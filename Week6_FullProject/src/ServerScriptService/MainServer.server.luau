local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)
local PlayerProfile = require(ReplicatedStorage.Modules.PlayerProfile)
local SecondFloorConfig = require(ReplicatedStorage.Modules.SecondFloorConfig)
local ThirdFloorConfig = require(ReplicatedStorage.Modules.ThirdFloorConfig)
local RaidService = require(script.Parent.Services.RaidService)
local RebirthService = require(script.Parent.Services.RebirthService)
local SaveService = require(script.Parent.Services.SaveService)
local SelfTestService = require(script.Parent.Services.SelfTestService)
local TycoonService = require(script.Parent.Services.TycoonService)
local WeaponService = require(script.Parent.Services.WeaponService)

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

local dailySpinFunction = remotesFolder:FindFirstChild("RequestDailySpin") or Instance.new("RemoteFunction")
dailySpinFunction.Name = "RequestDailySpin"
dailySpinFunction.Parent = remotesFolder

local redeemCodeFunction = remotesFolder:FindFirstChild("RequestCodeRedeem") or Instance.new("RemoteFunction")
redeemCodeFunction.Name = "RequestCodeRedeem"
redeemCodeFunction.Parent = remotesFolder

local rebirthFunction = remotesFolder:FindFirstChild("RequestRebirth") or Instance.new("RemoteFunction")
rebirthFunction.Name = "RequestRebirth"
rebirthFunction.Parent = remotesFolder

local promptVipPurchaseRemote = remotesFolder:FindFirstChild("PromptVipStarterPackPurchase") or Instance.new("RemoteEvent")
promptVipPurchaseRemote.Name = "PromptVipStarterPackPurchase"
promptVipPurchaseRemote.Parent = remotesFolder

local sprintRemote = remotesFolder:FindFirstChild("SprintStateChanged") or Instance.new("RemoteEvent")
sprintRemote.Name = "SprintStateChanged"
sprintRemote.Parent = remotesFolder

local dropperLoops: { [string]: { [string]: boolean } } = {}
local starterClickerCooldowns: { [number]: number } = {}
local sprintStates: { [number]: boolean } = {}
local playerPersistenceState: { [number]: {
	loadState: string,
	lastSaveAt: number?,
	lastSaveOk: boolean?,
} } = {}
local raidSessions: { [string]: any } = {}
local raidWindowTokens: { [string]: number } = {}
local week3DoorRuntime: { [string]: {
	prompts: { ProximityPrompt },
	isOpen: boolean,
	openToken: number,
} } = {}

local updateLeaderstats
local sendStateUpdate
local broadcastAllStates

local function getAllUpgradeIds(): { string }
	return table.clone(GameConfig.UPGRADE_ORDER)
end

local function getUpgradeDefinition(upgradeId: string)
	return GameConfig.getUpgrade(upgradeId)
end

local function areUpgradeRequirementsMet(purchased: { [string]: boolean }, upgradeId: string): boolean
	return GameConfig.areRequirementsMet(purchased, upgradeId)
end

local function getDropperConfig(upgradeId: string)
	return GameConfig.getConfiguredDropper(upgradeId)
end

local function getAllAutomatedDropperIds(): { string }
	return GameConfig.getAllDropperIds()
end

local function getDropperPayoutValue(upgradeId: string, purchased: { [string]: boolean }): number
	return GameConfig.getDropperPayoutValue(upgradeId, purchased)
end

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

local function playerHasVipBenefits(player: Player): boolean
	return GameConfig.hasVipStatus(player) or PlayerProfile.hasVipStatus(player)
end

local function playerHasAdminBenefits(player: Player): boolean
	return GameConfig.hasAdminStatus(player)
end

local function applyMovementSpeed(player: Player)
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 10)
	if humanoid then
		humanoid.WalkSpeed = GameConfig.getWalkSpeed(
			player,
			sprintStates[player.UserId] == true,
			playerHasVipBenefits(player),
			playerHasAdminBenefits(player)
		)
	end
end

local function applyCharacterHealth(player: Player)
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 10)
	if humanoid then
		local maxHealth = GameConfig.getMaxHealth(
			player,
			playerHasVipBenefits(player),
			playerHasAdminBenefits(player)
		)
		humanoid.MaxHealth = maxHealth
		humanoid.Health = maxHealth
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

local function getTycoonBaseCFrame(tycoon)
	return tycoon.BaseCFrame or (CFrame.new(tycoon.Origin) * CFrame.Angles(0, math.rad(tycoon.FacingYaw or 0), 0))
end

local function getDoorPanelClosedCFrame(tycoon)
	return getTycoonBaseCFrame(tycoon) * CFrame.new(GameConfig.TYCOON_ENTRY_PANEL_OFFSET)
end

local function getDoorPanelOpenCFrame(tycoon)
	return getTycoonBaseCFrame(tycoon) * CFrame.new(GameConfig.TYCOON_ENTRY_PANEL_OFFSET + GameConfig.TYCOON_ENTRY_PANEL_OPEN_OFFSET)
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
		tycoon.DoorPanel.CFrame = getDoorPanelOpenCFrame(tycoon)
		tycoon.DoorPanel.Transparency = 0.25
		tycoon.DoorPanel.Material = Enum.Material.Neon
		tycoon.DoorPanel.Color = if purchased.reinforced_door then Color3.fromRGB(255, 178, 79) else tycoon.Accent
		tycoon.DoorPanel.CanCollide = false
		tycoon.DoorPanel.CanTouch = false
		tycoon.DoorPanel.CanQuery = false
		tycoon.DoorSensor.Color = Color3.fromRGB(98, 245, 182)
		tycoon.DoorInnerSensor.Color = Color3.fromRGB(98, 245, 182)
	else
		tycoon.DoorPanel.CFrame = getDoorPanelClosedCFrame(tycoon)
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

