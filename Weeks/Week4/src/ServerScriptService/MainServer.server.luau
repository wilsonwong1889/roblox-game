local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
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

local sprintRemote = remotesFolder:FindFirstChild("SprintStateChanged") or Instance.new("RemoteEvent")
sprintRemote.Name = "SprintStateChanged"
sprintRemote.Parent = remotesFolder

local dropperLoops: { [string]: { [string]: boolean } } = {}
local starterClickerCooldowns: { [number]: number } = {}
local sprintStates: { [number]: boolean } = {}
local week3DoorRuntime: { [string]: {
	prompts: { ProximityPrompt },
	isOpen: boolean,
	openToken: number,
} } = {}

local function syncPlayerCollisionGroup(player: Player)
	local character = player.Character
	if not character then
		return
	end

	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = "Default"
		end
	end
end

local function applyMovementSpeed(player: Player)
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 10)
	if humanoid then
		humanoid.WalkSpeed = GameConfig.getWalkSpeed(player, sprintStates[player.UserId] == true)
	end
end

local function getWeek3DoorRuntime(tycoonId: string)
	local runtime = week3DoorRuntime[tycoonId]
	if runtime then
		return runtime
	end

	runtime = {
		prompts = {},
		isOpen = false,
		openToken = 0,
	}
	week3DoorRuntime[tycoonId] = runtime
	return runtime
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

	for _, prompt in runtime.prompts do
		prompt.ActionText = if isOpen then "Close Door" else "Open Door"
		prompt.ObjectText = "Owner Door Button"
		prompt.Enabled = tycoon.Owner ~= nil and unlocked
	end

	if not tycoon.DoorPanel then
		return
	end

	if isOpen then
		tycoon.DoorPanel.Transparency = 0.25
		tycoon.DoorPanel.Material = Enum.Material.Neon
		tycoon.DoorPanel.Color = if purchased.reinforced_door then Color3.fromRGB(255, 178, 79) else tycoon.Accent
		tycoon.DoorPanel.CanCollide = false
		tycoon.DoorPanel.CanTouch = false
		tycoon.DoorPanel.CanQuery = false
		tycoon.DoorSensor.Color = Color3.fromRGB(98, 245, 182)
		tycoon.DoorInnerSensor.Color = Color3.fromRGB(98, 245, 182)
	else
		tycoon.DoorPanel.Transparency = 0
		if purchased.reinforced_door then
			tycoon.DoorPanel.Color = Color3.fromRGB(255, 178, 79)
			tycoon.DoorPanel.Material = Enum.Material.DiamondPlate
			tycoon.DoorSensor.Color = Color3.fromRGB(255, 178, 79)
			tycoon.DoorInnerSensor.Color = Color3.fromRGB(255, 178, 79)
		else
			tycoon.DoorPanel.Color = Color3.fromRGB(162, 171, 192)
			tycoon.DoorPanel.Material = Enum.Material.Metal
			tycoon.DoorSensor.Color = tycoon.Accent
			tycoon.DoorInnerSensor.Color = tycoon.Accent
		end
		tycoon.DoorPanel.CanCollide = true
		tycoon.DoorPanel.CanTouch = true
		tycoon.DoorPanel.CanQuery = true
	end
end

local function syncWeek3DoorState(tycoonId: string)
	local tycoon = TycoonService.getTycoon(tycoonId)
	if not tycoon then
		return
	end

	local runtime = getWeek3DoorRuntime(tycoonId)
	if tycoon.DoorPanel then
		tycoon.DoorPanel.CollisionGroup = "Default"
	end
	local profile = tycoon.Owner and PlayerProfile.getProfile(tycoon.Owner) or nil
	local purchased = profile and profile.PurchasedUpgrades or {}
	local unlocked = hasWeek3DoorUpgrade(profile)

	runtime.prompts = {}
	for _, doorButton in { tycoon.DoorSensor, tycoon.DoorInnerSensor } do
		local prompt = doorButton:FindFirstChildOfClass("ProximityPrompt")
		if not prompt then
			prompt = Instance.new("ProximityPrompt")
			prompt.Parent = doorButton
		end

		prompt.ActionText = if runtime.isOpen then "Close Door" else "Open Door"
		prompt.ObjectText = "Owner Door Button"
		prompt.RequiresLineOfSight = false
		prompt.MaxActivationDistance = GameConfig.BUTTON_PROMPT_RANGE
		prompt.HoldDuration = 0
		prompt.Enabled = tycoon.Owner ~= nil and unlocked
		table.insert(runtime.prompts, prompt)
	end
	setTycoonDoorPresentation(tycoonId, runtime.isOpen)
end

local function toggleWeek3Door(tycoonId: string)
	local tycoon = TycoonService.getTycoon(tycoonId)
	if not tycoon then
		return
	end

	local runtime = getWeek3DoorRuntime(tycoonId)
	setTycoonDoorPresentation(tycoonId, not runtime.isOpen)
end

local function sendUiMessage(player: Player, title: string, body: string, tone: string?)
	messageRemote:FireClient(player, {
		title = title,
		body = body,
		tone = tone or "info",
	})
end

