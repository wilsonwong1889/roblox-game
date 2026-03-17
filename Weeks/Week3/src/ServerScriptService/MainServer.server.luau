local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")
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
local week3DoorRuntime: { [string]: {
	prompt: ProximityPrompt?,
	isOpen: boolean,
	openToken: number,
	ownerCollisionGroup: string,
	doorCollisionGroup: string,
} } = {}

local function ensureCollisionGroup(groupName: string)
	pcall(function()
		if PhysicsService.RegisterCollisionGroup then
			PhysicsService:RegisterCollisionGroup(groupName)
		else
			PhysicsService:CreateCollisionGroup(groupName)
		end
	end)
end

local function safeSetCollisionGroupCollidable(groupA: string, groupB: string, collidable: boolean)
	pcall(function()
		PhysicsService:CollisionGroupSetCollidable(groupA, groupB, collidable)
	end)
end

local function setCharacterCollisionGroup(character: Model, groupName: string)
	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = groupName
		end
	end
end

local function getWeek3CollisionGroups(tycoonId: string): (string, string)
	return "Week3Owner_" .. tycoonId, "Week3Door_" .. tycoonId
end

local function syncPlayerCollisionGroup(player: Player)
	local profile = PlayerProfile.getProfile(player)
	local character = player.Character
	if not profile or not character then
		return
	end

	local groupName = "Default"
	if profile.TycoonId then
		groupName = (getWeek3CollisionGroups(profile.TycoonId))
	end

	setCharacterCollisionGroup(character, groupName)
end

local function getWeek3DoorRuntime(tycoonId: string)
	local runtime = week3DoorRuntime[tycoonId]
	if runtime then
		return runtime
	end

	local ownerCollisionGroup, doorCollisionGroup = getWeek3CollisionGroups(tycoonId)
	runtime = {
		prompt = nil,
		isOpen = false,
		openToken = 0,
		ownerCollisionGroup = ownerCollisionGroup,
		doorCollisionGroup = doorCollisionGroup,
	}
	week3DoorRuntime[tycoonId] = runtime
	return runtime
end

local function applyWeek3DoorCollisionRules(tycoonId: string)
	local runtime = getWeek3DoorRuntime(tycoonId)
	ensureCollisionGroup(runtime.ownerCollisionGroup)
	ensureCollisionGroup(runtime.doorCollisionGroup)
	safeSetCollisionGroupCollidable(runtime.ownerCollisionGroup, runtime.doorCollisionGroup, false)
	safeSetCollisionGroupCollidable(runtime.doorCollisionGroup, runtime.ownerCollisionGroup, false)
	safeSetCollisionGroupCollidable(runtime.ownerCollisionGroup, "Default", true)
	safeSetCollisionGroupCollidable(runtime.doorCollisionGroup, "Default", true)
end

local function hasWeek3DoorUpgrade(profile): boolean
	return profile ~= nil and (profile.PurchasedUpgrades.front_door == true or profile.PurchasedUpgrades.reinforced_door == true)
end

local function canPlayerUseWeek3Door(profile, tycoonId: string): boolean
	return profile ~= nil and profile.TycoonId == tycoonId and hasWeek3DoorUpgrade(profile)
end

local function setTycoonDoorPresentation(tycoonId: string, isOpen: boolean)
	local tycoon = TycoonService.getTycoon(tycoonId)
	if not tycoon then
		return
	end

	local runtime = getWeek3DoorRuntime(tycoonId)
	runtime.isOpen = isOpen

	local profile = tycoon.Owner and PlayerProfile.getProfile(tycoon.Owner) or nil
	local purchased = profile and profile.PurchasedUpgrades or {}
	local unlocked = hasWeek3DoorUpgrade(profile)

	if runtime.prompt then
		runtime.prompt.ActionText = if isOpen then "Close Door" else "Open Door"
		runtime.prompt.ObjectText = if purchased.reinforced_door then "Reinforced Door" else "Front Door"
		runtime.prompt.Enabled = tycoon.Owner ~= nil and unlocked
	end

	if isOpen then
		tycoon.DoorPanel.Transparency = 0.25
		tycoon.DoorPanel.Material = Enum.Material.Neon
		tycoon.DoorPanel.Color = if purchased.reinforced_door then Color3.fromRGB(255, 178, 79) else tycoon.Accent
	else
		tycoon.DoorPanel.Transparency = 0
		if purchased.reinforced_door then
			tycoon.DoorPanel.Color = Color3.fromRGB(255, 178, 79)
			tycoon.DoorPanel.Material = Enum.Material.DiamondPlate
		else
			tycoon.DoorPanel.Color = Color3.fromRGB(162, 171, 192)
			tycoon.DoorPanel.Material = Enum.Material.Metal
		end
	end
end