local function getUtcDayKey(): string
	local now = os.date("!*t")
	return string.format("%04d-%03d", now.year, now.yday)
end

local function getPersistenceEntry(userId: number)
	local entry = playerPersistenceState[userId]
	if entry then
		return entry
	end

	entry = {
		loadState = if GameConfig.SAVE_ENABLED then "pending" else "disabled",
		lastSaveAt = nil,
		lastSaveOk = nil,
	}
	playerPersistenceState[userId] = entry
	return entry
end

local function canUseDataStoreRuntime(): boolean
	if not GameConfig.SAVE_ENABLED then
		return false
	end

	if RunService:IsStudio() and not GameConfig.SAVE_IN_STUDIO then
		return false
	end

	return true
end

local function savePlayerProfile(player: Player, reason: string?): boolean
	if not canUseDataStoreRuntime() then
		return false
	end

	local exportData = PlayerProfile.exportSaveData(player)
	if not exportData then
		return false
	end

	local ok, err = SaveService.saveProfileAsync(exportData)
	local persistenceEntry = getPersistenceEntry(player.UserId)
	persistenceEntry.lastSaveAt = os.time()
	persistenceEntry.lastSaveOk = ok

	if not ok then
		warn(string.format("[SaveService] Failed to save %s (%s): %s", player.Name, reason or "unknown", tostring(err)))
	end

	return ok
end

local function getPlayerEarningsPerSecond(player: Player): number
	local base = PlayerProfile.getEarningsPerSecond(player)
	if not GameConfig.REBIRTH_ENABLED then
		return base
	end

	local total = base * RebirthService.getCurrentRewardMultiplier(PlayerProfile.getRebirthCount(player))
	return math.floor(total * 10 + 0.5) / 10
end

local function ownsVipStarterPack(player: Player): boolean
	if not GameConfig.VIP_STARTER_PACK.ENABLED then
		return false
	end

	local success, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, GameConfig.VIP_STARTER_PACK.GAMEPASS_ID)
	end)

	if not success then
		warn(string.format("[VipStarterPack] Failed to check ownership for %s: %s", player.Name, tostring(result)))
		return false
	end

	return result == true
end

