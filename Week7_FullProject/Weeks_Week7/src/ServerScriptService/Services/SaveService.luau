local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

local SaveService = {}

local DATA_STORE_NAME = "BreakInTycoon_PlayerData_v1"
local SCHEMA_VERSION = 1
local MAX_RETRIES = 3

export type SerializedProfile = {
	SchemaVersion: number,
	UserId: number,
	Name: string,
	DisplayName: string,
	TycoonId: string?,
	WalletCash: number,
	StashCash: number,
	VaultCash: number,
	Gems: number,
	CollectorStoredCash: number,
	TotalEarned: number,
	Kills: number,
	Coins: number,
	FreeSpins: number,
	PurchasedUpgrades: { [string]: boolean },
	RedeemedCodes: { [string]: boolean },
	VipStatus: boolean,
	RebirthCount: number,
	DailySpinClaimKey: string?,
	DailySpinLastReward: number,
	DailySpinLastRewardName: string?,
	DailySpinLastRewardType: string?,
	LastSavedAt: number,
}

export type ProfileIdentity = {
	UserId: number,
	Name: string,
	DisplayName: string,
}

export type ProfileLike = {
	UserId: number,
	Name: string,
	DisplayName: string,
	TycoonId: string?,
	WalletCash: number,
	StashCash: number,
	VaultCash: number,
	Gems: number,
	CollectorStoredCash: number,
	TotalEarned: number,
	Kills: number,
	Coins: number,
	FreeSpins: number,
	PurchasedUpgrades: { [string]: boolean },
	RedeemedCodes: { [string]: boolean },
	VipStatus: boolean,
	RebirthCount: number,
	DailySpinClaimKey: string?,
	DailySpinLastReward: number,
	DailySpinLastRewardName: string?,
	DailySpinLastRewardType: string?,
}

local store = DataStoreService:GetDataStore(DATA_STORE_NAME)