local function ensureBackgroundMusic()
	if not GameConfig.BACKGROUND_MUSIC_ENABLED then
		local existing = SoundService:FindFirstChild(GameConfig.BACKGROUND_MUSIC_NAME)
		if existing and existing:IsA("Sound") then
			existing:Stop()
		end
		return
	end

	local music = SoundService:FindFirstChild(GameConfig.BACKGROUND_MUSIC_NAME)
	if not music or not music:IsA("Sound") then
		if music then
			music:Destroy()
		end

		music = Instance.new("Sound")
		music.Name = GameConfig.BACKGROUND_MUSIC_NAME
		music.Parent = SoundService
	end

	music.SoundId = GameConfig.BACKGROUND_MUSIC_SOUND_ID
	music.Looped = true
	music.Volume = GameConfig.BACKGROUND_MUSIC_VOLUME
	music.RollOffMode = Enum.RollOffMode.InverseTapered

	if not music.IsPlaying then
		task.defer(function()
			pcall(function()
				music:Play()
			end)
		end)
	end
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

	local conveyorDuration = GameConfig.getConveyorTravelTime(profile.PurchasedUpgrades)
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

	local payoutValue = GameConfig.getDropperPayoutValue(upgradeId, profile.PurchasedUpgrades)
	if not profile or profile.TycoonId ~= tycoonId then
		moneyPart:Destroy()
		return
	end

	if profile.PurchasedUpgrades.auto_collector then
		PlayerProfile.addWalletCash(player, payoutValue)
	else
		PlayerProfile.addCollectorStored(player, payoutValue)
	end
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

	for _, upgradeId in GameConfig.DROPPER_ORDER do
		if profile.PurchasedUpgrades[upgradeId] then
			startDropperLoop(player, profile.TycoonId, upgradeId)
		end
	end
end

local function applyDeveloperFullBuild(player: Player)
	local profile = PlayerProfile.getProfile(player)
	if not profile or not profile.TycoonId then
		return
	end

	for _, upgradeId in GameConfig.UPGRADE_ORDER do
		PlayerProfile.markUpgradePurchased(player, upgradeId)
	end

	PlayerProfile.collectStoredCash(player)
	refreshTycoonForPlayer(player)
	restoreOwnedDroppers(player)
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

	if upgradeId == "auto_collector" and not PlayerProfile.hasAllDroppers(player) then
		sendUiMessage(player, "Locked Upgrade", "Unlock all eight droppers before buying Auto Collector.", "warning")
		return
	end

	if not PlayerProfile.trySpendCash(player, upgrade.cost) then
		sendUiMessage(player, "Not Enough Cash", string.format("%s costs $%d.", upgrade.name, upgrade.cost), "warning")
		return
	end

	if upgradeId == "developer_full_build" then
		applyDeveloperFullBuild(player)
		sendUiMessage(player, "Developer Build", "Built the full tycoon progression chain.", "success")
		return
	end

	PlayerProfile.markUpgradePurchased(player, upgradeId)

	if upgradeId == "auto_collector" then
		PlayerProfile.collectStoredCash(player)
	end

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
					string.format("%s is now yours. Use the starter clicker, then buy Basic Dropper.", tycoonId),
					"success"
				)
			else
				sendUiMessage(player, "Claim Failed", "That tycoon is already taken.", "warning")
			end
		end)

		tycoon.StarterClickerPrompt.Triggered:Connect(function(player)
			local profile = PlayerProfile.getProfile(player)
			if not profile or profile.TycoonId ~= tycoonId then
				sendUiMessage(player, "Access Denied", "Only the owner can use the starter clicker.", "warning")
				return
			end

			local now = os.clock()
			local nextAllowed = starterClickerCooldowns[player.UserId] or 0
			if now < nextAllowed then
				return
			end

			starterClickerCooldowns[player.UserId] = now + 0.75
			spawnMoneyCrate(player, tycoonId, "basic_dropper")
		end)

		for _, doorButton in { tycoon.DoorSensor, tycoon.DoorInnerSensor } do
			local doorPrompt = doorButton:FindFirstChildOfClass("ProximityPrompt")
			if not doorPrompt then
				doorPrompt = Instance.new("ProximityPrompt")
				doorPrompt.Parent = doorButton
			end

			doorPrompt.Triggered:Connect(function(player)
				local profile = PlayerProfile.getProfile(player)
				if not profile or profile.TycoonId ~= tycoonId then
					sendUiMessage(player, "Access Denied", "Only the owner can use this door button.", "warning")
					return
				end

				if not canPlayerUseWeek3Door(profile, tycoonId) then
					sendUiMessage(player, "Locked Door", "Buy Front Door before using the door button.", "warning")
					return
				end

				toggleWeek3Door(tycoonId)
			end)
		end

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
ensureBackgroundMusic()
connectTycoonEvents()

requestStateFunction.OnServerInvoke = function(player)
	return getStatePayload(player)
end

local function handleCharacterAdded(player: Player)
	syncPlayerCollisionGroup(player)
	applyMovementSpeed(player)

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
	applyMovementSpeed(player)
end

local function setupPlayer(player: Player)
	if PlayerProfile.getProfile(player) then
		return
	end

	PlayerProfile.createProfile(player)
	sprintStates[player.UserId] = false
	updateLeaderstats(player)
	sendStateUpdate(player)

	player.CharacterAdded:Connect(function()
		handleCharacterAdded(player)
	end)

	if player.Character then
		task.defer(function()
			handleCharacterAdded(player)
		end)
	end
end

Players.PlayerAdded:Connect(setupPlayer)

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
	starterClickerCooldowns[player.UserId] = nil
	sprintStates[player.UserId] = nil
	broadcastAllStates()
end)

sprintRemote.OnServerEvent:Connect(function(player, sprinting)
	if type(sprinting) ~= "boolean" then
		return
	end

	sprintStates[player.UserId] = sprinting
	applyMovementSpeed(player)
end)

for _, player in Players:GetPlayers() do
	setupPlayer(player)
end

if RunService:IsStudio() then
	local ok, err = pcall(function()
		SelfTestService.run()
	end)
	if not ok then
		warn("[SelfTest] Week 4 self-test failed: " .. tostring(err))
	end
end

print("Week 4 tycoon server logic bootstrapped")
