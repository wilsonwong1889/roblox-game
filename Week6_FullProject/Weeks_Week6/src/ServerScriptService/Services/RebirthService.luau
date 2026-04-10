local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

local RebirthService = {}

export type ProgressState = {
	totalEarned: number?,
	walletCash: number?,
	stashCash: number?,
	vaultCash: number?,
	collectorStoredCash: number?,
	rebirthCount: number?,
	purchasedUpgrades: { [string]: boolean }?,
}

export type ResetPlan = {
	canRebirth: boolean,
	rebirthCount: number,
	nextRebirthCount: number,
	requiredTotalEarned: number,
	progressScore: number,
	progressLabel: string,
	payoutMultiplier: number,
	cashMultiplier: number,
	startingBonusCash: number,
	requiredMilestones: { string },
	completedMilestones: { string },
	reset: {
		walletCash: number,
		stashCash: number,
		vaultCash: number,
		collectorStoredCash: number,
		tycoonId: string?,
		purchasedUpgrades: boolean,
	},
	keep: {
		rebirthCount: boolean,
		displayName: boolean,
		leaderstatsHistory: boolean,
	},
	unlocks: {
		newStarterCash: number,
		newPrestigeTitle: string,
		permanentMultiplier: number,
	},
}

local REQUIRED_TOTAL_EARNED = 1_000_000
local STARTING_REBIRTH_CASH = 25_000
local REBIRTH_MULTIPLIER_STEP = 0.25
local CASH_MULTIPLIER_STEP = 0.10
local MAX_MULTIPLIER_BONUS = 5

local PROGRESSION_STAGES = {
	{
		id = "claim",
		label = "Claimed Tycoon",
		required = { "tycoon" },
	},
	{
		id = "starter_clicker",
		label = "Starter Clicker Online",
		required = { "basic_dropper" },
	},
	{
		id = "full_droppers",
		label = "All First-Floor Droppers",
		required = { "dropper_8" },
	},
	{
		id = "auto_collector",
		label = "Auto Collector Online",
		required = { "auto_collector" },
	},
	{
		id = "utility_lane",
		label = "Utility Lane Online",
		required = { "premium_conveyor", "cash_compressor", "collector_array" },
	},
	{
		id = "wall_shell",
		label = "Wall Shell Online",
		required = { "wall_set_1", "front_door", "reinforced_door", "high_walls" },
	},
	{
		id = "outer_shell",
		label = "Outer Shell Complete",
		required = { "security_lights", "corner_posts", "rear_extension", "utility_bay", "roof_frame" },
	},
}

local function getPurchasedSet(purchasedUpgrades: { [string]: boolean }?): { [string]: boolean }
	return purchasedUpgrades or {}
end

local function hasAllRequired(purchased: { [string]: boolean }, claimed: boolean, requirements: { string }): boolean
	for _, upgradeId in requirements do
		if upgradeId == "tycoon" then
			if not claimed then
				return false
			end
		elseif not purchased[upgradeId] then
			return false
		end
	end

	return true
end

function RebirthService.getProgressScore(state: ProgressState): number
	local purchased = getPurchasedSet(state.purchasedUpgrades)
	local score = 0

	if state.tycoonId ~= nil then
		score = 10
	end

	if purchased.basic_dropper then
		score = math.max(score, 20)
	end

	if purchased.dropper_8 then
		score = math.max(score, 40)
	end

	if purchased.auto_collector then
		score = math.max(score, 55)
	end

	if purchased.collector_array then
		score = math.max(score, 65)
	end

	if purchased.wall_set_1 then
		score = math.max(score, 72)
	end

	if purchased.front_door then
		score = math.max(score, 76)
	end

	if purchased.reinforced_door then
		score = math.max(score, 80)
	end

	if purchased.high_walls then
		score = math.max(score, 84)
	end

	if purchased.security_lights then
		score = math.max(score, 88)
	end

	if purchased.corner_posts then
		score = math.max(score, 92)
	end

	if purchased.rear_extension then
		score = math.max(score, 95)
	end

	if purchased.utility_bay then
		score = math.max(score, 98)
	end

	if purchased.roof_frame then
		score = math.max(score, 100)
	end

	return score
end

function RebirthService.getProgressLabel(state: ProgressState): string
	local purchased = getPurchasedSet(state.purchasedUpgrades)
	local claimed = state.tycoonId ~= nil

	for index = #PROGRESSION_STAGES, 1, -1 do
		local stage = PROGRESSION_STAGES[index]
		if hasAllRequired(purchased, claimed, stage.required) then
			return stage.label
		end
	end

	if state.tycoonId == nil then
		return "Unclaimed"
	end

	return "Starter Progress"
