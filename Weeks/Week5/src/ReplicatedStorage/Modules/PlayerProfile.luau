local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)
local SecondFloorConfig = require(ReplicatedStorage.Modules.SecondFloorConfig)

local PlayerProfile = {}

local MAX_CASH = 1_000_000_000
local MAX_TOTAL_EARNED = 2_147_483_647

export type PlayerData = {
	UserId: number,
	Name: string,
	DisplayName: string,
	TycoonId: string?,
	WalletCash: number,
	StashCash: number,
	VaultCash: number,
	CollectorStoredCash: number,
	TotalEarned: number,
	PurchasedUpgrades: { [string]: boolean },
}

local playerProfiles: { [Player]: PlayerData } = {}

local function clampCash(value: number): number
	return math.clamp(math.floor(value), 0, MAX_CASH)
end

local function clampTotalEarned(value: number): number
	return math.clamp(math.floor(value), 0, MAX_TOTAL_EARNED)
end

local function copyUpgrades(upgrades: { [string]: boolean }): { [string]: boolean }
	local copy = {}
	for upgradeId, purchased in upgrades do
		if purchased then
			copy[upgradeId] = true
		end
	end
	return copy
end

local function getUpperDropperIds(): { string }
	return GameConfig.getUpperDropperIds()
end

function PlayerProfile.createProfile(player: Player): PlayerData
	local profile: PlayerData = {
		UserId = player.UserId,
		Name = player.Name,
		DisplayName = player.DisplayName,
		TycoonId = nil,
		WalletCash = GameConfig.STARTING_CASH,
		StashCash = GameConfig.STARTING_STASH_CASH,
		VaultCash = GameConfig.STARTING_VAULT_CASH,
		CollectorStoredCash = 0,
		TotalEarned = 0,
		PurchasedUpgrades = {},
	}

	playerProfiles[player] = profile
	return profile
end

function PlayerProfile.getProfile(player: Player): PlayerData?
	return playerProfiles[player]
end

function PlayerProfile.setTycoonId(player: Player, tycoonId: string?)
	local profile = playerProfiles[player]
	if profile then
		profile.TycoonId = tycoonId
	end
end

function PlayerProfile.clearTycoonId(player: Player)
	local profile = playerProfiles[player]
	if profile then
		profile.TycoonId = nil
	end
end

function PlayerProfile.setWalletCash(player: Player, amount: number)
	local profile = playerProfiles[player]
	if profile then
		profile.WalletCash = clampCash(amount)
	end
end

function PlayerProfile.addWalletCash(player: Player, amount: number)
	local profile = playerProfiles[player]
	if profile and amount > 0 then
		profile.WalletCash = clampCash(profile.WalletCash + amount)
		profile.TotalEarned = clampTotalEarned(profile.TotalEarned + amount)
	end
end

function PlayerProfile.trySpendCash(player: Player, amount: number): boolean
	local profile = playerProfiles[player]
	if not profile or amount <= 0 or profile.WalletCash < amount then
		return false
	end

	profile.WalletCash = clampCash(profile.WalletCash - amount)
	return true
end

function PlayerProfile.setStashCash(player: Player, amount: number)
	local profile = playerProfiles[player]
	if profile then
		profile.StashCash = clampCash(amount)
	end
end

function PlayerProfile.addStashCash(player: Player, amount: number)
	local profile = playerProfiles[player]
	if profile and amount > 0 then
		profile.StashCash = clampCash(profile.StashCash + amount)
	end
end

function PlayerProfile.setVaultCash(player: Player, amount: number)
	local profile = playerProfiles[player]
	if profile then
		profile.VaultCash = clampCash(amount)
	end
end

function PlayerProfile.addVaultCash(player: Player, amount: number)
	local profile = playerProfiles[player]
	if profile and amount > 0 then
		profile.VaultCash = clampCash(profile.VaultCash + amount)
	end
end

