local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

local PlayerProfile = {}

export type PlayerData = {
	UserId: number,
	Name: string,
	DisplayName: string,
	TycoonId: string?,
	WalletCash: number,
	StashCash: number,
	VaultCash: number,
	PurchasedUpgrades: { [string]: boolean },
}

local playerProfiles: { [Player]: PlayerData } = {}

function PlayerProfile.createProfile(player: Player): PlayerData
	local profile: PlayerData = {
		UserId = player.UserId,
		Name = player.Name,
		DisplayName = player.DisplayName,
		TycoonId = nil,
		WalletCash = GameConfig.STARTING_CASH,
		StashCash = GameConfig.STARTING_STASH_CASH,
		VaultCash = GameConfig.STARTING_VAULT_CASH,
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

function PlayerProfile.getStatePayload(player: Player)
	local profile = playerProfiles[player]
	if not profile then
		return nil
	end

	return {
		gameName = GameConfig.GAME_NAME,
		gameStage = GameConfig.GAME_STAGE,
		walletCash = profile.WalletCash,
		stashCash = profile.StashCash,
		vaultCash = profile.VaultCash,
		tycoonId = profile.TycoonId,
		statusText = if profile.TycoonId
			then string.format("You own %s. Future respawns route here.", profile.TycoonId)
			else "Walk to a green claim pad to claim a tycoon.",
	}
end

function PlayerProfile.removeProfile(player: Player)
	playerProfiles[player] = nil
end

return PlayerProfile