end

function RebirthService.getCurrentRewardMultiplier(rebirthCount: number?): number
	local count = math.max(0, math.floor(rebirthCount or 0))
	return 1 + math.min(count, MAX_MULTIPLIER_BONUS) * REBIRTH_MULTIPLIER_STEP
end

function RebirthService.getCurrentCashMultiplier(rebirthCount: number?): number
	local count = math.max(0, math.floor(rebirthCount or 0))
	return 1 + math.min(count, MAX_MULTIPLIER_BONUS) * CASH_MULTIPLIER_STEP
end

function RebirthService.getRequiredTotalEarned(rebirthCount: number?): number
	local count = math.max(0, math.floor(rebirthCount or 0))
	return REQUIRED_TOTAL_EARNED + (count * 250_000)
end

function RebirthService.canRebirth(state: ProgressState): boolean
	local purchased = getPurchasedSet(state.purchasedUpgrades)
	if state.tycoonId == nil then
		return false
	end

	if not purchased.roof_frame then
		return false
	end

	local totalEarned = math.floor(state.totalEarned or 0)
	return totalEarned >= RebirthService.getRequiredTotalEarned(state.rebirthCount)
end

function RebirthService.getResetPlan(state: ProgressState): ResetPlan
	local purchased = getPurchasedSet(state.purchasedUpgrades)
	local claimed = state.tycoonId ~= nil
	local completedMilestones = {}
	local requiredMilestones = {}

	for _, stage in PROGRESSION_STAGES do
		if hasAllRequired(purchased, claimed, stage.required) then
			table.insert(completedMilestones, stage.label)
		else
			table.insert(requiredMilestones, stage.label)
		end
	end

	local rebirthCount = math.max(0, math.floor(state.rebirthCount or 0))
	local nextRebirthCount = rebirthCount + 1
	local canRebirth = RebirthService.canRebirth(state)
	local progressScore = RebirthService.getProgressScore(state)
	local progressLabel = RebirthService.getProgressLabel(state)
	local payoutMultiplier = RebirthService.getCurrentRewardMultiplier(rebirthCount)
	local cashMultiplier = RebirthService.getCurrentCashMultiplier(rebirthCount)

	return {
		canRebirth = canRebirth,
		rebirthCount = rebirthCount,
		nextRebirthCount = nextRebirthCount,
		requiredTotalEarned = RebirthService.getRequiredTotalEarned(rebirthCount),
		progressScore = progressScore,
		progressLabel = progressLabel,
		payoutMultiplier = payoutMultiplier,
		cashMultiplier = cashMultiplier,
		startingBonusCash = STARTING_REBIRTH_CASH * nextRebirthCount,
		requiredMilestones = requiredMilestones,
		completedMilestones = completedMilestones,
		reset = {
			walletCash = 0,
			stashCash = 0,
			vaultCash = 0,
			collectorStoredCash = 0,
			tycoonId = nil,
			purchasedUpgrades = true,
		},
		keep = {
			rebirthCount = true,
			displayName = true,
			leaderstatsHistory = true,
		},
		unlocks = {
			newStarterCash = STARTING_REBIRTH_CASH * nextRebirthCount,
			newPrestigeTitle = string.format("Prestige %d", nextRebirthCount),
			permanentMultiplier = payoutMultiplier,
		},
	}
end

function RebirthService.describeResetPlan(state: ProgressState): { string }
	local plan = RebirthService.getResetPlan(state)
	local lines = {
		string.format("Progress: %s (%d%%)", plan.progressLabel, plan.progressScore),
		string.format("Required total earned: $%d", plan.requiredTotalEarned),
		string.format("Current multiplier: x%.2f", plan.payoutMultiplier),
		string.format("Next starter cash: $%d", plan.unlocks.newStarterCash),
		"Reset wallet, stash, vault, collector storage, tycoon ownership, and purchased upgrades.",
		"Keep rebirth count, display identity, and historical prestige tracking.",
	}

	if plan.canRebirth then
		table.insert(lines, "Player is eligible to rebirth now.")
	else
		table.insert(lines, "Player is not eligible yet.")
	end

	return lines
end

function RebirthService.getStageNames(): { string }
	local names = {}
	for _, stage in PROGRESSION_STAGES do
		table.insert(names, stage.label)
	end
	return names
end

return RebirthService
