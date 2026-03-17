local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

local Tycoon = {}
Tycoon.__index = Tycoon

export type Definition = {
	Id: string,
	Origin: Vector3,
	Accent: Color3,
}

export type UpgradeButton = {
	part: BasePart,
	label: TextLabel,
	prompt: ProximityPrompt,
	upgradeId: string,
}

export type TycoonObject = {
	Id: string,
	Origin: Vector3,
	Accent: Color3,
	Model: Model,
	Spawn: SpawnLocation,
	ClaimPad: BasePart,
	ClaimPrompt: ProximityPrompt,
	ClaimLabel: TextLabel,
	OwnerSign: BasePart,
	OwnerLabel: TextLabel,
	EarningsBoard: BasePart,
	EarningsLabel: TextLabel,
	ConveyorBase: BasePart,
	ConveyorStrip: BasePart,
	ConveyorEntry: BasePart,
	CollectorMachine: Model,
	CollectorPad: BasePart,
	CollectorPrompt: ProximityPrompt,
	CollectorLabel: TextLabel,
	CollectorPoint: BasePart,
	CollectorTrigger: BasePart,
	RuntimeFolder: Folder,
	MoneyPartsFolder: Folder,
	EconomyFolder: Folder,
	StructuresFolder: Folder,
	ButtonsFolder: Folder,
	StructureSocketsFolder: Folder,
	SpawnPointsFolder: Folder,
	DropperModels: { [string]: Model },
	DropperOutputs: { [string]: BasePart },
	LowWallParts: { BasePart },
	HighWallParts: { BasePart },
	WallSetFolder: Folder,
	DoorFrame: BasePart,
	DoorPanel: BasePart,
	DoorSensor: BasePart,
	ButtonStates: { [string]: UpgradeButton },
	UpgradeButtons: { [string]: UpgradeButton },
	Owner: Player?,
	ValuesFolder: Folder,
	OwnerUserIdValue: IntValue,
	OwnerNameValue: StringValue,
	IsClaimedValue: BoolValue,
	TycoonIdValue: StringValue,
	setOwner: (self: TycoonObject, player: Player?) -> (),
	isOwnedBy: (self: TycoonObject, player: Player) -> boolean,
	updateCollectorDisplay: (self: TycoonObject, amount: number) -> (),
	applyVisualState: (self: TycoonObject, purchased: { [string]: boolean }, collectorStored: number) -> (),
	updateButtons: (self: TycoonObject, purchased: { [string]: boolean }) -> (),
	teleportToSpawn: (self: TycoonObject, player: Player) -> (),
}

local function createFolder(parent: Instance, name: string): Folder
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function ensureFolder(parent: Instance, name: string): Folder
	local existing = parent:FindFirstChild(name)
	if existing and existing:IsA("Folder") then
		return existing
	end

	if existing then
		existing:Destroy()
	end

	return createFolder(parent, name)
end

local function clearFolder(folder: Folder)
	for _, child in folder:GetChildren() do
		child:Destroy()
	end
end

local function destroyChild(parent: Instance, name: string)
	local child = parent:FindFirstChild(name)
	if child then
		child:Destroy()
	end
end

local function applyPartProperties(part: BasePart, properties: { [string]: any }?)
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth

	if properties then
		for key, value in properties do
			(part :: any)[key] = value
		end
	end
end

local function createPart(parent: Instance, name: string, size: Vector3, cframe: CFrame, properties: { [string]: any }?): BasePart
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Parent = parent
	applyPartProperties(part, properties)
	return part
end

local function ensurePart(parent: Instance, name: string, size: Vector3, cframe: CFrame, properties: { [string]: any }?): BasePart
	local existing = parent:FindFirstChild(name)
	if existing and existing:IsA("BasePart") then
		existing.Size = size
		existing.CFrame = cframe
		applyPartProperties(existing, properties)
		return existing
	end

	if existing then
		existing:Destroy()
	end

	return createPart(parent, name, size, cframe, properties)
end

local function createSurfaceLabel(parent: BasePart, text: string, face: Enum.NormalId, textColor: Color3): TextLabel
	local gui = Instance.new("SurfaceGui")
	gui.Name = "LabelGui"
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 28
	gui.AlwaysOnTop = true
	gui.Parent = parent

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = textColor
	label.TextStrokeTransparency = 0.35
	label.Text = text
	label.Parent = gui

	return label
end