local function syncWeek3DoorState(tycoonId: string)
	local tycoon = TycoonService.getTycoon(tycoonId)
	if not tycoon then
		return
	end

	local runtime = getWeek3DoorRuntime(tycoonId)
	applyWeek3DoorCollisionRules(tycoonId)
	tycoon.DoorPanel.CollisionGroup = runtime.doorCollisionGroup
	local profile = tycoon.Owner and PlayerProfile.getProfile(tycoon.Owner) or nil
	local purchased = profile and profile.PurchasedUpgrades or {}
	local unlocked = hasWeek3DoorUpgrade(profile)

	local prompt = tycoon.DoorSensor:FindFirstChildOfClass("ProximityPrompt")
	if not prompt then
		prompt = Instance.new("ProximityPrompt")
		prompt.Parent = tycoon.DoorSensor
	end

	prompt.ActionText = if runtime.isOpen then "Close Door" else "Open Door"
	prompt.ObjectText = if purchased.reinforced_door then "Reinforced Door" else "Front Door"
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = GameConfig.BUTTON_PROMPT_RANGE
	prompt.HoldDuration = 0
	prompt.Enabled = tycoon.Owner ~= nil and unlocked

	runtime.prompt = prompt
	setTycoonDoorPresentation(tycoonId, runtime.isOpen)
end

local function toggleWeek3Door(tycoonId: string)
	local tycoon = TycoonService.getTycoon(tycoonId)
	if not tycoon then
		return
	end

	local runtime = getWeek3DoorRuntime(tycoonId)
	runtime.openToken += 1
	local currentToken = runtime.openToken
	setTycoonDoorPresentation(tycoonId, true)

	task.delay(1.2, function()
		if runtime.openToken ~= currentToken then
			return
		end

		setTycoonDoorPresentation(tycoonId, false)
	end)
end

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
				earningsPerSecond = PlayerProfile.getEarningsPerSecond(player),
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
	local payload = PlayerProfile.getStatePayload(player)
	if not payload then
		return nil
	end

	payload.competition = competitionSnapshot or getCompetitionSnapshot()
	return payload
end

local function getOrCreateLeaderstatsValue(leaderstats: Folder, className: string, name: string): ValueBase
	local existing = leaderstats:FindFirstChild(name)
	if existing and existing.ClassName == className then
		return existing :: ValueBase
	end

	if existing then
		existing:Destroy()
	end

	local valueObject = Instance.new(className)
	valueObject.Name = name
	valueObject.Parent = leaderstats
	return valueObject
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
	end

	local cash = getOrCreateLeaderstatsValue(leaderstats, "IntValue", "Cash") :: IntValue
	local stored = getOrCreateLeaderstatsValue(leaderstats, "IntValue", "Stored") :: IntValue
	local earned = getOrCreateLeaderstatsValue(leaderstats, "IntValue", "Earned") :: IntValue
	local upgrades = getOrCreateLeaderstatsValue(leaderstats, "IntValue", "Upgrades") :: IntValue
	local eps = getOrCreateLeaderstatsValue(leaderstats, "NumberValue", "EPS") :: NumberValue

	cash.Value = profile.WalletCash
	stored.Value = profile.CollectorStoredCash
	earned.Value = profile.TotalEarned
	upgrades.Value = PlayerProfile.getUpgradeCount(player)
	eps.Value = PlayerProfile.getEarningsPerSecond(player)
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
	syncWeek3DoorState(profile.TycoonId)
	syncPlayerCollisionGroup(player)
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
	local runtime = getWeek3DoorRuntime(tycoonId)
	runtime.isOpen = false
	runtime.openToken += 1
	syncWeek3DoorState(tycoonId)
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

	if upgrade.category == "structure" then
		sendUiMessage(player, "Structure Upgraded", string.format("Unlocked %s.", upgrade.name), "success")
		return
	end

	sendUiMessage(player, "Upgrade Purchased", string.format("Unlocked %s.", upgrade.name), "success")
end

local function connectTycoonEvents()
	for tycoonId, tycoon in TycoonService.getTycoons() do
		syncWeek3DoorState(tycoonId)

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
				syncPlayerCollisionGroup(player)
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

		local doorPrompt = tycoon.DoorSensor:FindFirstChildOfClass("ProximityPrompt")
		if not doorPrompt then
			doorPrompt = Instance.new("ProximityPrompt")
			doorPrompt.Parent = tycoon.DoorSensor
		end

		local runtime = getWeek3DoorRuntime(tycoonId)
		runtime.prompt = doorPrompt
		doorPrompt.Triggered:Connect(function(player)
			local profile = PlayerProfile.getProfile(player)
			if not profile or profile.TycoonId ~= tycoonId then
				sendUiMessage(player, "Access Denied", "Only the owner can open this front door.", "warning")
				return
			end

			if not canPlayerUseWeek3Door(profile, tycoonId) then
				sendUiMessage(player, "Locked Door", "Buy Front Door before using the entrance.", "warning")
				return
			end

			toggleWeek3Door(tycoonId)
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
		syncPlayerCollisionGroup(player)

		local profile = PlayerProfile.getProfile(player)
		if not profile or not profile.TycoonId then
			local character = player.Character
			if character then
				character.DescendantAdded:Connect(function(descendant)
					if descendant:IsA("BasePart") then
						syncPlayerCollisionGroup(player)
					end
				end)
			end
			return
		end

		local character = player.Character
		if not character then
			return
		end

		character.DescendantAdded:Connect(function(descendant)
			if descendant:IsA("BasePart") then
				syncPlayerCollisionGroup(player)
			end
		end)

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
	syncPlayerCollisionGroup(player)
	PlayerProfile.removeProfile(player)
	broadcastAllStates()
end)

print("Week 3 tycoon server logic bootstrapped")
