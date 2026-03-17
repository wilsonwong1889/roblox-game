local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

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

function PlayerProfile.getEarningsPerSecond(player: Player): number
	local profile = playerProfiles[player]
	if not profile then
		return 0
	end

	local rate = 0
	for upgradeId, dropperConfig in GameConfig.DROPPERS do
		if profile.PurchasedUpgrades[upgradeId] then
			rate += dropperConfig.value / dropperConfig.interval
		end
	end

	local conveyorMultiplier = if profile.PurchasedUpgrades.conveyor_speed then 1.2 else 1
	rate *= conveyorMultiplier

	return math.floor(rate * 10 + 0.5) / 10
end

function PlayerProfile.getStatePayload(player: Player)
	local profile = playerProfiles[player]
	if not profile then
		return nil
	end

	local hasTycoon = profile.TycoonId ~= nil
	local purchasedUpgrades = copyUpgrades(profile.PurchasedUpgrades)
	local earningsPerSecond = PlayerProfile.getEarningsPerSecond(player)
	local statusText

	if not hasTycoon then
		statusText = "Walk to a green claim pad to claim a tycoon."
	elseif not purchasedUpgrades.basic_dropper then
		statusText = "Buy Basic Dropper to start the money loop."
	elseif profile.CollectorStoredCash > 0 then
		statusText = "Collect from the money pad to move cash into your wallet."
	elseif not purchasedUpgrades.second_dropper then
		statusText = "Buy Second Dropper to speed up the factory."
	elseif not purchasedUpgrades.wall_set_1 then
		statusText = "Buy Wall Set 1 to start securing the base."
	elseif not purchasedUpgrades.front_door then
		statusText = "Buy Front Door for owner-only entry."
	elseif not purchasedUpgrades.reinforced_door then
		statusText = "Buy Reinforced Door for a stronger front gate."
	elseif not purchasedUpgrades.high_walls then
		statusText = "Buy High Walls to finish the perimeter."
	else
		statusText = "Factory running. Collect cash whenever the pad fills."
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
		purchasedUpgrades = purchasedUpgrades,
		statusText = statusText,
	}
end

function PlayerProfile.removeProfile(player: Player)
	playerProfiles[player] = nil
end

return PlayerProfile