local function ensureSurfaceLabel(parent: BasePart, text: string, face: Enum.NormalId, textColor: Color3): TextLabel
	for _, child in parent:GetChildren() do
		if child:IsA("SurfaceGui") then
			local label = child:FindFirstChildWhichIsA("TextLabel")
			if label then
				child.Face = face
				label.TextColor3 = textColor
				label.Text = text
				return label
			end
		end
	end

	return createSurfaceLabel(parent, text, face, textColor)
end

local function ensurePrompt(parent: BasePart, actionText: string, objectText: string, maxDistance: number?): ProximityPrompt
	local prompt = parent:FindFirstChildWhichIsA("ProximityPrompt")
	if not prompt then
		prompt = Instance.new("ProximityPrompt")
		prompt.Parent = parent
	end

	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = maxDistance or GameConfig.BUTTON_PROMPT_RANGE
	prompt.HoldDuration = 0

	return prompt
end

local function ensureValue<T>(parent: Instance, className: string, name: string, defaultValue: T)
	local existing = parent:FindFirstChild(name)
	if existing and existing:IsA(className) then
		(existing :: any).Value = defaultValue
		return existing
	end

	if existing then
		existing:Destroy()
	end

	local valueObject = Instance.new(className)
	valueObject.Name = name
	valueObject.Value = defaultValue
	valueObject.Parent = parent
	return valueObject
end

local function setPartVisible(part: BasePart, visible: boolean, transparency: number?)
	part.Transparency = if visible then (transparency or 0) else 1
	part.CanCollide = visible
	part.CanTouch = visible
	part.CanQuery = visible
end

local function setPartsVisible(parts: { BasePart }, visible: boolean, transparency: number?)
	for _, part in parts do
		setPartVisible(part, visible, transparency)
	end
end

local function setModelVisible(model: Model, visible: boolean, transparency: number?)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") and descendant.Name ~= "OutputPoint" then
			setPartVisible(descendant, visible, transparency)
		end
	end
end

local function createDropperModel(parent: Instance, name: string, origin: CFrame, accent: Color3, muted: boolean)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent

	local bodyColor = if muted then Color3.fromRGB(176, 176, 176) else accent
	local base = createPart(model, "Base", Vector3.new(10, 2, 10), origin + Vector3.new(0, -3, 0), {
		Color = Color3.fromRGB(48, 54, 67),
		Material = Enum.Material.Metal,
	})
	local body = createPart(model, "Body", Vector3.new(6, 6, 6), origin, {
		Color = bodyColor,
		Material = Enum.Material.Metal,
	})
	local nozzle = createPart(model, "Nozzle", Vector3.new(2, 2, 4), origin + Vector3.new(0, 4, -3), {
		Color = Color3.fromRGB(225, 230, 240),
		Material = Enum.Material.SmoothPlastic,
	})
	local outputPoint = createPart(model, "OutputPoint", Vector3.new(1, 1, 1), origin + Vector3.new(0, 5.5, -4.5), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})

	model.PrimaryPart = body

	if muted then
		base.Transparency = 0.2
		body.Transparency = 0.45
		nozzle.Transparency = 0.25
	end

	return model, outputPoint
end

local function createCollectorMachine(parent: Instance, name: string, origin: CFrame, accent: Color3)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent

	createPart(model, "Base", Vector3.new(12, 2, 10), origin + Vector3.new(0, 1, 0), {
		Color = Color3.fromRGB(42, 48, 59),
		Material = Enum.Material.Metal,
	})
	local core = createPart(model, "Core", Vector3.new(8, 6, 6), origin + Vector3.new(0, 5, 0), {
		Color = accent,
		Material = Enum.Material.Neon,
	})
	createPart(model, "Pipe", Vector3.new(2, 4, 2), origin + Vector3.new(0, 7, -2), {
		Color = Color3.fromRGB(110, 118, 130),
		Material = Enum.Material.Metal,
	})
	createPart(model, "Display", Vector3.new(4, 2, 0.5), origin + Vector3.new(0, 5, 3), {
		Color = Color3.fromRGB(23, 26, 33),
		Material = Enum.Material.SmoothPlastic,
	})

	model.PrimaryPart = core
	return model
end

