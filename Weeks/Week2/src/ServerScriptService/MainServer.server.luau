local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

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

local dropperLoops: { [string]: { [string]: boolean } } = {}

local function sendUiMessage(player: Player, title: string, body: string, tone: string?)
	messageRemote:FireClient(player, {
		title = title,
		body = body,
		tone = tone or "info",
	})
end

local function getCompetitionSnapshot()
	local standings = {}

	for _, player in Players:GetPlayers() do
		local profile = PlayerProfile.getProfile(player)
		if profile then
			table.insert(standings, {
				name = player.DisplayName,
				tycoonId = profile.TycoonId,
				totalEarned = profile.TotalEarned,
				walletCash = profile.WalletCash,
				upgradeCount = PlayerProfile.getUpgradeCount(player),
			})
		end
	end

	table.sort(standings, function(a, b)
		if a.totalEarned == b.totalEarned then
			return a.upgradeCount > b.upgradeCount
		end

		return a.totalEarned > b.totalEarned
	end)

	return standings
end

local function getStatePayload(player: Player, competitionSnapshot)
	local profile = PlayerProfile.getProfile(player)
	if not profile then
		return nil
	end

	return {
		gameName = GameConfig.GAME_NAME,
		gameStage = GameConfig.WEEK_PHASE,
		walletCash = profile.WalletCash,
		collectorStored = profile.CollectorStoredCash,
		stashCash = profile.StashCash,
		vaultCash = profile.VaultCash,
		tycoonId = profile.TycoonId,
		totalEarned = profile.TotalEarned,
		purchasedUpgrades = profile.PurchasedUpgrades,
		competition = competitionSnapshot or getCompetitionSnapshot(),
	}
end

local function updateLeaderstats(player: Player)
	local profile = PlayerProfile.getProfile(player)
	if not profile then
		return
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player

		local cash = Instance.new("IntValue")
		cash.Name = "Cash"
		cash.Parent = leaderstats

		local stored = Instance.new("IntValue")
		stored.Name = "Stored"
		stored.Parent = leaderstats

		local earned = Instance.new("IntValue")
		earned.Name = "Earned"
		earned.Parent = leaderstats

		local upgrades = Instance.new("IntValue")
		upgrades.Name = "Upgrades"
		upgrades.Parent = leaderstats
	end

	leaderstats.Cash.Value = profile.WalletCash
	leaderstats.Stored.Value = profile.CollectorStoredCash
	leaderstats.Earned.Value = profile.TotalEarned
	leaderstats.Upgrades.Value = PlayerProfile.getUpgradeCount(player)
end

local function sendStateUpdate(player: Player)
	local payload = getStatePayload(player)
	if payload then
		stateRemote:FireClient(player, payload)
	end
end

local function broadcastAllStates()
	local competitionSnapshot = getCompetitionSnapshot()
	for _, player in Players:GetPlayers() do
		local payload = getStatePayload(player, competitionSnapshot)
		if payload then
			stateRemote:FireClient(player, payload)
		end
	end
end

local function refreshTycoonForPlayer(player: Player)
	local profile = PlayerProfile.getProfile(player)
	if not profile or not profile.TycoonId then
		updateLeaderstats(player)
		broadcastAllStates()
		return
	end

	TycoonService.applyVisualState(profile.TycoonId, profile.PurchasedUpgrades, profile.CollectorStoredCash)
	TycoonService.updateButtons(profile.TycoonId, profile.PurchasedUpgrades)
	updateLeaderstats(player)
	broadcastAllStates()
end

local function resetTycoonState(tycoonId: string)
	local tycoon = TycoonService.getTycoon(tycoonId)
	if not tycoon then
		return
	end

	for _, child in tycoon.MoneyPartsFolder:GetChildren() do
		child:Destroy()
	end

	dropperLoops[tycoonId] = nil
	TycoonService.applyVisualState(tycoonId, {}, 0)
	TycoonService.updateButtons(tycoonId, {})
end