function PlayerProfile.setCollectorStored(player: Player, amount: number)
	local profile = playerProfiles[player]
	if profile then
		profile.CollectorStoredCash = clampCash(amount)
	end
end

function PlayerProfile.addCollectorStored(player: Player, amount: number)
	local profile = playerProfiles[player]
	if profile and amount > 0 then
		profile.CollectorStoredCash = clampCash(profile.CollectorStoredCash + amount)
	end
end

function PlayerProfile.collectStoredCash(player: Player): number
	local profile = playerProfiles[player]
	if not profile then
		return 0
	end

	local amount = profile.CollectorStoredCash
	if amount <= 0 then
		return 0
	end

	profile.CollectorStoredCash = 0
	profile.WalletCash = clampCash(profile.WalletCash + amount)
	profile.TotalEarned = clampTotalEarned(profile.TotalEarned + amount)
	return amount
end

function PlayerProfile.markUpgradePurchased(player: Player, upgradeId: string)
	local profile = playerProfiles[player]
	if profile then
		profile.PurchasedUpgrades[upgradeId] = true
	end
end

function PlayerProfile.hasUpgrade(player: Player, upgradeId: string): boolean
	local profile = playerProfiles[player]
	return profile ~= nil and profile.PurchasedUpgrades[upgradeId] == true
end

function PlayerProfile.getUpgradeCount(player: Player): number
	local profile = playerProfiles[player]
	if not profile then
		return 0
	end

	local count = 0
	for _, purchased in profile.PurchasedUpgrades do
		if purchased then
			count += 1
		end
	end

	return count
end

function PlayerProfile.getPurchasedDropperCount(player: Player): number
	local profile = playerProfiles[player]
	if not profile then
		return 0
	end

	local count = 0
	for _, dropperId in GameConfig.DROPPER_ORDER do
		if profile.PurchasedUpgrades[dropperId] then
			count += 1
		end
	end

	return count
end

function PlayerProfile.hasAllDroppers(player: Player): boolean
	return PlayerProfile.getPurchasedDropperCount(player) >= #GameConfig.DROPPER_ORDER
end

function PlayerProfile.getPurchasedUpperDropperCount(player: Player): number
	local profile = playerProfiles[player]
	if not profile then
		return 0
	end

	local count = 0
	for _, dropperId in getUpperDropperIds() do
		if profile.PurchasedUpgrades[dropperId] then
			count += 1
		end
	end

	return count
end

function PlayerProfile.getEarningsPerSecond(player: Player): number
	local profile = playerProfiles[player]
	if not profile then
		return 0
	end

	return GameConfig.getEarningsPerSecondForUpgrades(profile.PurchasedUpgrades)
end