local function computeEarningsPerSecond(purchased: { [string]: boolean }): number
	local total = 0
	for dropperId, dropperConfig in GameConfig.DROPPERS do
		if purchased[dropperId] then
			total += dropperConfig.value / dropperConfig.interval
		end
	end

	if purchased.conveyor_speed then
		total *= 1.2
	end

	return math.floor(total * 10 + 0.5) / 10
end

local function createUpgradeButton(parent: Instance, laneOrigin: Vector3, accent: Color3, upgradeId: string, index: number): UpgradeButton
	local upgrade = GameConfig.getUpgrade(upgradeId)
	if not upgrade then
		error(string.format("Missing upgrade definition for %s", upgradeId))
	end

	local buttonPart = createPart(parent, upgradeId, Vector3.new(10, 1, 10), CFrame.new(
		laneOrigin + Vector3.new(0, 0.6, GameConfig.BUTTON_LANE_START_Z + ((index - 1) * GameConfig.BUTTON_LANE_STEP_Z))
	), {
		Color = accent,
		Material = Enum.Material.Neon,
	})

	local label = createSurfaceLabel(buttonPart, string.format("%s\n$%d", upgrade.name, upgrade.cost), Enum.NormalId.Top, Color3.new(1, 1, 1))
	local prompt = ensurePrompt(buttonPart, string.format("Buy $%d", upgrade.cost), upgrade.name)

	return {
		part = buttonPart,
		label = label,
		prompt = prompt,
		upgradeId = upgradeId,
	}
end

local function createWallSet(parent: Instance, prefix: string, origin: Vector3, yOffset: number, wallHeight: number, accent: Color3)
	return {
		createPart(parent, prefix .. "Back", Vector3.new(64, wallHeight, 2), CFrame.new(origin + Vector3.new(0, yOffset, GameConfig.TYCOON_WALL_BACK_Z)), {
			Color = accent,
			Material = Enum.Material.Metal,
		}),
		createPart(parent, prefix .. "Left", Vector3.new(2, wallHeight, 84), CFrame.new(origin + Vector3.new(-38, yOffset, 0)), {
			Color = accent,
			Material = Enum.Material.Metal,
		}),
		createPart(parent, prefix .. "Right", Vector3.new(2, wallHeight, 84), CFrame.new(origin + Vector3.new(38, yOffset, 0)), {
			Color = accent,
			Material = Enum.Material.Metal,
		}),
		createPart(parent, prefix .. "FrontLeft", Vector3.new(26, wallHeight, 2), CFrame.new(origin + Vector3.new(-19, yOffset, GameConfig.TYCOON_WALL_FRONT_Z)), {
			Color = accent,
			Material = Enum.Material.Metal,
		}),
		createPart(parent, prefix .. "FrontRight", Vector3.new(26, wallHeight, 2), CFrame.new(origin + Vector3.new(19, yOffset, GameConfig.TYCOON_WALL_FRONT_Z)), {
			Color = accent,
			Material = Enum.Material.Metal,
		}),
	}
end

local function ensureSpawnPoints(model: Model, origin: Vector3): Folder
	local spawnPoints = ensureFolder(model, "SpawnPoints")
	clearFolder(spawnPoints)

	local spawnLocation = Instance.new("SpawnLocation")
	spawnLocation.Name = "TycoonSpawn"
	spawnLocation.Size = Vector3.new(12, 1, 12)
	spawnLocation.CFrame = CFrame.new(origin + Vector3.new(-26, 2.5, 28))
	spawnLocation.Anchored = true
	spawnLocation.Enabled = false
	spawnLocation.Neutral = false
	spawnLocation.Parent = spawnPoints

	createPart(spawnPoints, "SpawnMarker", Vector3.new(1, 1, 1), spawnLocation.CFrame + Vector3.new(0, 1.5, 0), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})

	return spawnPoints
end

