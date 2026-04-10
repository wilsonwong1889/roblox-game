local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)
local TycoonService = require(script.Parent.TycoonService)

local EventService = {}

type EventCallbacks = {
	announce: ((Player?, string, string, string?) -> ())?,
	stateChanged: (() -> ())?,
}

local callbacks: EventCallbacks = {}
local initialized = false
local rotationTaskStarted = false

local liveEventFolder: Folder? = nil
local zombieFolder: Folder? = nil
local joinPad: BasePart? = nil
local joinLabel: TextLabel? = nil
local joinPrompt: ProximityPrompt? = nil
local statusBoard: BasePart? = nil
local statusLabel: TextLabel? = nil
local arenaFolder: Folder? = nil
local arenaSpawns: { BasePart } = {}
local hubOrigin = Vector3.zero

local currentMode = "pvp"
local roundEndsAt = 0
local rotationIndex = 1
local joinedPlayers: { [number]: boolean } = {}
local zombieGeneration = 0

local function fireStateChanged()
	if callbacks.stateChanged then
		callbacks.stateChanged()
	end
end

local function announce(targetPlayer: Player?, title: string, body: string, tone: string?)
	if callbacks.announce then
		callbacks.announce(targetPlayer, title, body, tone)
	end
end

local function clearFolder(folder: Folder)
	for _, child in folder:GetChildren() do
		child:Destroy()
	end
end

local function createPart(parent: Instance, name: string, size: Vector3, cframe: CFrame, properties: { [string]: any }?): BasePart
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent

	if properties then
		for key, value in properties do
			(part :: any)[key] = value
		end
	end

	return part
end

local function ensureFolder(parent: Instance, name: string): Folder
	local existing = parent:FindFirstChild(name)
	if existing and existing:IsA("Folder") then
		return existing
	end

	if existing then
		existing:Destroy()
	end

	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function createSurfaceLabel(parent: BasePart, name: string, text: string, face: Enum.NormalId, color: Color3): TextLabel
	local gui = Instance.new("SurfaceGui")
	gui.Name = name .. "Gui"
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 26
	gui.AlwaysOnTop = true
	gui.Parent = parent

	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextWrapped = true
	label.TextColor3 = color
	label.Text = text
	label.Parent = gui

	return label
end

local function ensurePrompt(parent: BasePart, actionText: string, objectText: string): ProximityPrompt
	local prompt = parent:FindFirstChildOfClass("ProximityPrompt")
	if not prompt then
		prompt = Instance.new("ProximityPrompt")
		prompt.Parent = parent
	end

	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = GameConfig.CLAIM_PROMPT_RANGE
	prompt.HoldDuration = 0

	return prompt
end

local function formatDuration(totalSeconds: number): string
	local safe = math.max(0, math.floor(totalSeconds + 0.5))
	local minutes = math.floor(safe / 60)
	local seconds = safe % 60
	return string.format("%02d:%02d", minutes, seconds)
end

