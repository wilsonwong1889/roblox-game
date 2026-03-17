local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)
local PlayerProfile = require(ReplicatedStorage.Modules.PlayerProfile)
local SelfTestService = require(script.Parent.Services.SelfTestService)
local TycoonService = require(script.Parent.Services.TycoonService)

local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder")
remotesFolder.Name = "Remotes"
remotesFolder.Parent = ReplicatedStorage

local stateRemote = remotesFolder:FindFirstChild("StateUpdate") or Instance.new("RemoteEvent")
stateRemote.Name = "StateUpdate"
stateRemote.Parent = remotesFolder

local messageRemote = remotesFolder:FindFirstChild("UiMessage") or Instance.new("RemoteEvent")
messageRemote.Name = "UiMessage"
messageRemote.Parent = remotesFolder

local requestStateFunction = remotesFolder:FindFirstChild("RequestState") or Instance.new("RemoteFunction")
requestStateFunction.Name = "RequestState"
requestStateFunction.Parent = remotesFolder

local function sendUiMessage(player: Player, title: string, body: string, tone: string?)
	messageRemote:FireClient(player, {
		title = title,
		body = body,
		tone = tone or "info",
	})
end

local function sendStateUpdate(player: Player)
	local payload = PlayerProfile.getStatePayload(player)
	if payload then
		stateRemote:FireClient(player, payload)
	end
end

local function broadcastAllStates()
	for _, player in Players:GetPlayers() do
		sendStateUpdate(player)
	end
end

local function connectClaimPrompts()
	for tycoonId, tycoon in TycoonService.getTycoons() do
		tycoon.ClaimPrompt.Triggered:Connect(function(player)
			local profile = PlayerProfile.getProfile(player)
			if not profile then
				return
			end

			if profile.TycoonId then
				sendUiMessage(player, "Already Claimed", "You already own a tycoon in this server.", "warning")
				return
			end

			if not TycoonService.claimTycoon(player, tycoonId) then
				local message = if profile.TycoonId
					then "You already own a tycoon in this server."
					else "That tycoon is already claimed by another player."
				sendUiMessage(player, "Claim Failed", message, "warning")
				return
			end

			PlayerProfile.setTycoonId(player, tycoonId)
			sendUiMessage(
				player,
				"Tycoon Claimed",
				if GameConfig.CLAIM_TELEPORT_ON_CLAIM
					then string.format("%s is now yours. You have been moved to your spawn.", tycoonId)
					else string.format("%s is now yours. Your next respawn will send you there.", tycoonId),
				"success"
			)

			if GameConfig.CLAIM_TELEPORT_ON_CLAIM then
				task.defer(function()
					TycoonService.teleportToSpawn(player, tycoonId)
				end)
			end

			broadcastAllStates()
		end)
	end
end

TycoonService.initialize()
connectClaimPrompts()

if RunService:IsStudio() then
	SelfTestService.run()
end

	requestStateFunction.OnServerInvoke = function(player)
	return PlayerProfile.getStatePayload(player)
end

Players.PlayerAdded:Connect(function(player)
	PlayerProfile.createProfile(player)
	sendStateUpdate(player)

	player.CharacterAdded:Connect(function()
		local profile = PlayerProfile.getProfile(player)
		if not profile or not profile.TycoonId then
			return
		end

		local character = player.Character
		if not character then
			return
		end

		local root = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 10)
		if root and profile.TycoonId then
			TycoonService.teleportToSpawn(player, profile.TycoonId)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	PlayerProfile.clearTycoonId(player)
	TycoonService.releaseTycoon(player)
	PlayerProfile.removeProfile(player)
	broadcastAllStates()
end)

print("Week 1 tycoon foundation bootstrapped")