local function ensureWeek3Scaffolding(model: Model, definition: Definition)
	local origin = definition.Origin

	destroyChild(model, "SpawnPoints")
	destroyChild(model, "ConveyorBase")
	destroyChild(model, "ConveyorStrip")
	destroyChild(model, "ConveyorEntry")
	destroyChild(model, "CollectorMachine")
	destroyChild(model, "CollectorPad")
	destroyChild(model, "CollectorPoint")
	destroyChild(model, "CollectorTrigger")
	destroyChild(model, "Economy")
	destroyChild(model, "Structures")
	destroyChild(model, "StructureSockets")
	destroyChild(model, "Buttons")
	destroyChild(model, "Runtime")
	destroyChild(model, "Values")
	destroyChild(model, "EarningsBoard")
	destroyChild(model, "LowWalls")
	destroyChild(model, "HighWalls")
	destroyChild(model, "Door")

	local baseFloor = ensurePart(model, "BaseFloor", GameConfig.TYCOON_SIZE, CFrame.new(origin), {
		Color = Color3.fromRGB(44, 47, 57),
		Material = Enum.Material.Slate,
	})

	local claimPad = ensurePart(model, "ClaimPad", Vector3.new(16, 1, 16), CFrame.new(origin + Vector3.new(0, 1.5, -32)), {
		Color = Color3.fromRGB(63, 215, 120),
		Material = Enum.Material.Neon,
	})

	local ownerSign = ensurePart(model, "OwnerSign", Vector3.new(20, 8, 1), CFrame.new(origin + Vector3.new(0, 8, -46)), {
		Color = Color3.fromRGB(22, 24, 31),
		Material = Enum.Material.SmoothPlastic,
	})

	local earningsBoard = ensurePart(model, "EarningsBoard", Vector3.new(18, 7, 1), CFrame.new(origin + GameConfig.EARNINGS_BOARD_OFFSET), {
		Color = Color3.fromRGB(26, 31, 41),
		Material = Enum.Material.SmoothPlastic,
	})

	local spawnPointsFolder = ensureSpawnPoints(model, origin)

	local structureSocketsFolder = ensureFolder(model, "StructureSockets")
	clearFolder(structureSocketsFolder)
	createPart(structureSocketsFolder, "ClaimSocket", Vector3.new(1, 1, 1), CFrame.new(origin + Vector3.new(0, 1, -32)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
	createPart(structureSocketsFolder, "ConveyorSocket", Vector3.new(1, 1, 1), CFrame.new(origin + Vector3.new(0, 1, -4)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
	createPart(structureSocketsFolder, "CollectorSocket", Vector3.new(1, 1, 1), CFrame.new(origin + Vector3.new(0, 1, 22)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
	createPart(structureSocketsFolder, "ButtonLaneSocket", Vector3.new(1, 1, 1), CFrame.new(origin + Vector3.new(GameConfig.BUTTON_LANE_X_OFFSET, 1, 0)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
	createPart(structureSocketsFolder, "DoorSocket", Vector3.new(1, 1, 1), CFrame.new(origin + Vector3.new(GameConfig.TYCOON_ENTRY_DOOR_OFFSET.X, 1, GameConfig.TYCOON_ENTRY_DOOR_OFFSET.Z)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})

	local economyFolder = ensureFolder(model, "Economy")
	clearFolder(economyFolder)
	local droppersFolder = ensureFolder(economyFolder, "Droppers")
	clearFolder(droppersFolder)

	local conveyorBase = ensurePart(economyFolder, "ConveyorBase", Vector3.new(10, 1, 48), CFrame.new(origin + Vector3.new(0, 1.25, -2)), {
		Color = Color3.fromRGB(52, 58, 71),
		Material = Enum.Material.Metal,
	})
	local conveyorStrip = ensurePart(economyFolder, "ConveyorStrip", Vector3.new(6, 0.35, 48), CFrame.new(origin + Vector3.new(0, 1.9, -2)), {
		Color = Color3.fromRGB(109, 122, 255),
		Material = Enum.Material.Neon,
	})
	local conveyorEntry = ensurePart(economyFolder, "ConveyorEntry", Vector3.new(1, 1, 1), CFrame.new(origin + Vector3.new(0, 5.25, -20)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})

	local collectorMachine = createCollectorMachine(economyFolder, "CollectorMachine", CFrame.new(origin + Vector3.new(0, 0, 22)), Color3.fromRGB(255, 182, 72))
	local collectorPad = ensurePart(economyFolder, "CollectorPad", Vector3.new(14, 1, 10), CFrame.new(origin + Vector3.new(0, 1.5, 28)), {
		Color = Color3.fromRGB(255, 182, 72),
		Material = Enum.Material.Neon,
	})
	local collectorLabel = ensureSurfaceLabel(collectorPad, "Stored\n$0", Enum.NormalId.Top, Color3.new(1, 1, 1))
	local collectorPrompt = ensurePrompt(collectorPad, "Collect $0", "Collector", GameConfig.COLLECTOR_PROMPT_RANGE)
	local collectorPoint = ensurePart(economyFolder, "CollectorPoint", Vector3.new(1, 1, 1), CFrame.new(origin + Vector3.new(0, 3.2, 22)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
	local collectorTrigger = ensurePart(economyFolder, "CollectorTrigger", Vector3.new(12, 3, 10), CFrame.new(origin + Vector3.new(0, 2.5, 26)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = true,
		CanQuery = false,
	})

	local runtimeFolder = ensureFolder(model, "Runtime")
	clearFolder(runtimeFolder)
	local moneyPartsFolder = ensureFolder(runtimeFolder, "MoneyParts")
	clearFolder(moneyPartsFolder)

	local structuresFolder = ensureFolder(model, "Structures")
	clearFolder(structuresFolder)
	local wallSetFolder = ensureFolder(structuresFolder, "WallSet1")
	clearFolder(wallSetFolder)
	local lowWallParts = createWallSet(wallSetFolder, "LowWall", origin, GameConfig.TYCOON_LOW_WALL_Y_OFFSET, GameConfig.TYCOON_LOW_WALL_HEIGHT, definition.Accent)
	local highWallsFolder = ensureFolder(structuresFolder, "HighWalls")
	clearFolder(highWallsFolder)
	local highWallParts = createWallSet(highWallsFolder, "HighWall", origin, GameConfig.TYCOON_HIGH_WALL_Y_OFFSET, GameConfig.TYCOON_HIGH_WALL_HEIGHT, Color3.fromRGB(49, 61, 104))
	local doorFolder = ensureFolder(structuresFolder, "Door")
	clearFolder(doorFolder)
	local doorFrame = createPart(doorFolder, "DoorFrame", Vector3.new(16, 14, 2), CFrame.new(origin + GameConfig.TYCOON_ENTRY_DOOR_OFFSET), {
		Color = Color3.fromRGB(24, 27, 34),
		Material = Enum.Material.Metal,
	})
	local doorPanel = createPart(doorFolder, "DoorPanel", Vector3.new(10, 10, 1), CFrame.new(origin + GameConfig.TYCOON_ENTRY_PANEL_OFFSET), {
		Color = Color3.fromRGB(162, 171, 192),
		Material = Enum.Material.Metal,
	})
	local doorSensor = createPart(doorFolder, "DoorSensor", Vector3.new(16, 12, 8), CFrame.new(origin + GameConfig.TYCOON_ENTRY_SENSOR_OFFSET), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = true,
		CanQuery = false,
	})

	local buttonsFolder = ensureFolder(model, "Buttons")
	clearFolder(buttonsFolder)
	local buttonLaneBase = createPart(buttonsFolder, "ButtonLaneBase", Vector3.new(8, 1, 84), CFrame.new(origin + Vector3.new(GameConfig.BUTTON_LANE_X_OFFSET, 1.25, -2)), {
		Color = Color3.fromRGB(31, 34, 45),
		Material = Enum.Material.SmoothPlastic,
	})
	ensureSurfaceLabel(buttonLaneBase, "Upgrade Lane", Enum.NormalId.Top, Color3.fromRGB(235, 235, 235))

	local buttonsOrigin = origin + Vector3.new(GameConfig.BUTTON_LANE_X_OFFSET, 0, -2)
	local upgradeButtons = {}
	for index, upgradeId in GameConfig.UPGRADE_ORDER do
		upgradeButtons[upgradeId] = createUpgradeButton(buttonsFolder, buttonsOrigin, definition.Accent, upgradeId, index)
	end

	local valuesFolder = ensureFolder(model, "Values")
	local ownerUserIdValue = ensureValue(valuesFolder, "IntValue", "OwnerUserId", 0)
	local ownerNameValue = ensureValue(valuesFolder, "StringValue", "OwnerName", "")
	local isClaimedValue = ensureValue(valuesFolder, "BoolValue", "IsClaimed", false)
	local tycoonIdValue = ensureValue(valuesFolder, "StringValue", "TycoonId", definition.Id)

	local claimLabel = ensureSurfaceLabel(claimPad, "Claim Tycoon", Enum.NormalId.Top, Color3.new(1, 1, 1))
	local ownerLabel = ensureSurfaceLabel(ownerSign, "Unclaimed", Enum.NormalId.Front, Color3.new(1, 1, 1))
	local earningsLabel = ensureSurfaceLabel(earningsBoard, "Earnings\n$0.0/sec", Enum.NormalId.Front, Color3.fromRGB(255, 231, 154))

	local dropperModels = {}
	local dropperOutputs = {}
	dropperModels.basic_dropper, dropperOutputs.basic_dropper = createDropperModel(
		droppersFolder,
		"BasicDropper",
		CFrame.new(origin + Vector3.new(-14, 5, -24)),
		definition.Accent,
		false
	)
	dropperModels.second_dropper, dropperOutputs.second_dropper = createDropperModel(
		droppersFolder,
		"SecondDropper",
		CFrame.new(origin + Vector3.new(-2, 5, -24)),
		Color3.fromRGB(255, 215, 102),
		true
	)

	return {
		Spawn = spawnPointsFolder:FindFirstChild("TycoonSpawn") :: SpawnLocation,
		ClaimPad = claimPad,
		ClaimPrompt = ensurePrompt(claimPad, "Claim Tycoon", definition.Id, GameConfig.CLAIM_PROMPT_RANGE),
		ClaimLabel = claimLabel,
		OwnerSign = ownerSign,
		OwnerLabel = ownerLabel,
		EarningsBoard = earningsBoard,
		EarningsLabel = earningsLabel,
		ConveyorBase = conveyorBase,
		ConveyorStrip = conveyorStrip,
		ConveyorEntry = conveyorEntry,
		CollectorMachine = collectorMachine,
		CollectorPad = collectorPad,
		CollectorPrompt = collectorPrompt,
		CollectorLabel = collectorLabel,
		CollectorPoint = collectorPoint,
		CollectorTrigger = collectorTrigger,
		RuntimeFolder = runtimeFolder,
		MoneyPartsFolder = moneyPartsFolder,
		EconomyFolder = economyFolder,
		StructuresFolder = structuresFolder,
		ButtonsFolder = buttonsFolder,
		StructureSocketsFolder = structureSocketsFolder,
		SpawnPointsFolder = spawnPointsFolder,
		DropperModels = dropperModels,
		DropperOutputs = dropperOutputs,
		LowWallParts = lowWallParts,
		HighWallParts = highWallParts,
		WallSetFolder = wallSetFolder,
		DoorFrame = doorFrame,
		DoorPanel = doorPanel,
		DoorSensor = doorSensor,
		ButtonStates = upgradeButtons,
		UpgradeButtons = upgradeButtons,
		Owner = nil,
		ValuesFolder = valuesFolder,
		OwnerUserIdValue = ownerUserIdValue :: IntValue,
		OwnerNameValue = ownerNameValue :: StringValue,
		IsClaimedValue = isClaimedValue :: BoolValue,
		TycoonIdValue = tycoonIdValue :: StringValue,
	}
end

local function buildInstance(selfTable)
	return setmetatable(selfTable, Tycoon)
end

function Tycoon.new(definition: Definition, parent: Instance): TycoonObject
	local model = Instance.new("Model")
	model.Name = definition.Id
	model.Parent = parent

	local refs = ensureWeek3Scaffolding(model, definition)

	local self = buildInstance({
		Id = definition.Id,
		Origin = definition.Origin,
		Accent = definition.Accent,
		Model = model,
		Spawn = refs.Spawn,
		ClaimPad = refs.ClaimPad,
		ClaimPrompt = refs.ClaimPrompt,
		ClaimLabel = refs.ClaimLabel,
		OwnerSign = refs.OwnerSign,
		OwnerLabel = refs.OwnerLabel,
		EarningsBoard = refs.EarningsBoard,
		EarningsLabel = refs.EarningsLabel,
		ConveyorBase = refs.ConveyorBase,
		ConveyorStrip = refs.ConveyorStrip,
		ConveyorEntry = refs.ConveyorEntry,
		CollectorMachine = refs.CollectorMachine,
		CollectorPad = refs.CollectorPad,
		CollectorPrompt = refs.CollectorPrompt,
		CollectorLabel = refs.CollectorLabel,
		CollectorPoint = refs.CollectorPoint,
		CollectorTrigger = refs.CollectorTrigger,
		RuntimeFolder = refs.RuntimeFolder,
		MoneyPartsFolder = refs.MoneyPartsFolder,
		EconomyFolder = refs.EconomyFolder,
		StructuresFolder = refs.StructuresFolder,
		ButtonsFolder = refs.ButtonsFolder,
		StructureSocketsFolder = refs.StructureSocketsFolder,
		SpawnPointsFolder = refs.SpawnPointsFolder,
		DropperModels = refs.DropperModels,
		DropperOutputs = refs.DropperOutputs,
		LowWallParts = refs.LowWallParts,
		HighWallParts = refs.HighWallParts,
		WallSetFolder = refs.WallSetFolder,
		DoorFrame = refs.DoorFrame,
		DoorPanel = refs.DoorPanel,
		DoorSensor = refs.DoorSensor,
		ButtonStates = refs.ButtonStates,
		UpgradeButtons = refs.UpgradeButtons,
		Owner = nil,
		ValuesFolder = refs.ValuesFolder,
		OwnerUserIdValue = refs.OwnerUserIdValue,
		OwnerNameValue = refs.OwnerNameValue,
		IsClaimedValue = refs.IsClaimedValue,
		TycoonIdValue = refs.TycoonIdValue,
	}, Tycoon)

	self:updateButtons({})
	self:applyVisualState({}, 0)
	self:setOwner(nil)
	return self
end

function Tycoon.bind(model: Model, definition: Definition): TycoonObject
	local refs = ensureWeek3Scaffolding(model, definition)

	local self = buildInstance({
		Id = definition.Id,
		Origin = definition.Origin,
		Accent = definition.Accent,
		Model = model,
		Spawn = refs.Spawn,
		ClaimPad = refs.ClaimPad,
		ClaimPrompt = refs.ClaimPrompt,
		ClaimLabel = refs.ClaimLabel,
		OwnerSign = refs.OwnerSign,
		OwnerLabel = refs.OwnerLabel,
		EarningsBoard = refs.EarningsBoard,
		EarningsLabel = refs.EarningsLabel,
		ConveyorBase = refs.ConveyorBase,
		ConveyorStrip = refs.ConveyorStrip,
		ConveyorEntry = refs.ConveyorEntry,
		CollectorMachine = refs.CollectorMachine,
		CollectorPad = refs.CollectorPad,
		CollectorPrompt = refs.CollectorPrompt,
		CollectorLabel = refs.CollectorLabel,
		CollectorPoint = refs.CollectorPoint,
		CollectorTrigger = refs.CollectorTrigger,
		RuntimeFolder = refs.RuntimeFolder,
		MoneyPartsFolder = refs.MoneyPartsFolder,
		EconomyFolder = refs.EconomyFolder,
		StructuresFolder = refs.StructuresFolder,
		ButtonsFolder = refs.ButtonsFolder,
		StructureSocketsFolder = refs.StructureSocketsFolder,
		SpawnPointsFolder = refs.SpawnPointsFolder,
		DropperModels = refs.DropperModels,
		DropperOutputs = refs.DropperOutputs,
		LowWallParts = refs.LowWallParts,
		HighWallParts = refs.HighWallParts,
		WallSetFolder = refs.WallSetFolder,
		DoorFrame = refs.DoorFrame,
		DoorPanel = refs.DoorPanel,
		DoorSensor = refs.DoorSensor,
		ButtonStates = refs.ButtonStates,
		UpgradeButtons = refs.UpgradeButtons,
		Owner = nil,
		ValuesFolder = refs.ValuesFolder,
		OwnerUserIdValue = refs.OwnerUserIdValue,
		OwnerNameValue = refs.OwnerNameValue,
		IsClaimedValue = refs.IsClaimedValue,
		TycoonIdValue = refs.TycoonIdValue,
	}, Tycoon)

	self:updateButtons({})
	self:applyVisualState({}, 0)
	self:setOwner(nil)
	return self
end

function Tycoon:setOwner(player: Player?)
	self.Owner = player
	self.Spawn.Enabled = player ~= nil

	if player then
		self.OwnerLabel.Text = string.format("%s's Tycoon", player.DisplayName)
		self.ClaimLabel.Text = "Claimed"
		self.ClaimPrompt.Enabled = false
		self.ClaimPad.Color = self.Accent
		self.OwnerUserIdValue.Value = player.UserId
		self.OwnerNameValue.Value = player.Name
		self.IsClaimedValue.Value = true
	else
		self.OwnerLabel.Text = "Unclaimed"
		self.ClaimLabel.Text = "Claim Tycoon"
		self.ClaimPrompt.Enabled = true
		self.ClaimPad.Color = Color3.fromRGB(63, 215, 120)
		self.OwnerUserIdValue.Value = 0
		self.OwnerNameValue.Value = ""
		self.IsClaimedValue.Value = false
	end

	self.TycoonIdValue.Value = self.Id
end

function Tycoon:isOwnedBy(player: Player): boolean
	return self.OwnerUserIdValue.Value == player.UserId and self.IsClaimedValue.Value
end

function Tycoon:updateCollectorDisplay(amount: number)
	self.CollectorLabel.Text = string.format("Stored\n$%d", amount)
	self.CollectorPrompt.ActionText = if amount > 0 then string.format("Collect $%d", amount) else "Collect $0"
end

function Tycoon:applyVisualState(purchased: { [string]: boolean }, collectorStored: number)
	setPartVisible(self.ClaimPad, true, 0)
	setPartVisible(self.OwnerSign, true, 0)
	setPartVisible(self.EarningsBoard, true, 0)
	setPartVisible(self.ConveyorBase, true, 0)
	setPartVisible(self.ConveyorStrip, true, 0)
	setPartVisible(self.ConveyorEntry, false)
	setPartVisible(self.CollectorPad, true, 0)
	setPartVisible(self.CollectorPoint, false)
	setPartVisible(self.CollectorTrigger, false)
	setPartVisible(self.DoorFrame, purchased.front_door == true or purchased.reinforced_door == true, 0)
	setPartVisible(self.DoorPanel, purchased.front_door == true or purchased.reinforced_door == true, if purchased.reinforced_door then 0 else 0)
	setPartVisible(self.DoorSensor, purchased.front_door == true or purchased.reinforced_door == true, 1)
	self.DoorFrame.CanCollide = false
	self.DoorFrame.CanTouch = false
	self.DoorSensor.CanCollide = false
	self.DoorSensor.CanTouch = false

	setModelVisible(self.CollectorMachine, true, 0)
	setModelVisible(self.DropperModels.basic_dropper, purchased.basic_dropper == true, 0)
	setModelVisible(self.DropperModels.second_dropper, purchased.second_dropper == true, 0)

	local showWallSet = purchased.wall_set_1 == true or purchased.front_door == true or purchased.reinforced_door == true or purchased.high_walls == true
	setPartsVisible(self.LowWallParts, showWallSet, 0)
	setPartsVisible(self.HighWallParts, purchased.high_walls == true, 0)

	if purchased.reinforced_door then
		self.DoorPanel.Color = Color3.fromRGB(255, 178, 79)
		self.DoorPanel.Material = Enum.Material.DiamondPlate
	elseif purchased.front_door then
		self.DoorPanel.Color = Color3.fromRGB(162, 171, 192)
		self.DoorPanel.Material = Enum.Material.Metal
	else
		self.DoorPanel.Color = Color3.fromRGB(162, 171, 192)
		self.DoorPanel.Material = Enum.Material.Metal
	end

	self.ConveyorStrip.Color = if purchased.conveyor_speed then Color3.fromRGB(255, 230, 132) else Color3.fromRGB(109, 122, 255)
	self.CollectorMachine.PrimaryPart.Color = if purchased.collector then Color3.fromRGB(255, 215, 128) else Color3.fromRGB(255, 182, 72)
	self.EarningsLabel.Text = string.format("Earnings\n$%.1f/sec", computeEarningsPerSecond(purchased))
	self:updateCollectorDisplay(collectorStored)
end

function Tycoon:updateButtons(purchased: { [string]: boolean })
	for _, upgradeId in GameConfig.UPGRADE_ORDER do
		local buttonState = self.ButtonStates[upgradeId]
		local upgrade = GameConfig.getUpgrade(upgradeId)
		local isPurchased = purchased[upgradeId] == true
		local canBuy = self.Owner ~= nil and not isPurchased and GameConfig.areRequirementsMet(purchased, upgradeId)

		buttonState.prompt.Enabled = canBuy
		buttonState.part.Transparency = if canBuy then 0 else 1
		buttonState.part.CanCollide = canBuy
		buttonState.part.CanTouch = canBuy
		buttonState.part.CanQuery = canBuy
		buttonState.label.Visible = canBuy
		buttonState.prompt.ActionText = string.format("Buy $%d", upgrade.cost)
	end
end

function Tycoon:teleportToSpawn(player: Player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = self.Spawn.CFrame + Vector3.new(0, 4, 0)
	end
end

return Tycoon