function EventService.getNextMode(mode: string): string
	local modes = GameConfig.LIVE_EVENT_MODES
	local currentIndex = 1
	for index, configuredMode in modes do
		if configuredMode == mode then
			currentIndex = index
			break
		end
	end

	local nextIndex = (currentIndex % #modes) + 1
	return modes[nextIndex]
end

function EventService.getModeTitle(mode: string): string
	if mode == "zombie" then
		return "Zombie Siege"
	end

	return "PvP Arena"
end

local function getTimeRemaining(): number
	return math.max(0, math.ceil(roundEndsAt - os.clock()))
end

local function countJoinedPlayers(): number
	local count = 0
	for userId in joinedPlayers do
		local player = Players:GetPlayerByUserId(userId)
		if player then
			count += 1
		else
			joinedPlayers[userId] = nil
		end
	end
	return count
end

local function getLobbySpawnCFrame(): CFrame
	local lobbyFolder = TycoonService.getLobbyFolder()
	if not lobbyFolder then
		return CFrame.new(hubOrigin + Vector3.new(0, 3, 0))
	end

	local spawnLocation = lobbyFolder:FindFirstChild("SpawnLocation")
	if spawnLocation and spawnLocation:IsA("SpawnLocation") then
		return spawnLocation.CFrame + Vector3.new(0, 3, 0)
	end

	return CFrame.new(hubOrigin + Vector3.new(0, 3, 0))
end

local function teleportPlayer(player: Player, targetCFrame: CFrame)
	local character = player.Character
	if not character then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
	if root and root:IsA("BasePart") then
		character:PivotTo(targetCFrame)
	end
end

local function teleportPlayerHome(player: Player)
	local tycoon = TycoonService.getPlayerTycoon(player)
	if tycoon then
		tycoon:teleportToSpawn(player)
		return
	end

	teleportPlayer(player, getLobbySpawnCFrame())
end

local function getArenaSpawnCFrame(player: Player): CFrame
	if #arenaSpawns == 0 then
		return CFrame.new(hubOrigin + Vector3.new(0, 4, 0))
	end

	local index = ((player.UserId % #arenaSpawns) + 1)
	return arenaSpawns[index].CFrame + Vector3.new(0, 3, 0)
end

local function teleportPlayerToArena(player: Player)
	teleportPlayer(player, getArenaSpawnCFrame(player))
end

local function isAttackableWallPart(part: BasePart?): boolean
	if not part then
		return false
	end

	if not part:IsDescendantOf(Workspace) then
		return false
	end

	if part.Transparency >= 0.98 then
		return false
	end

	return part.CanCollide or part.CanQuery or part.CanTouch
end

local function countActiveZombies(): number
	if not zombieFolder then
		return 0
	end

	local count = 0
	for _, child in zombieFolder:GetChildren() do
		if child:IsA("Model") and child:GetAttribute("ZombieAlive") == true then
			count += 1
		end
	end

	return count
end

local function updateWorldUi()
	if not statusLabel or not joinPad or not joinPrompt or not joinLabel then
		return
	end

	local nextMode = EventService.getNextMode(currentMode)
	local secondsRemaining = getTimeRemaining()
	if currentMode == "pvp" then
		joinPad.Color = Color3.fromRGB(106, 255, 185)
		joinPad.Material = Enum.Material.Neon
		joinPrompt.Enabled = true
		joinPrompt.ActionText = "Join Arena"
		joinPrompt.ObjectText = "PvP Event"
		joinLabel.Text = "JOIN\nPVP"
		statusLabel.Text = string.format(
			"Week 7 Event Rotation\nPvP Arena\n%s left\nJoined: %d\nNext: %s",
			formatDuration(secondsRemaining),
			countJoinedPlayers(),
			EventService.getModeTitle(nextMode)
		)
	else
		joinPad.Color = Color3.fromRGB(255, 140, 125)
		joinPad.Material = Enum.Material.SmoothPlastic
		joinPrompt.Enabled = false
		joinPrompt.ActionText = "PvP Closed"
		joinPrompt.ObjectText = "PvP Event"
		joinLabel.Text = "PVP\nSOON"
		statusLabel.Text = string.format(
			"Week 7 Event Rotation\nZombie Siege\n%s left\nZombies: %d\nNext: %s",
			formatDuration(secondsRemaining),
			countActiveZombies(),
			EventService.getModeTitle(nextMode)
		)
	end
end

local function damageWall(part: BasePart, amount: number)
	TycoonService.damageWallPart(part, amount)

	local spark = Instance.new("Part")
	spark.Name = "ZombieWallHit"
	spark.Size = Vector3.new(1.1, 1.1, 1.1)
	spark.Shape = Enum.PartType.Ball
	spark.Material = Enum.Material.Neon
	spark.Color = Color3.fromRGB(126, 255, 145)
	spark.Anchored = true
	spark.CanCollide = false
	spark.CanTouch = false
	spark.CanQuery = false
	spark.CFrame = CFrame.new(part.Position + Vector3.new(0, 2, 0))
	spark.Parent = Workspace
	Debris:AddItem(spark, 0.15)
end

local function buildZombieModel(parent: Instance, name: string, position: Vector3, tycoonId: string): Model
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	model:SetAttribute("NpcRole", "Zombie")
	model:SetAttribute("TargetTycoonId", tycoonId)
	model:SetAttribute("NextAttackAt", 0)
	model:SetAttribute("ZombieAlive", true)

	local function makeBodyPart(partName: string, size: Vector3, offset: Vector3, color: Color3, material: Enum.Material, transparency: number?, canCollide: boolean?): BasePart
		local part = createPart(model, partName, size, CFrame.new(position + offset), {
			Color = color,
			Material = material,
			Transparency = transparency or 0,
			CanCollide = if canCollide == nil then true else canCollide,
		})
		part.Anchored = false
		part.Massless = partName ~= "HumanoidRootPart"
		return part
	end

	local root = makeBodyPart("HumanoidRootPart", Vector3.new(2, 2, 1), Vector3.new(0, 3, 0), Color3.fromRGB(82, 136, 76), Enum.Material.SmoothPlastic, 1, false)
	root.CanTouch = false
	root.CanQuery = false
	local torso = makeBodyPart("Torso", Vector3.new(2.2, 2.4, 1.4), Vector3.new(0, 3, 0), Color3.fromRGB(74, 148, 66), Enum.Material.Fabric, nil, true)
	local head = makeBodyPart("Head", Vector3.new(2, 1, 1), Vector3.new(0, 4.7, 0), Color3.fromRGB(104, 171, 89), Enum.Material.SmoothPlastic, nil, false)
	local leftArm = makeBodyPart("LeftArm", Vector3.new(1, 2.2, 1), Vector3.new(-1.7, 3, 0), Color3.fromRGB(88, 161, 80), Enum.Material.Fabric, nil, false)
	local rightArm = makeBodyPart("RightArm", Vector3.new(1, 2.2, 1), Vector3.new(1.7, 3, 0), Color3.fromRGB(88, 161, 80), Enum.Material.Fabric, nil, false)
	local leftLeg = makeBodyPart("LeftLeg", Vector3.new(1, 2.4, 1), Vector3.new(-0.55, 1, 0), Color3.fromRGB(58, 88, 56), Enum.Material.Fabric, nil, true)
	local rightLeg = makeBodyPart("RightLeg", Vector3.new(1, 2.4, 1), Vector3.new(0.55, 1, 0), Color3.fromRGB(58, 88, 56), Enum.Material.Fabric, nil, true)

	for _, part in { torso, head, leftArm, rightArm, leftLeg, rightLeg } do
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = root
		weld.Part1 = part
		weld.Parent = root
	end

	local humanoid = Instance.new("Humanoid")
	humanoid.Name = "Humanoid"
	humanoid.DisplayName = "Zombie"
	humanoid.Health = GameConfig.LIVE_EVENT_ZOMBIE_HEALTH
	humanoid.MaxHealth = GameConfig.LIVE_EVENT_ZOMBIE_HEALTH
	humanoid.WalkSpeed = GameConfig.LIVE_EVENT_ZOMBIE_SPEED
	humanoid.AutoRotate = true
	humanoid.Parent = model

	humanoid.Died:Connect(function()
		model:SetAttribute("ZombieAlive", false)
		fireStateChanged()
		Debris:AddItem(model, 4)
	end)

	model.PrimaryPart = root
	task.defer(function()
		pcall(function()
			root:SetNetworkOwner(nil)
		end)
	end)

	return model
end

local function getZombieWallTarget(tycoonId: string, origin: Vector3): BasePart?
	local tycoon = TycoonService.getTycoon(tycoonId)
	if not tycoon then
		return nil
	end

	local bestPart = nil
	local bestDistance = math.huge

	local function consider(part: BasePart?)
		if not isAttackableWallPart(part) then
			return
		end

		local distance = (part.Position - origin).Magnitude
		if distance < bestDistance then
			bestDistance = distance
			bestPart = part
		end
	end

	for _, wallPart in tycoon.LowWallParts do
		consider(wallPart)
	end
	for _, wallPart in tycoon.HighWallParts do
		consider(wallPart)
	end
	consider(tycoon.DoorPanel)

	return bestPart
end

local function getZombiePlayerTarget(tycoonId: string, origin: Vector3): (Humanoid?, BasePart?, number)
	local tycoon = TycoonService.getTycoon(tycoonId)
	if not tycoon or not tycoon.Owner then
		return nil, nil, math.huge
	end

	local character = tycoon.Owner.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
	if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
		return nil, nil, math.huge
	end

	local distance = (root.Position - origin).Magnitude
	if distance > GameConfig.LIVE_EVENT_ZOMBIE_TARGET_RADIUS then
		return nil, nil, math.huge
	end

	return humanoid, root, distance
end

local function getZombieSpawnPositions(tycoon): { Vector3 }
	local baseCFrame = tycoon.BaseCFrame or CFrame.new(tycoon.Origin)
	local offsets = {
		Vector3.new(-72, 4, -96),
		Vector3.new(72, 4, -96),
		Vector3.new(-74, 4, -10),
		Vector3.new(74, 4, -10),
		Vector3.new(-72, 4, 86),
		Vector3.new(72, 4, 86),
	}

	local positions = {}
	for _, offset in offsets do
		table.insert(positions, (baseCFrame * CFrame.new(offset)).Position)
	end

	return positions
end

local function runZombieLoop(generation: number, zombieModel: Model)
	local humanoid = zombieModel:FindFirstChildOfClass("Humanoid")
	local root = zombieModel.PrimaryPart
	local targetTycoonId = zombieModel:GetAttribute("TargetTycoonId")
	if not humanoid or not root or type(targetTycoonId) ~= "string" then
		return
	end

	while zombieGeneration == generation and currentMode == "zombie" and zombieModel.Parent and humanoid.Health > 0 do
		local playerHumanoid, playerRoot, playerDistance = getZombiePlayerTarget(targetTycoonId, root.Position)
		local wallTarget = getZombieWallTarget(targetTycoonId, root.Position)
		local wallDistance = if wallTarget then (wallTarget.Position - root.Position).Magnitude else math.huge

		local attackPlayer = playerHumanoid ~= nil and playerRoot ~= nil and playerDistance <= wallDistance + 8
		local targetPosition = nil

		if attackPlayer and playerRoot then
			targetPosition = playerRoot.Position
		elseif wallTarget then
			targetPosition = wallTarget.Position
		end

		if not targetPosition then
			task.wait(0.35)
			continue
		end

		local distance = (targetPosition - root.Position).Magnitude
		if distance > GameConfig.LIVE_EVENT_ZOMBIE_ATTACK_RANGE + 1.5 then
			humanoid:MoveTo(targetPosition)
		else
			local now = os.clock()
			local nextAttackAt = zombieModel:GetAttribute("NextAttackAt")
			if type(nextAttackAt) ~= "number" or now >= nextAttackAt then
				zombieModel:SetAttribute("NextAttackAt", now + GameConfig.LIVE_EVENT_ZOMBIE_ATTACK_COOLDOWN)
				if attackPlayer and playerHumanoid then
					playerHumanoid:TakeDamage(GameConfig.LIVE_EVENT_ZOMBIE_PLAYER_DAMAGE)
				elseif wallTarget then
					damageWall(wallTarget, GameConfig.LIVE_EVENT_ZOMBIE_WALL_DAMAGE)
				end
			end
		end

		task.wait(0.3)
	end
end

local function clearJoinedPlayers(teleportHome: boolean)
	for userId in joinedPlayers do
		local player = Players:GetPlayerByUserId(userId)
		if player and teleportHome then
			teleportPlayerHome(player)
		end
	end
	table.clear(joinedPlayers)
end

local function clearZombies()
	zombieGeneration += 1
	if zombieFolder then
		clearFolder(zombieFolder)
	end
end

local function spawnZombieWave()
	if not zombieFolder then
		return
	end

	local generation = zombieGeneration
	for _, tycoon in TycoonService.getTycoons() do
		if tycoon.Owner ~= nil then
			local activeForTycoon = 0
			for _, child in zombieFolder:GetChildren() do
				if child:IsA("Model") and child:GetAttribute("TargetTycoonId") == tycoon.Id and child:GetAttribute("ZombieAlive") == true then
					activeForTycoon += 1
				end
			end

			local positions = getZombieSpawnPositions(tycoon)
			for index = activeForTycoon + 1, GameConfig.LIVE_EVENT_ZOMBIE_COUNT_PER_TYCOON do
				local spawnPosition = positions[((index - 1) % #positions) + 1]
				local zombieModel = buildZombieModel(zombieFolder, string.format("%sZombie%d", tycoon.Id, index), spawnPosition, tycoon.Id)
				task.spawn(runZombieLoop, generation, zombieModel)
			end
		end
	end

	fireStateChanged()
end

local function startPvpRound()
	clearZombies()
	clearJoinedPlayers(false)
	announce(nil, "PvP Arena", "The PvP arena is live for the next 10 minutes. Use the join pad in the center.", "info")
	updateWorldUi()
	fireStateChanged()
end

local function endPvpRound()
	clearJoinedPlayers(true)
	announce(nil, "PvP Arena", "The PvP arena round ended. Returning joined players to their tycoons.", "info")
	updateWorldUi()
	fireStateChanged()
end

local function startZombieRound()
	clearJoinedPlayers(true)
	clearZombies()
	spawnZombieWave()

	local generation = zombieGeneration
	task.spawn(function()
		while currentMode == "zombie" and zombieGeneration == generation do
			task.wait(45)
			if currentMode ~= "zombie" or zombieGeneration ~= generation then
				return
			end
			spawnZombieWave()
			updateWorldUi()
		end
	end)

	announce(nil, "Zombie Siege", "A zombie siege has started. Defend your tycoon and keep your walls standing.", "warning")
	updateWorldUi()
	fireStateChanged()
end

local function endZombieRound()
	clearZombies()
	announce(nil, "Zombie Siege", "The zombie siege is over. The next event will open from the center hub.", "success")
	updateWorldUi()
	fireStateChanged()
end

local function runRotationLoop()
	if rotationTaskStarted or not GameConfig.LIVE_EVENT_ENABLED then
		return
	end

	rotationTaskStarted = true
	currentMode = GameConfig.LIVE_EVENT_MODES[rotationIndex]
	roundEndsAt = os.clock() + GameConfig.LIVE_EVENT_ROTATION_SECONDS

	if currentMode == "pvp" then
		startPvpRound()
	else
		startZombieRound()
	end

	task.spawn(function()
		while true do
			task.wait(1)
			updateWorldUi()
			fireStateChanged()

			if getTimeRemaining() > 0 then
				continue
			end

			if currentMode == "pvp" then
				endPvpRound()
			else
				endZombieRound()
			end

			rotationIndex = (rotationIndex % #GameConfig.LIVE_EVENT_MODES) + 1
			currentMode = GameConfig.LIVE_EVENT_MODES[rotationIndex]
			roundEndsAt = os.clock() + GameConfig.LIVE_EVENT_ROTATION_SECONDS

			if currentMode == "pvp" then
				startPvpRound()
			else
				startZombieRound()
			end
		end
	end)
end

local function buildEventWorld(sharedMapFolder: Folder)
	local plaza = sharedMapFolder:FindFirstChild("CentralPlaza")
	if plaza and plaza:IsA("BasePart") then
		hubOrigin = plaza.Position
	else
		hubOrigin = Vector3.zero
	end

	liveEventFolder = ensureFolder(sharedMapFolder, "LiveEvents")
	clearFolder(liveEventFolder)
	arenaFolder = ensureFolder(liveEventFolder, "Arena")
	zombieFolder = ensureFolder(liveEventFolder, "Zombies")
	clearFolder(arenaFolder)
	clearFolder(zombieFolder)

	local arenaRadius = GameConfig.LIVE_EVENT_ARENA_RADIUS
	createPart(arenaFolder, "ArenaFloor", Vector3.new(arenaRadius * 2, 1, arenaRadius * 2), CFrame.new(hubOrigin + Vector3.new(0, 2.2, 0)), {
		Color = Color3.fromRGB(52, 60, 76),
		Material = Enum.Material.Asphalt,
	})
	createPart(arenaFolder, "ArenaRing", Vector3.new((arenaRadius * 2) + 8, 1, (arenaRadius * 2) + 8), CFrame.new(hubOrigin + Vector3.new(0, 1.7, 0)), {
		Color = Color3.fromRGB(120, 202, 255),
		Material = Enum.Material.Neon,
		Transparency = 0.18,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})

	table.clear(arenaSpawns)
	for index = 1, GameConfig.LIVE_EVENT_PVP_SPAWN_COUNT do
		local angle = ((index - 1) / GameConfig.LIVE_EVENT_PVP_SPAWN_COUNT) * math.pi * 2
		local position = hubOrigin + Vector3.new(math.cos(angle) * (arenaRadius - 10), 2.7, math.sin(angle) * (arenaRadius - 10))
		local spawnPad = createPart(arenaFolder, "ArenaSpawn" .. index, Vector3.new(8, 1, 8), CFrame.new(position), {
			Color = Color3.fromRGB(173, 206, 255),
			Material = Enum.Material.SmoothPlastic,
			CanCollide = false,
		})
		table.insert(arenaSpawns, spawnPad)
	end

	joinPad = createPart(liveEventFolder, "PvpJoinPad", Vector3.new(16, 1, 16), CFrame.new(hubOrigin + GameConfig.LIVE_EVENT_PVP_JOIN_PAD_OFFSET), {
		Color = Color3.fromRGB(106, 255, 185),
		Material = Enum.Material.Neon,
	})
	joinLabel = createSurfaceLabel(joinPad, "JoinLabel", "JOIN\nPVP", Enum.NormalId.Top, Color3.fromRGB(18, 34, 28))
	joinPrompt = ensurePrompt(joinPad, "Join Arena", "PvP Event")

	statusBoard = createPart(liveEventFolder, "EventStatusBoard", Vector3.new(24, 16, 1), CFrame.new(hubOrigin + GameConfig.LIVE_EVENT_STATUS_BOARD_OFFSET), {
		Color = Color3.fromRGB(25, 30, 39),
		Material = Enum.Material.SmoothPlastic,
	})
	statusLabel = createSurfaceLabel(statusBoard, "StatusLabel", "Week 7 Event Rotation", Enum.NormalId.Front, Color3.fromRGB(238, 245, 255))

	joinPrompt.Triggered:Connect(function(player)
		if currentMode ~= "pvp" then
			announce(player, "PvP Closed", "The join pad only works during the PvP arena round.", "info")
			return
		end

		if joinedPlayers[player.UserId] == true then
			announce(player, "PvP Joined", "You are already queued in the PvP arena.", "info")
			return
		end

		joinedPlayers[player.UserId] = true
		teleportPlayerToArena(player)
		announce(player, "PvP Joined", "You joined the PvP arena round.", "success")
		updateWorldUi()
		fireStateChanged()
	end)

	updateWorldUi()
end

function EventService.initialize(newCallbacks: EventCallbacks?)
	if initialized then
		return
	end

	initialized = true
	callbacks = newCallbacks or {}

	if not GameConfig.LIVE_EVENT_ENABLED then
		return
	end

	local sharedMapFolder = TycoonService.getSharedMapFolder()
	if not sharedMapFolder then
		warn("[EventService] SharedMap folder missing; live event rotation disabled.")
		return
	end

	buildEventWorld(sharedMapFolder)
	runRotationLoop()
end

function EventService.handlePlayerRemoving(player: Player)
	joinedPlayers[player.UserId] = nil
	fireStateChanged()
end

function EventService.handleCharacterAdded(player: Player)
	if currentMode == "pvp" and joinedPlayers[player.UserId] == true then
		task.defer(function()
			task.wait(0.2)
			teleportPlayerToArena(player)
		end)
	end
end

function EventService.getPublicState(player: Player?): { [string]: any }
	local mode = currentMode
	local nextMode = EventService.getNextMode(mode)
	return {
		enabled = GameConfig.LIVE_EVENT_ENABLED,
		mode = mode,
		title = EventService.getModeTitle(mode),
		description = if mode == "pvp"
			then "Join the center arena pad and fight other players for the round."
			else "Zombies are attacking claimed tycoons. Hold the line and defend your walls.",
		timeRemainingSeconds = getTimeRemaining(),
		joinEnabled = mode == "pvp",
		joined = if player then joinedPlayers[player.UserId] == true else false,
		joinedCount = countJoinedPlayers(),
		zombieCount = countActiveZombies(),
		nextMode = nextMode,
		nextModeTitle = EventService.getModeTitle(nextMode),
		rotationSeconds = GameConfig.LIVE_EVENT_ROTATION_SECONDS,
	}
end

return EventService