local function spawnMoneyCrate(player: Player, tycoonId: string, upgradeId: string)
	local tycoon = TycoonService.getTycoon(tycoonId)
	local profile = PlayerProfile.getProfile(player)
	local dropperConfig = GameConfig.DROPPERS[upgradeId]
	if not tycoon or not profile or profile.TycoonId ~= tycoonId or not dropperConfig then
		return
	end

	local outputPoint = tycoon.DropperOutputs[upgradeId]
	if not outputPoint then
		return
	end

	local moneyPart = Instance.new("Part")
	moneyPart.Name = "MoneyCrate"
	moneyPart.Size = Vector3.new(2.8, 2.8, 2.8)
	moneyPart.Anchored = true
	moneyPart.CanCollide = false
	moneyPart.CanTouch = false
	moneyPart.CanQuery = false
	moneyPart.Color = dropperConfig.color
	moneyPart.Material = Enum.Material.Neon
	moneyPart.CFrame = outputPoint.CFrame
	moneyPart.Parent = tycoon.MoneyPartsFolder

	local fallTween = TweenService:Create(
		moneyPart,
		TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ CFrame = tycoon.ConveyorEntry.CFrame }
	)
	fallTween:Play()
	fallTween.Completed:Wait()

	if not moneyPart.Parent then
		return
	end

	local conveyorDuration = if profile.PurchasedUpgrades.conveyor_speed then 1.35 else 2.1
	local beltTween = TweenService:Create(
		moneyPart,
		TweenInfo.new(conveyorDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
		{ CFrame = tycoon.CollectorPoint.CFrame }
	)
	beltTween:Play()
	beltTween.Completed:Wait()

	if not moneyPart.Parent then
		return
	end

	local payoutValue = dropperConfig.value
	if not profile or profile.TycoonId ~= tycoonId then
		moneyPart:Destroy()
		return
	end

	PlayerProfile.addCollectorStored(player, payoutValue)
	moneyPart:Destroy()
	refreshTycoonForPlayer(player)
end

local function startDropperLoop(player: Player, tycoonId: string, upgradeId: string)
	dropperLoops[tycoonId] = dropperLoops[tycoonId] or {}
	if dropperLoops[tycoonId][upgradeId] then
		return
	end

	dropperLoops[tycoonId][upgradeId] = true

	task.spawn(function()
		while dropperLoops[tycoonId] and dropperLoops[tycoonId][upgradeId] do
			local profile = PlayerProfile.getProfile(player)
			if not profile or profile.TycoonId ~= tycoonId or not profile.PurchasedUpgrades[upgradeId] then
				break
			end

			spawnMoneyCrate(player, tycoonId, upgradeId)
			task.wait(GameConfig.DROPPERS[upgradeId].interval)
		end

		if dropperLoops[tycoonId] then
			dropperLoops[tycoonId][upgradeId] = nil
		end
	end)
end

local function restoreOwnedDroppers(player: Player)
	local profile = PlayerProfile.getProfile(player)
	if not profile or not profile.TycoonId then
		return
	end

	for upgradeId in GameConfig.DROPPERS do
		if profile.PurchasedUpgrades[upgradeId] then
			startDropperLoop(player, profile.TycoonId, upgradeId)
		end
	end
end

local function purchaseUpgrade(player: Player, upgradeId: string)
	local profile = PlayerProfile.getProfile(player)
	local upgrade = GameConfig.getUpgrade(upgradeId)
	if not profile or not profile.TycoonId or not upgrade then
		return
	end

	if profile.PurchasedUpgrades[upgradeId] then
		sendUiMessage(player, "Already Purchased", string.format("%s is already unlocked.", upgrade.name), "warning")
		return
	end

	if not GameConfig.areRequirementsMet(profile.PurchasedUpgrades, upgradeId) then
		sendUiMessage(player, "Locked Upgrade", string.format("%s requires earlier upgrades first.", upgrade.name), "warning")
		return
	end

	if not PlayerProfile.trySpendCash(player, upgrade.cost) then
		sendUiMessage(player, "Not Enough Cash", string.format("%s costs $%d.", upgrade.name, upgrade.cost), "warning")
		return
	end

	PlayerProfile.markUpgradePurchased(player, upgradeId)
	refreshTycoonForPlayer(player)

	if GameConfig.DROPPERS[upgradeId] then
		startDropperLoop(player, profile.TycoonId, upgradeId)
	end

	sendUiMessage(player, "Upgrade Purchased", string.format("Unlocked %s.", upgrade.name), "success")
end

local function connectTycoonEvents()
	for tycoonId, tycoon in TycoonService.getTycoons() do
		tycoon.ClaimPrompt.Triggered:Connect(function(player)
			local profile = PlayerProfile.getProfile(player)
			if not profile then
				return
			end

			if profile.TycoonId then
				sendUiMessage(player, "Tycoon Locked", "You already own a tycoon in this server.", "warning")
				return
			end

			if TycoonService.claimTycoon(player, tycoonId) then
				PlayerProfile.setTycoonId(player, tycoonId)
				refreshTycoonForPlayer(player)
				restoreOwnedDroppers(player)
				sendUiMessage(
					player,
					"Tycoon Claimed",
					string.format("%s is now yours. Buy the Basic Dropper first.", tycoonId),
					"success"
				)
			else
				sendUiMessage(player, "Claim Failed", "That tycoon is already taken.", "warning")
			end
		end)

		tycoon.CollectorPrompt.Triggered:Connect(function(player)
			local profile = PlayerProfile.getProfile(player)
			if not profile then
				return
			end

			if profile.TycoonId ~= tycoonId then
				sendUiMessage(player, "Access Denied", "You cannot collect from another player's tycoon.", "warning")
				return
			end

			local collected = PlayerProfile.collectStoredCash(player)
			local bonus = if profile.PurchasedUpgrades.collector then math.floor(collected * 0.1) else 0
			if bonus > 0 then
				PlayerProfile.addWalletCash(player, bonus)
			end

			refreshTycoonForPlayer(player)
			if collected <= 0 then
				sendUiMessage(player, "Collector Empty", "Wait for more money blocks to reach the collector.", "info")
			else
				local total = collected + bonus
				sendUiMessage(player, "Cash Collected", string.format("Claimed $%d from the collector pad.", total), "success")
			end
		end)

		for upgradeId, buttonState in tycoon.ButtonStates do
			buttonState.prompt.Triggered:Connect(function(player)
				local profile = PlayerProfile.getProfile(player)
				if not profile then
					return
				end

				if profile.TycoonId ~= tycoonId then
					sendUiMessage(player, "Access Denied", "You cannot buy upgrades in another player's tycoon.", "warning")
					return
				end

				purchaseUpgrade(player, upgradeId)
			end)
		end

		resetTycoonState(tycoonId)
	end
end

TycoonService.initialize()
connectTycoonEvents()

if RunService:IsStudio() then
	SelfTestService.run()
end

requestStateFunction.OnServerInvoke = function(player)
	return getStatePayload(player)
end

Players.PlayerAdded:Connect(function(player)
	PlayerProfile.createProfile(player)
	updateLeaderstats(player)
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
	local profile = PlayerProfile.getProfile(player)
	local tycoonId = profile and profile.TycoonId or nil

	if tycoonId then
		local releasedId = TycoonService.releaseTycoon(player)
		if releasedId then
			resetTycoonState(releasedId)
		end
	end

	PlayerProfile.clearTycoonId(player)
	PlayerProfile.removeProfile(player)
	broadcastAllStates()
end)

print("Week 2 tycoon economy bootstrapped")