function PlayerProfile.getStatePayload(player: Player)
	local profile = playerProfiles[player]
	if not profile then
		return nil
	end

	local hasTycoon = profile.TycoonId ~= nil
	local purchasedUpgrades = copyUpgrades(profile.PurchasedUpgrades)
	local earningsPerSecond = PlayerProfile.getEarningsPerSecond(player)
	local hasAllDroppers = PlayerProfile.hasAllDroppers(player)
	local upperDropperIds = getUpperDropperIds()
	local upperDropperCount = PlayerProfile.getPurchasedUpperDropperCount(player)
	local statusText

	purchasedUpgrades.clicker = hasTycoon and not purchasedUpgrades.basic_dropper
	purchasedUpgrades.front_door_button = purchasedUpgrades.front_door == true or purchasedUpgrades.reinforced_door == true

	if not hasTycoon then
		statusText = "Walk to a green claim pad to claim a tycoon."
	elseif not purchasedUpgrades.basic_dropper then
		statusText = "Use the starter clicker, then buy Basic Dropper to automate it."
	elseif profile.CollectorStoredCash > 0 then
		statusText = "Collect from the money pad to move cash into your wallet."
	elseif not hasAllDroppers then
		statusText = string.format(
			"Expand the first floor. %d of %d automated droppers are online.",
			PlayerProfile.getPurchasedDropperCount(player),
			#GameConfig.DROPPER_ORDER
		)
	elseif not purchasedUpgrades.auto_collector then
		statusText = "Buy Auto Collector after all eight droppers are online."
	elseif not purchasedUpgrades.premium_conveyor then
		statusText = "Buy Premium Conveyor to push the first-floor lane faster."
	elseif not purchasedUpgrades.cash_compressor then
		statusText = "Buy Cash Compressor to raise the value of each money block."
	elseif not purchasedUpgrades.collector_array then
		statusText = "Buy Collector Array to boost the payout line around the collector."
	elseif not purchasedUpgrades.wall_set_1 then
		statusText = "Buy Wall Set 1 to start securing the base."
	elseif not purchasedUpgrades.front_door then
		statusText = "Buy Front Door for owner-only entry."
	elseif not purchasedUpgrades.reinforced_door then
		statusText = "Buy Reinforced Door for a stronger front gate."
	elseif not purchasedUpgrades.high_walls then
		statusText = "Buy High Walls to finish the perimeter."
	elseif not purchasedUpgrades.security_lights then
		statusText = "Buy Security Lights to tighten the wall line around the base."
	elseif not purchasedUpgrades.corner_posts then
		statusText = "Buy Corner Posts to finish the first-floor shell."
	elseif not purchasedUpgrades.rear_extension then
		statusText = "Buy Rear Extension to push the factory deeper into the back end."
	elseif not purchasedUpgrades.utility_bay then
		statusText = "Buy Utility Bay to build out the side service lane."
	elseif not purchasedUpgrades.roof_frame then
		statusText = "Buy Roof Frame to finish the expanded first-floor structure."
	elseif not purchasedUpgrades.second_floor then
		statusText = string.format("Buy %s to unlock the upper deck.", SecondFloorConfig.UPGRADE_NAME)
	elseif not purchasedUpgrades.upper_walls then
		statusText = "Buy Upper Walls to secure the second-floor shell."
	elseif not purchasedUpgrades.upper_conveyor then
		statusText = "Buy Upper Conveyor to bring the second-floor line online."
	elseif upperDropperCount < #upperDropperIds then
		statusText = string.format(
			"Expand the upper deck. %d of %d second-floor droppers are online.",
			upperDropperCount,
			#upperDropperIds
		)
	elseif not purchasedUpgrades.upper_collector then
		statusText = "Buy Upper Collector to complete the second-floor payout line."
	else
		statusText = "Factory running. Both production floors are online."
	end

	return {
		gameName = GameConfig.GAME_NAME,
		gameStage = GameConfig.WEEK_PHASE,
		walletCash = profile.WalletCash,
		stashCash = profile.StashCash,
		vaultCash = profile.VaultCash,
		collectorStored = profile.CollectorStoredCash,
		collectorStoredCash = profile.CollectorStoredCash,
		tycoonId = profile.TycoonId,
		totalEarned = profile.TotalEarned,
		earningsPerSecond = earningsPerSecond,
		earningsPerSecondText = string.format("$%.1f/sec", earningsPerSecond),
		dropperCount = PlayerProfile.getPurchasedDropperCount(player),
		upperDropperCount = upperDropperCount,
		upperDropperTotal = #upperDropperIds,
		hasAllDroppers = hasAllDroppers,
		autoCollectorUnlocked = purchasedUpgrades.auto_collector == true and hasAllDroppers,
		secondFloorUnlocked = purchasedUpgrades.second_floor == true,
		upperCollectorUnlocked = purchasedUpgrades.upper_collector == true,
		clickerCashPerTap = GameConfig.DROPPERS.basic_dropper.value,
		ownerName = profile.DisplayName,
		purchasedUpgrades = purchasedUpgrades,
		statusText = statusText,
	}
end

function PlayerProfile.removeProfile(player: Player)
	playerProfiles[player] = nil
end

return PlayerProfile