local function sanitizeNumber(value: any, fallback: number, minValue: number?, maxValue: number?): number
	if typeof(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
		return fallback
	end

	local rounded = math.floor(value)
	if minValue then
		rounded = math.max(minValue, rounded)
	end
	if maxValue then
		rounded = math.min(maxValue, rounded)
	end

	return rounded
end

local function sanitizeString(value: any, fallback: string): string
	if typeof(value) ~= "string" or value == "" then
		return fallback
	end

	return value
end

local function sanitizePurchasedUpgrades(value: any): { [string]: boolean }
	local sanitized = {}
	if typeof(value) ~= "table" then
		return sanitized
	end

	for upgradeId, purchased in value do
		if typeof(upgradeId) == "string" and purchased == true and GameConfig.UPGRADES[upgradeId] then
			sanitized[upgradeId] = true
		end
	end

	return sanitized
end

local function sanitizeFlags(value: any): { [string]: boolean }
	local sanitized = {}
	if typeof(value) ~= "table" then
		return sanitized
	end

	for key, enabled in value do
		if typeof(key) == "string" and enabled == true then
			sanitized[key] = true
		end
	end

	return sanitized
end

function SaveService.getStore()
	return store
end

function SaveService.getSchemaVersion(): number
	return SCHEMA_VERSION
end

function SaveService.buildDefaultRecord(identity: ProfileIdentity): SerializedProfile
	return {
		SchemaVersion = SCHEMA_VERSION,
		UserId = identity.UserId,
		Name = sanitizeString(identity.Name, "Player"),
		DisplayName = sanitizeString(identity.DisplayName, sanitizeString(identity.Name, "Player")),
		TycoonId = nil,
		WalletCash = GameConfig.STARTING_CASH,
		StashCash = GameConfig.STARTING_STASH_CASH,
		VaultCash = GameConfig.STARTING_VAULT_CASH,
		Gems = GameConfig.STARTING_GEMS,
		CollectorStoredCash = 0,
		TotalEarned = 0,
		Kills = 0,
		Coins = 0,
		FreeSpins = 0,
		PurchasedUpgrades = {},
		RedeemedCodes = {},
		VipStatus = false,
		RebirthCount = 0,
		DailySpinClaimKey = nil,
		DailySpinLastReward = 0,
		DailySpinLastRewardName = nil,
		DailySpinLastRewardType = nil,
		LastSavedAt = os.time(),
	}
end

function SaveService.serializeProfile(profile: ProfileLike): SerializedProfile
	local identity = {
		UserId = sanitizeNumber(profile.UserId, 0, 0, math.huge),
		Name = sanitizeString(profile.Name, "Player"),
		DisplayName = sanitizeString(profile.DisplayName, sanitizeString(profile.Name, "Player")),
	}

	return {
		SchemaVersion = SCHEMA_VERSION,
		UserId = identity.UserId,
		Name = identity.Name,
		DisplayName = identity.DisplayName,
		TycoonId = sanitizeString(profile.TycoonId, ""),
		WalletCash = sanitizeNumber(profile.WalletCash, GameConfig.STARTING_CASH, 0, 1_000_000_000),
		StashCash = sanitizeNumber(profile.StashCash, GameConfig.STARTING_STASH_CASH, 0, 1_000_000_000),
		VaultCash = sanitizeNumber(profile.VaultCash, GameConfig.STARTING_VAULT_CASH, 0, 1_000_000_000),
		Gems = sanitizeNumber(profile.Gems, GameConfig.STARTING_GEMS, 0, 1_000_000),
		CollectorStoredCash = sanitizeNumber(profile.CollectorStoredCash, 0, 0, 1_000_000_000),
		TotalEarned = sanitizeNumber(profile.TotalEarned, 0, 0, 2_147_483_647),
		Kills = sanitizeNumber(profile.Kills, 0, 0, 2_147_483_647),
		Coins = sanitizeNumber(profile.Coins, 0, 0, 1_000_000),
		FreeSpins = sanitizeNumber(profile.FreeSpins, 0, 0, 100_000),
		PurchasedUpgrades = sanitizePurchasedUpgrades(profile.PurchasedUpgrades),
		RedeemedCodes = sanitizeFlags(profile.RedeemedCodes),
		VipStatus = profile.VipStatus == true,
		RebirthCount = sanitizeNumber(profile.RebirthCount, 0, 0, 1000),
		DailySpinClaimKey = if typeof(profile.DailySpinClaimKey) == "string" and profile.DailySpinClaimKey ~= "" then profile.DailySpinClaimKey else nil,
		DailySpinLastReward = sanitizeNumber(profile.DailySpinLastReward, 0, 0, 1_000_000_000),
		DailySpinLastRewardName = if typeof(profile.DailySpinLastRewardName) == "string" and profile.DailySpinLastRewardName ~= "" then profile.DailySpinLastRewardName else nil,
		DailySpinLastRewardType = if typeof(profile.DailySpinLastRewardType) == "string" and profile.DailySpinLastRewardType ~= "" then profile.DailySpinLastRewardType else nil,
		LastSavedAt = os.time(),
	}
end

function SaveService.deserializeProfile(raw: any, identity: ProfileIdentity): SerializedProfile
	local fallback = SaveService.buildDefaultRecord(identity)
	if typeof(raw) ~= "table" then
		return fallback
	end

	local purchasedUpgrades = sanitizePurchasedUpgrades(raw.PurchasedUpgrades)
	local tycoonId = if typeof(raw.TycoonId) == "string" and raw.TycoonId ~= "" then raw.TycoonId else nil

	return {
		SchemaVersion = sanitizeNumber(raw.SchemaVersion, SCHEMA_VERSION, 1, 100),
		UserId = sanitizeNumber(raw.UserId, identity.UserId, 0, math.huge),
		Name = sanitizeString(raw.Name, fallback.Name),
		DisplayName = sanitizeString(raw.DisplayName, fallback.DisplayName),
		TycoonId = tycoonId,
		WalletCash = sanitizeNumber(raw.WalletCash, fallback.WalletCash, 0, 1_000_000_000),
		StashCash = sanitizeNumber(raw.StashCash, fallback.StashCash, 0, 1_000_000_000),
		VaultCash = sanitizeNumber(raw.VaultCash, fallback.VaultCash, 0, 1_000_000_000),
		Gems = sanitizeNumber(raw.Gems, fallback.Gems, 0, 1_000_000),
		CollectorStoredCash = sanitizeNumber(raw.CollectorStoredCash, fallback.CollectorStoredCash, 0, 1_000_000_000),
		TotalEarned = sanitizeNumber(raw.TotalEarned, fallback.TotalEarned, 0, 2_147_483_647),
		Kills = sanitizeNumber(raw.Kills, fallback.Kills, 0, 2_147_483_647),
		Coins = sanitizeNumber(raw.Coins, fallback.Coins, 0, 1_000_000),
		FreeSpins = sanitizeNumber(raw.FreeSpins, fallback.FreeSpins, 0, 100_000),
		PurchasedUpgrades = purchasedUpgrades,
		RedeemedCodes = sanitizeFlags(raw.RedeemedCodes),
		VipStatus = raw.VipStatus == true,
		RebirthCount = sanitizeNumber(raw.RebirthCount, fallback.RebirthCount, 0, 1000),
		DailySpinClaimKey = if typeof(raw.DailySpinClaimKey) == "string" and raw.DailySpinClaimKey ~= "" then raw.DailySpinClaimKey else nil,
		DailySpinLastReward = sanitizeNumber(raw.DailySpinLastReward, fallback.DailySpinLastReward, 0, 1_000_000_000),
		DailySpinLastRewardName = if typeof(raw.DailySpinLastRewardName) == "string" and raw.DailySpinLastRewardName ~= "" then raw.DailySpinLastRewardName else nil,
		DailySpinLastRewardType = if typeof(raw.DailySpinLastRewardType) == "string" and raw.DailySpinLastRewardType ~= "" then raw.DailySpinLastRewardType else nil,
		LastSavedAt = sanitizeNumber(raw.LastSavedAt, fallback.LastSavedAt, 0, math.huge),
	}
end

function SaveService.validateProfileRecord(record: any): (boolean, string?)
	if typeof(record) ~= "table" then
		return false, "Profile record must be a table."
	end

	if typeof(record.UserId) ~= "number" then
		return false, "Profile record must include a numeric UserId."
	end

	if typeof(record.Name) ~= "string" then
		return false, "Profile record must include a string Name."
	end

	if typeof(record.DisplayName) ~= "string" then
		return false, "Profile record must include a string DisplayName."
	end

	if typeof(record.PurchasedUpgrades) ~= "table" then
		return false, "Profile record must include a PurchasedUpgrades table."
	end

	return true, nil
end

function SaveService.getKeyForUserId(userId: number): string
	return string.format("u_%d", sanitizeNumber(userId, 0, 0, math.huge))
end

function SaveService.loadProfileAsync(identity: ProfileIdentity): (boolean, SerializedProfile?, string?)
	local key = SaveService.getKeyForUserId(identity.UserId)

	for attempt = 1, MAX_RETRIES do
		local ok, result = pcall(function()
			return store:GetAsync(key)
		end)

		if ok then
			return true, SaveService.deserializeProfile(result, identity), nil
		end

		if attempt == MAX_RETRIES then
			return false, nil, tostring(result)
		end

		task.wait(0.5 * attempt)
	end

	return false, nil, "Unknown load failure."
end

function SaveService.saveProfileAsync(profile: ProfileLike): (boolean, string?)
	local serialized = SaveService.serializeProfile(profile)
	local key = SaveService.getKeyForUserId(serialized.UserId)

	for attempt = 1, MAX_RETRIES do
		local ok, err = pcall(function()
			store:UpdateAsync(key, function()
				return serialized
			end)
		end)

		if ok then
			return true, nil
		end

		if attempt == MAX_RETRIES then
			return false, tostring(err)
		end

		task.wait(0.5 * attempt)
	end

	return false, "Unknown save failure."
end

function SaveService.buildResetPlan(profile: ProfileLike)
	return {
		UserId = sanitizeNumber(profile.UserId, 0, 0, math.huge),
		TycoonId = nil,
		WalletCash = GameConfig.STARTING_CASH,
		StashCash = GameConfig.STARTING_STASH_CASH,
		VaultCash = GameConfig.STARTING_VAULT_CASH,
		CollectorStoredCash = 0,
		PurchasedUpgrades = {},
	}
end

function SaveService.needsMigration(record: any): boolean
	if typeof(record) ~= "table" then
		return true
	end

	return sanitizeNumber(record.SchemaVersion, 0, 0, math.huge) < SCHEMA_VERSION
end

return SaveService