local function grantVipStarterPackIfNeeded(player: Player, reason: string?)
	if not GameConfig.VIP_STARTER_PACK.ENABLED then
		return
	end

	local profile = PlayerProfile.getProfile(player)
	if not profile then
		return
	end

	local ownsPack = ownsVipStarterPack(player)
	PlayerProfile.setVipStarterPackOwned(player, ownsPack)

	if not ownsPack or PlayerProfile.hasReceivedVipStarterPack(player) then
		return
	end

	PlayerProfile.addWalletCash(player, GameConfig.VIP_STARTER_PACK.CASH_BONUS)
	PlayerProfile.markVipStarterPackGranted(player)
	updateLeaderstats(player)
	sendStateUpdate(player)
	sendUiMessage(
		player,
		GameConfig.VIP_STARTER_PACK.NAME,
		string.format(
			"Added $%d to your wallet%s.",
			GameConfig.VIP_STARTER_PACK.CASH_BONUS,
			reason and (" (" .. reason .. ")") or ""
		),
		"success"
	)
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
	local claimedPlots = 0

	for _, player in Players:GetPlayers() do
		local profile = PlayerProfile.getProfile(player)
		if profile then
			if profile.TycoonId then
				claimedPlots += 1
			end

			table.insert(standings, {
				name = player.DisplayName,
				tycoonId = profile.TycoonId,
				totalEarned = profile.TotalEarned,
				walletCash = profile.WalletCash,
				earningsPerSecond = getPlayerEarningsPerSecond(player),
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

	return {
		standings = standings,
		tycoonCapacity = #GameConfig.TYCOONS,
		claimedPlots = claimedPlots,
		availablePlots = math.max(0, #GameConfig.TYCOONS - claimedPlots),
		playerCount = #Players:GetPlayers(),
	}
end

local function buildRebirthState(profile)
	if not GameConfig.REBIRTH_ENABLED or not profile then
		return nil
	end

	local plan = RebirthService.getResetPlan({
		tycoonId = profile.TycoonId,
		totalEarned = profile.TotalEarned,
		rebirthCount = profile.RebirthCount,
		purchasedUpgrades = profile.PurchasedUpgrades,
	})

	return {
		enabled = true,
		count = profile.RebirthCount,
		canRebirth = plan.canRebirth,
		requiredTotalEarned = plan.requiredTotalEarned,
		progressScore = plan.progressScore,
		progressLabel = plan.progressLabel,
		payoutMultiplier = plan.payoutMultiplier,
		cashMultiplier = plan.cashMultiplier,
		nextStarterCash = plan.unlocks.newStarterCash,
	}
end

local function ensureRaidSession(tycoonId: string)
	local existing = raidSessions[tycoonId]
	if existing then
		return existing
	end

	local tycoon = TycoonService.getTycoon(tycoonId)
	local ownerUserId = tycoon and tycoon.Owner and tycoon.Owner.UserId or nil
	local ownerProfile = tycoon and tycoon.Owner and PlayerProfile.getProfile(tycoon.Owner) or nil
	local theftCap = RaidService.computeTheftCap(
		ownerProfile and ownerProfile.CollectorStoredCash or 0,
		GameConfig.RAID_THEFT_CAP_MULTIPLIER
	)
	local session = RaidService.createSession(tycoonId, ownerUserId, os.time(), theftCap)
	session.door.maxBreaches = GameConfig.RAID_MAX_BREACHES
	session.door.breachCooldownSeconds = GameConfig.RAID_BREACH_COOLDOWN_SECONDS
	session.theft.maxPerPull = GameConfig.RAID_MAX_THEFT_PER_PULL
	raidSessions[tycoonId] = session
	return session
end

local function setRaidWindowState(tycoonId: string, isOpen: boolean)
	local tycoon = TycoonService.getTycoon(tycoonId)
	if not tycoon then
		return
	end

	local session = ensureRaidSession(tycoonId)
	local summary = RaidService.summarizeSession(session, os.time())
	local text = if isOpen
		then string.format("Raid Open\n%ds left\nLoot $%d", summary.windowRemainingSeconds, summary.theftRemaining)
		else "Raid Closed\nOwner controlled"
	tycoon:updateRaidDisplay(isOpen, text, summary.windowOpen and not summary.doorBreached, summary.doorBreached)
end

local function resetRaidSession(tycoonId: string)
	local tycoon = TycoonService.getTycoon(tycoonId)
	local ownerUserId = tycoon and tycoon.Owner and tycoon.Owner.UserId or nil
	local ownerProfile = tycoon and tycoon.Owner and PlayerProfile.getProfile(tycoon.Owner) or nil
	local theftCap = RaidService.computeTheftCap(
		ownerProfile and ownerProfile.CollectorStoredCash or 0,
		GameConfig.RAID_THEFT_CAP_MULTIPLIER
	)
	local session = RaidService.createSession(tycoonId, ownerUserId, os.time(), theftCap)
	session.door.maxBreaches = GameConfig.RAID_MAX_BREACHES
	session.door.breachCooldownSeconds = GameConfig.RAID_BREACH_COOLDOWN_SECONDS
	session.theft.maxPerPull = GameConfig.RAID_MAX_THEFT_PER_PULL
	raidSessions[tycoonId] = session
	raidWindowTokens[tycoonId] = (raidWindowTokens[tycoonId] or 0) + 1
	setRaidWindowState(tycoonId, false)
end

local function buildRaidState(profile)
	if not GameConfig.RAID_ENABLED or not profile or not profile.TycoonId then
		return {
			enabled = GameConfig.RAID_ENABLED,
		}
	end

	local session = ensureRaidSession(profile.TycoonId)
	local summary = RaidService.summarizeSession(session, os.time())
	return {
		enabled = true,
		tycoonId = profile.TycoonId,
		windowOpen = summary.windowOpen,
		windowRemainingSeconds = summary.windowRemainingSeconds,
		doorLocked = summary.doorLocked,
		doorBreached = summary.doorBreached,
		theftRemaining = summary.theftRemaining,
	}
end

local function getStatePayload(player: Player, competitionSnapshot)
	local payload = PlayerProfile.getStatePayload(player)
	if not payload then
		return nil
	end

	local profile = PlayerProfile.getProfile(player)
	local persistenceEntry = getPersistenceEntry(player.UserId)
	local earningsPerSecond = getPlayerEarningsPerSecond(player)
	payload.competition = competitionSnapshot or getCompetitionSnapshot()
	payload.rebirth = buildRebirthState(profile)
	payload.raid = buildRaidState(profile)
	payload.shopOffers = GameConfig.getShopOffers()
	payload.earningsPerSecond = earningsPerSecond
	payload.earningsPerSecondText = string.format("$%.1f/sec", earningsPerSecond)
	payload.persistence = {
		enabled = canUseDataStoreRuntime(),
		loadState = persistenceEntry.loadState,
		lastSaveAt = persistenceEntry.lastSaveAt,
		lastSaveOk = persistenceEntry.lastSaveOk,
	}
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

updateLeaderstats = function(player: Player)
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
	local kills = getOrCreateLeaderstatsValue(leaderstats, "IntValue", "Kills") :: IntValue
	local coins = getOrCreateLeaderstatsValue(leaderstats, "IntValue", "Coins") :: IntValue
	local freeSpins = getOrCreateLeaderstatsValue(leaderstats, "IntValue", "Spins") :: IntValue
	local upgrades = getOrCreateLeaderstatsValue(leaderstats, "IntValue", "Upgrades") :: IntValue
	local eps = getOrCreateLeaderstatsValue(leaderstats, "NumberValue", "EPS") :: NumberValue

	cash.Value = profile.WalletCash
	stored.Value = profile.CollectorStoredCash
	earned.Value = profile.TotalEarned
	kills.Value = PlayerProfile.getKills(player)
	coins.Value = PlayerProfile.getCoins(player)
	freeSpins.Value = PlayerProfile.getFreeSpins(player)
	upgrades.Value = PlayerProfile.getUpgradeCount(player)
	eps.Value = getPlayerEarningsPerSecond(player)
end

sendStateUpdate = function(player: Player)
	local payload = getStatePayload(player)
	if payload then
		stateRemote:FireClient(player, payload)
	end
end

broadcastAllStates = function()
	local competitionSnapshot = getCompetitionSnapshot()
	TycoonService.updateCompetitionBoard(competitionSnapshot)
	for _, player in Players:GetPlayers() do
		local payload = getStatePayload(player, competitionSnapshot)
		if payload then
			stateRemote:FireClient(player, payload)
		end
	end
end

WeaponService.KillAwarded.Event:Connect(function(player, victimModel)
	local victimPlayer = nil
	if typeof(victimModel) == "Instance" and victimModel:IsA("Model") then
		victimPlayer = Players:GetPlayerFromCharacter(victimModel)
	end

	local coinReward = if victimPlayer then GameConfig.PLAYER_KILL_COIN_REWARD else GameConfig.NPC_KILL_COIN_REWARD
	local _, _, grantedSpins = PlayerProfile.addCoins(player, coinReward)
	updateLeaderstats(player)
	sendStateUpdate(player)
	broadcastAllStates()

	local rewardMessage = string.format(
		"Kills: %d | +%d coin%s",
		PlayerProfile.getKills(player),
		coinReward,
		if coinReward == 1 then "" else "s"
	)
	if grantedSpins > 0 then
		rewardMessage = rewardMessage .. string.format(
			" | +%d free spin%s",
			grantedSpins,
			if grantedSpins == 1 then "" else "s"
		)
	end
	sendUiMessage(player, "Kill Confirmed", rewardMessage, "success")
end)

local function syncVerticalButtons(tycoon, purchased: { [string]: boolean })
	local verticalOrder = {}
	for _, upgradeId in GameConfig.SECOND_FLOOR_UPGRADE_ORDER do
		table.insert(verticalOrder, upgradeId)
	end
	for _, upgradeId in GameConfig.THIRD_FLOOR_UPGRADE_ORDER do
		table.insert(verticalOrder, upgradeId)
	end

	for _, upgradeId in verticalOrder do
		local buttonState = tycoon.ButtonStates[upgradeId]
		local upgrade = getUpgradeDefinition(upgradeId)
		if buttonState and upgrade then
			local isPurchased = purchased[upgradeId] == true
			local canBuy = tycoon.Owner ~= nil and not isPurchased and areUpgradeRequirementsMet(purchased, upgradeId)

			buttonState.prompt.Enabled = canBuy
			buttonState.part.Transparency = if canBuy then 0 else 1
			buttonState.part.CanCollide = canBuy
			buttonState.part.CanTouch = canBuy
			buttonState.part.CanQuery = canBuy
			buttonState.label.Visible = canBuy
			buttonState.prompt.ActionText = string.format("Buy $%d", upgrade.cost)
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
	local tycoon = TycoonService.getTycoon(profile.TycoonId)
	if tycoon then
		syncVerticalButtons(tycoon, profile.PurchasedUpgrades)
		tycoon.EarningsLabel.Text = string.format("Earnings\n$%.1f/sec", getPlayerEarningsPerSecond(player))
	end
	syncWeek3DoorState(profile.TycoonId)
	setRaidWindowState(profile.TycoonId, ensureRaidSession(profile.TycoonId).window.open)
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
	TycoonService.resetWallHealth(tycoonId)
	TycoonService.applyVisualState(tycoonId, {}, 0)
	TycoonService.updateButtons(tycoonId, {})
	syncVerticalButtons(tycoon, {})
	tycoon.EarningsLabel.Text = "Earnings\n$0.0/sec"
	local runtime = getWeek3DoorRuntime(tycoonId)
	runtime.isOpen = false
	runtime.openToken += 1
	syncWeek3DoorState(tycoonId)
	resetRaidSession(tycoonId)
end

local function getPlayerPayoutMultiplier(player: Player): number
	if not GameConfig.REBIRTH_ENABLED then
		return 1
	end

	return RebirthService.getCurrentRewardMultiplier(PlayerProfile.getRebirthCount(player))
end

local function spawnMoneyCrate(player: Player, tycoonId: string, upgradeId: string, spawnOverrideCFrame: CFrame?)
	local tycoon = TycoonService.getTycoon(tycoonId)
	local profile = PlayerProfile.getProfile(player)
	local dropperConfig = getDropperConfig(upgradeId)
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
	moneyPart.CFrame = spawnOverrideCFrame or outputPoint.CFrame
	moneyPart.Parent = tycoon.MoneyPartsFolder

	local entryCFrame = tycoon.ConveyorEntry.CFrame
	local collectorCFrame = tycoon.CollectorPoint.CFrame
	if GameConfig.isUpperFloorUpgrade(upgradeId) then
		local baseCFrame = getTycoonBaseCFrame(tycoon)
		entryCFrame = CFrame.new(SecondFloorConfig.getUpperConveyorEntryOrigin(baseCFrame))
		collectorCFrame = CFrame.new(SecondFloorConfig.getUpperCollectorPointOrigin(baseCFrame))
	elseif GameConfig.isThirdFloorUpgrade(upgradeId) then
		local baseCFrame = getTycoonBaseCFrame(tycoon)
		entryCFrame = CFrame.new(ThirdFloorConfig.getConveyorEntryOrigin(baseCFrame))
		collectorCFrame = CFrame.new(ThirdFloorConfig.getCollectorPointOrigin(baseCFrame))
	end

	local fallTween = TweenService:Create(
		moneyPart,
		TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ CFrame = entryCFrame }
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
		{ CFrame = collectorCFrame }
	)
	beltTween:Play()
	beltTween.Completed:Wait()

	if not moneyPart.Parent then
		return
	end

	local payoutValue = math.floor((getDropperPayoutValue(upgradeId, profile.PurchasedUpgrades) * getPlayerPayoutMultiplier(player)) + 0.5)
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
			local dropperConfig = getDropperConfig(upgradeId)
			if not dropperConfig then
				break
			end
			task.wait(dropperConfig.interval)
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

	for _, upgradeId in getAllAutomatedDropperIds() do
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

	for _, upgradeId in getAllUpgradeIds() do
		PlayerProfile.markUpgradePurchased(player, upgradeId)
	end

	PlayerProfile.collectStoredCash(player)
	refreshTycoonForPlayer(player)
	restoreOwnedDroppers(player)
	WeaponService.grantOwnedWeapons(player, PlayerProfile.getProfile(player).PurchasedUpgrades)
end

local function purchaseUpgrade(player: Player, upgradeId: string)
	local profile = PlayerProfile.getProfile(player)
	local upgrade = getUpgradeDefinition(upgradeId)
	if not profile or not profile.TycoonId or not upgrade then
		return
	end

	if profile.PurchasedUpgrades[upgradeId] then
		sendUiMessage(player, "Already Purchased", string.format("%s is already unlocked.", upgrade.name), "warning")
		return
	end

	if not areUpgradeRequirementsMet(profile.PurchasedUpgrades, upgradeId) then
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

	if getDropperConfig(upgradeId) then
		startDropperLoop(player, profile.TycoonId, upgradeId)
	end

	if WeaponService.isWeaponUpgrade(upgradeId) then
		WeaponService.grantUpgradeTool(player, upgradeId)
		sendUiMessage(player, "Weapon Unlocked", string.format("%s has been added to your backpack.", upgrade.name), "success")
		return
	end

	if upgrade.category == "structure" then
		sendUiMessage(player, "Structure Upgraded", string.format("Unlocked %s.", upgrade.name), "success")
		return
	end

	sendUiMessage(player, "Upgrade Purchased", string.format("Unlocked %s.", upgrade.name), "success")
end

local function closeRaidWindow(tycoonId: string, reason: string?)
	local session = ensureRaidSession(tycoonId)
	session.window = RaidService.closeWindow(session.window)
	session.door = RaidService.createDoorBreachState(tycoonId)
	session.door.maxBreaches = GameConfig.RAID_MAX_BREACHES
	session.door.breachCooldownSeconds = GameConfig.RAID_BREACH_COOLDOWN_SECONDS
	setTycoonDoorPresentation(tycoonId, false)
	setRaidWindowState(tycoonId, false)

	local tycoon = TycoonService.getTycoon(tycoonId)
	if tycoon and tycoon.Owner and reason then
		sendUiMessage(tycoon.Owner, "Raid Closed", reason, "info")
	end
	broadcastAllStates()
end

local function openRaidWindow(player: Player, tycoonId: string)
	if not GameConfig.RAID_ENABLED then
		sendUiMessage(player, "Raid Disabled", "Raid windows are disabled in this build.", "warning")
		return
	end

	local profile = PlayerProfile.getProfile(player)
	if not profile or profile.TycoonId ~= tycoonId then
		sendUiMessage(player, "Access Denied", "Only the owner can control the raid window.", "warning")
		return
	end

	local session = ensureRaidSession(tycoonId)
	local now = os.time()
	if session.window.open then
		raidWindowTokens[tycoonId] = (raidWindowTokens[tycoonId] or 0) + 1
		closeRaidWindow(tycoonId, "You closed the raid window.")
		return
	end

	local validation = RaidService.validateAntiGriefAction(session, player.UserId, "open_window", now)
	if not validation.allowed then
		sendUiMessage(player, "Raid Locked", validation.reason or "Raid window could not be opened.", "warning")
		return
	end

	session.theft = RaidService.createTheftLedger(
		RaidService.computeTheftCap(profile.CollectorStoredCash, GameConfig.RAID_THEFT_CAP_MULTIPLIER),
		GameConfig.RAID_MAX_THEFT_PER_PULL
	)
	session.window, _ = RaidService.openWindow(session.window, now, GameConfig.RAID_WINDOW_SECONDS)
	session.door = RaidService.createDoorBreachState(tycoonId)
	session.door.maxBreaches = GameConfig.RAID_MAX_BREACHES
	session.door.breachCooldownSeconds = GameConfig.RAID_BREACH_COOLDOWN_SECONDS

	local token = (raidWindowTokens[tycoonId] or 0) + 1
	raidWindowTokens[tycoonId] = token
	setRaidWindowState(tycoonId, true)
	sendUiMessage(
		player,
		"Raid Open",
		string.format("Raid window opened for %d seconds. Theft cap: $%d.", GameConfig.RAID_WINDOW_SECONDS, session.theft.cap),
		"success"
	)
	broadcastAllStates()

	task.delay(GameConfig.RAID_WINDOW_SECONDS, function()
		if raidWindowTokens[tycoonId] ~= token then
			return
		end
		closeRaidWindow(tycoonId, "The raid timer expired.")
	end)
end

local function breachRaidDoor(player: Player, tycoonId: string)
	local tycoon = TycoonService.getTycoon(tycoonId)
	local session = ensureRaidSession(tycoonId)
	local validation = RaidService.validateAntiGriefAction(session, player.UserId, "breach_door", os.time())
	if not validation.allowed then
		sendUiMessage(player, "Breach Failed", validation.reason or "The raid door cannot be breached right now.", "warning")
		return
	end

	session.door, validation = RaidService.recordBreachAttempt(session.door, player.UserId, os.time())
	if not validation.allowed then
		sendUiMessage(player, "Breach Failed", validation.reason or "The raid door cannot be breached right now.", "warning")
		return
	end

	setTycoonDoorPresentation(tycoonId, true)
	setRaidWindowState(tycoonId, true)
	sendUiMessage(player, "Door Breached", "The raid door is open. Reach the collector before the window closes.", "success")
	if tycoon and tycoon.Owner then
		sendUiMessage(tycoon.Owner, "Door Breached", string.format("%s breached your raid door.", player.DisplayName), "warning")
	end
	broadcastAllStates()
end

local function tryRaidSteal(player: Player, tycoonId: string): boolean
	local tycoon = TycoonService.getTycoon(tycoonId)
	if not tycoon or not tycoon.Owner then
		sendUiMessage(player, "Raid Failed", "This tycoon has no active owner to raid.", "warning")
		return false
	end

	local owner = tycoon.Owner
	local ownerProfile = PlayerProfile.getProfile(owner)
	local session = ensureRaidSession(tycoonId)
	local validation = RaidService.validateAntiGriefAction(session, player.UserId, "steal_cash", os.time())
	if not validation.allowed then
		sendUiMessage(player, "Raid Failed", validation.reason or "You cannot steal cash right now.", "warning")
		return false
	end

	if not ownerProfile or ownerProfile.CollectorStoredCash <= 0 then
		sendUiMessage(player, "No Cash To Steal", "The target collector is empty.", "info")
		return false
	end

	local stolenAmount
	session.theft, stolenAmount = RaidService.recordTheft(session.theft, ownerProfile.CollectorStoredCash)
	if stolenAmount <= 0 then
		sendUiMessage(player, "Raid Cap Reached", "This raid cannot steal any more cash.", "info")
		return false
	end

	PlayerProfile.setCollectorStored(owner, ownerProfile.CollectorStoredCash - stolenAmount)
	PlayerProfile.addWalletCash(player, stolenAmount)
	refreshTycoonForPlayer(owner)
	refreshTycoonForPlayer(player)
	setRaidWindowState(tycoonId, true)
	sendUiMessage(player, "Cash Stolen", string.format("You stole $%d from %s.", stolenAmount, owner.DisplayName), "success")
	sendUiMessage(owner, "Cash Stolen", string.format("%s stole $%d from your collector.", player.DisplayName, stolenAmount), "warning")
	return true
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
				resetRaidSession(tycoonId)
				syncPlayerCollisionGroup(player)
				refreshTycoonForPlayer(player)
				restoreOwnedDroppers(player)
				sendUiMessage(
					player,
					"Tycoon Claimed",
					string.format("%s is now yours. Use the starter dropper, then buy Basic Dropper.", tycoonId),
					"success"
				)
			else
				sendUiMessage(player, "Claim Failed", "That tycoon is already taken.", "warning")
			end
		end)

		tycoon.StarterClickerPrompt.Triggered:Connect(function(player)
			local profile = PlayerProfile.getProfile(player)
			if not profile or profile.TycoonId ~= tycoonId then
				sendUiMessage(player, "Access Denied", "Only the owner can use the starter dropper.", "warning")
				return
			end

			local now = os.clock()
			local nextAllowed = starterClickerCooldowns[player.UserId] or 0
			if now < nextAllowed then
				return
			end

			starterClickerCooldowns[player.UserId] = now + 0.75
			local starterDropCFrame = tycoon.StarterClickerOutput.CFrame
			spawnMoneyCrate(player, tycoonId, "basic_dropper", starterDropCFrame)
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
				tryRaidSteal(player, tycoonId)
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

		tycoon.RepairPrompt.Triggered:Connect(function(player)
			local profile = PlayerProfile.getProfile(player)
			if not profile or profile.TycoonId ~= tycoonId then
				sendUiMessage(player, "Access Denied", "Only the owner can rebuild these walls.", "warning")
				return
			end

			local repairCost = TycoonService.getWallRepairCost(tycoonId)
			if repairCost <= 0 then
				sendUiMessage(player, "Walls Full", "Your walls are already fully rebuilt.", "info")
				return
			end

			if not PlayerProfile.trySpendCash(player, repairCost) then
				sendUiMessage(player, "Not Enough Cash", string.format("You need $%d to rebuild the walls.", repairCost), "warning")
				return
			end

			local repaired = TycoonService.repairWalls(tycoonId, repairCost)
			refreshTycoonForPlayer(player)
			if repaired > 0 then
				sendUiMessage(player, "Walls Rebuilt", string.format("Spent $%d to restore wall health.", repaired), "success")
			else
				sendUiMessage(player, "Walls Full", "Your walls are already fully rebuilt.", "info")
			end
		end)

		tycoon.RaidPrompt.Triggered:Connect(function(player)
			openRaidWindow(player, tycoonId)
		end)

		tycoon.RaidBreachPrompt.Triggered:Connect(function(player)
			breachRaidDoor(player, tycoonId)
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

local function connectVipStarterPackPrompt()
	if not GameConfig.VIP_STARTER_PACK.ENABLED then
		return
	end

	local lobbyFolder = TycoonService.getLobbyFolder()
	if not lobbyFolder then
		return
	end

	local vipPad = lobbyFolder:FindFirstChild("VipStarterPackPad")
	if not vipPad or not vipPad:IsA("BasePart") then
		return
	end

	local prompt = vipPad:FindFirstChildOfClass("ProximityPrompt")
	if not prompt then
		return
	end

	prompt.Triggered:Connect(function(player)
		if ownsVipStarterPack(player) then
			PlayerProfile.setVipStarterPackOwned(player, true)
			local hadGrant = PlayerProfile.hasReceivedVipStarterPack(player)
			grantVipStarterPackIfNeeded(player, "owned")
			if hadGrant then
				sendUiMessage(player, GameConfig.VIP_STARTER_PACK.NAME, "You already own this pass.", "info")
			end
			return
		end

		local ok, err = pcall(function()
			MarketplaceService:PromptGamePassPurchase(player, GameConfig.VIP_STARTER_PACK.GAMEPASS_ID)
		end)

		if not ok then
			warn(string.format("[VipStarterPack] Failed to prompt purchase for %s: %s", player.Name, tostring(err)))
			sendUiMessage(player, "Purchase Unavailable", "Could not open the VIP starter pack prompt.", "warning")
		end
	end)

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
		if gamePassId ~= GameConfig.VIP_STARTER_PACK.GAMEPASS_ID or not wasPurchased then
			return
		end

		PlayerProfile.setVipStarterPackOwned(player, true)
		grantVipStarterPackIfNeeded(player, "purchase")
	end)
end

TycoonService.initialize()
ensureBackgroundMusic()
connectTycoonEvents()
connectVipStarterPackPrompt()

promptVipPurchaseRemote.OnServerEvent:Connect(function(player)
	if not GameConfig.VIP_STARTER_PACK.ENABLED then
		return
	end

	if ownsVipStarterPack(player) then
		PlayerProfile.setVipStarterPackOwned(player, true)
		grantVipStarterPackIfNeeded(player, "owned")
		sendUiMessage(player, GameConfig.VIP_STARTER_PACK.NAME, "You already own this pass.", "info")
		return
	end

	local ok, err = pcall(function()
		MarketplaceService:PromptGamePassPurchase(player, GameConfig.VIP_STARTER_PACK.GAMEPASS_ID)
	end)
	if not ok then
		warn(string.format("[VipStarterPack] Failed to prompt purchase from UI for %s: %s", player.Name, tostring(err)))
		sendUiMessage(player, "Purchase Unavailable", "Could not open the VIP starter pack prompt.", "warning")
	end
end)

requestStateFunction.OnServerInvoke = function(player)
	return getStatePayload(player)
end

rebirthFunction.OnServerInvoke = function(player)
	if not GameConfig.REBIRTH_ENABLED then
		return {
			ok = false,
			reason = "disabled",
		}
	end

	local profile = PlayerProfile.getProfile(player)
	if not profile then
		return {
			ok = false,
			reason = "missing_profile",
		}
	end

	local plan = RebirthService.getResetPlan({
		tycoonId = profile.TycoonId,
		totalEarned = profile.TotalEarned,
		rebirthCount = profile.RebirthCount,
		purchasedUpgrades = profile.PurchasedUpgrades,
	})
	if not plan.canRebirth then
		return {
			ok = false,
			reason = "locked",
			plan = plan,
		}
	end

	local tycoonId = profile.TycoonId
	PlayerProfile.performRebirth(player, plan.unlocks.newStarterCash)
	WeaponService.grantStarterWeapons(player)
	WeaponService.grantOwnedWeapons(player, PlayerProfile.getProfile(player).PurchasedUpgrades)
	if tycoonId then
		resetTycoonState(tycoonId)
		refreshTycoonForPlayer(player)
	end
	sendUiMessage(
		player,
		"Rebirth Complete",
		string.format("Prestige %d unlocked. Starter cash reset to $%d.", PlayerProfile.getRebirthCount(player), plan.unlocks.newStarterCash),
		"success"
	)
	return {
		ok = true,
		rebirthCount = PlayerProfile.getRebirthCount(player),
		starterCash = plan.unlocks.newStarterCash,
	}
end

dailySpinFunction.OnServerInvoke = function(player)
	if not GameConfig.DAILY_SPIN_ENABLED then
		return {
			ok = false,
			reason = "disabled",
		}
	end

	local profile = PlayerProfile.getProfile(player)
	if not profile then
		return {
			ok = false,
			reason = "missing_profile",
		}
	end

	local dayKey = getUtcDayKey()
	local canUseDailySpin = PlayerProfile.canUseDailySpin(player, dayKey)
	local usedFreeSpin = false

	if not canUseDailySpin then
		if not PlayerProfile.tryUseFreeSpin(player) then
			return {
				ok = false,
				reason = "already_claimed",
				dayKey = dayKey,
				reward = PlayerProfile.getDailySpinLastReward(player),
				freeSpins = PlayerProfile.getFreeSpins(player),
			}
		end
		usedFreeSpin = true
	end

	local reward = GameConfig.rollDailySpinReward()
	if canUseDailySpin then
		PlayerProfile.markDailySpinClaimed(player, dayKey, reward.amount)
	end
	PlayerProfile.addWalletCash(player, reward.amount)
	updateLeaderstats(player)
	sendStateUpdate(player)
	broadcastAllStates()
	sendUiMessage(
		player,
		if usedFreeSpin then "Free Spin" else "Daily Spin",
		string.format("You won %s from the %s.", reward.name, if usedFreeSpin then "free spin" else "daily spin"),
		"success"
	)

	return {
		ok = true,
		reward = reward.amount,
		rewardName = reward.name,
		dayKey = dayKey,
		spinType = if usedFreeSpin then "free" else "daily",
		freeSpins = PlayerProfile.getFreeSpins(player),
	}
end

redeemCodeFunction.OnServerInvoke = function(player, rawCode)
	local profile = PlayerProfile.getProfile(player)
	if not profile then
		return {
			ok = false,
			reason = "missing_profile",
		}
	end

	local rewardDefinition = GameConfig.getRedeemCode(rawCode)
	if not rewardDefinition then
		sendUiMessage(player, "Invalid Code", "That code does not exist.", "warning")
		return {
			ok = false,
			reason = "invalid_code",
		}
	end

	if PlayerProfile.hasRedeemedCode(player, rewardDefinition.code) then
		sendUiMessage(player, "Code Used", "That code can only be redeemed once per game.", "info")
		return {
			ok = false,
			reason = "already_redeemed",
			code = rewardDefinition.code,
		}
	end

	PlayerProfile.markCodeRedeemed(player, rewardDefinition.code)
	if rewardDefinition.grantsVip == true then
		PlayerProfile.setVipStatus(player, true)
		applyCharacterHealth(player)
		applyMovementSpeed(player)
	end
	if (rewardDefinition.reward or 0) > 0 then
		PlayerProfile.addWalletCash(player, rewardDefinition.reward)
	end
	updateLeaderstats(player)
	sendStateUpdate(player)
	broadcastAllStates()

	local rewardText = if rewardDefinition.grantsVip == true
		then "VIP status unlocked for this game."
		else string.format("Redeemed successfully for $%d.", rewardDefinition.reward)
	sendUiMessage(player, "Code Redeemed", rewardText, "success")

	return {
		ok = true,
		code = rewardDefinition.code,
		reward = rewardDefinition.reward,
		vipGranted = rewardDefinition.grantsVip == true,
	}
end

local function handleCharacterAdded(player: Player)
	syncPlayerCollisionGroup(player)
	applyCharacterHealth(player)
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
	WeaponService.grantStarterWeapons(player)
	WeaponService.grantOwnedWeapons(player, profile.PurchasedUpgrades)
	applyCharacterHealth(player)
	applyMovementSpeed(player)
end

local function setupPlayer(player: Player)
	if PlayerProfile.getProfile(player) then
		return
	end

	local persistenceEntry = getPersistenceEntry(player.UserId)
	local loadedData = nil
	if canUseDataStoreRuntime() then
		local ok, record, err = SaveService.loadProfileAsync({
			UserId = player.UserId,
			Name = player.Name,
			DisplayName = player.DisplayName,
		})
		if ok and record then
			loadedData = record
			persistenceEntry.loadState = "loaded"
		else
			persistenceEntry.loadState = "fresh"
			warn(string.format("[SaveService] Failed to load %s: %s", player.Name, tostring(err)))
		end
	else
		persistenceEntry.loadState = if GameConfig.SAVE_ENABLED then "studio_disabled" else "disabled"
	end

	PlayerProfile.createProfile(player, loadedData)
	sprintStates[player.UserId] = false
	grantVipStarterPackIfNeeded(player, "join")
	WeaponService.grantStarterWeapons(player)
	WeaponService.grantOwnedWeapons(player, PlayerProfile.getProfile(player).PurchasedUpgrades)
	updateLeaderstats(player)
	sendStateUpdate(player)
	if persistenceEntry.loadState == "loaded" then
		sendUiMessage(player, "Progress Loaded", "Your saved wallet, upgrades, spins, and rebirths were restored.", "success")
	end

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
	savePlayerProfile(player, "leave")

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
	playerPersistenceState[player.UserId] = nil
	WeaponService.clearPlayerState(player)
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

task.spawn(function()
	while task.wait(GameConfig.AUTOSAVE_INTERVAL_SECONDS) do
		if not canUseDataStoreRuntime() then
			continue
		end

		for _, player in Players:GetPlayers() do
			savePlayerProfile(player, "autosave")
		end
		broadcastAllStates()
	end
end)

game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		savePlayerProfile(player, "shutdown")
	end
end)

if RunService:IsStudio() then
	local ok, err = pcall(function()
		SelfTestService.run()
	end)
	if not ok then
		warn("[SelfTest] Week 6 self-test failed: " .. tostring(err))
	end
end

print("Week 6 tycoon server logic bootstrapped")
