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
	AutoCollectorMachine: Model?,
	CollectorPad: BasePart,
	CollectorPrompt: ProximityPrompt,
	CollectorLabel: TextLabel,
	CollectorPoint: BasePart,
	CollectorTrigger: BasePart,
	StarterClicker: BasePart,
	StarterClickerPrompt: ProximityPrompt,
	StarterClickerLabel: TextLabel,
	RuntimeFolder: Folder,
	MoneyPartsFolder: Folder,
	EconomyFolder: Folder,
	StructuresFolder: Folder,
	ButtonsFolder: Folder,
	StructureSocketsFolder: Folder,
	SpawnPointsFolder: Folder,
	DropperModels: { [string]: Model },
	DropperOutputs: { [string]: BasePart },
	DropperRoots: { [string]: Vector3 },
	LowWallParts: { BasePart },
	HighWallParts: { BasePart },
	WallSetFolder: Folder,
	DoorFrame: BasePart?,
	DoorPanel: BasePart?,
	DoorSensor: BasePart,
	DoorInnerSensor: BasePart,
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
	local base = createPart(model, "Base", Vector3.new(10, 2, 10), origin * CFrame.new(0, -3, 0), {
		Color = Color3.fromRGB(48, 54, 67),
		Material = Enum.Material.Metal,
	})
	local body = createPart(model, "Body", Vector3.new(6, 6, 6), origin, {
		Color = bodyColor,
		Material = Enum.Material.Metal,
	})
	local nozzle = createPart(model, "Nozzle", Vector3.new(2, 2, 4), origin * CFrame.new(0, 4, -3), {
		Color = Color3.fromRGB(225, 230, 240),
		Material = Enum.Material.SmoothPlastic,
	})
	local outputPoint = createPart(model, "OutputPoint", Vector3.new(1, 1, 1), origin * CFrame.new(0, 5.5, -4.5), {
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

local function getDropperRootCFrame(origin: Vector3, dropperOffset: Vector3): CFrame
	local worldPosition = origin + dropperOffset
	local lookDirection = if dropperOffset.X < GameConfig.TYCOON_CONVEYOR_X_OFFSET then Vector3.new(1, 0, 0) else Vector3.new(-1, 0, 0)
	return CFrame.lookAt(worldPosition, worldPosition + lookDirection)
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

local function labelMachine(model: Model, text: string, accent: Color3)
	local display = model:FindFirstChild("Display")
	if display and display:IsA("BasePart") then
		ensureSurfaceLabel(display, text, Enum.NormalId.Front, accent)
	end
end

local function computeEarningsPerSecond(purchased: { [string]: boolean }): number
	return GameConfig.getEarningsPerSecondForUpgrades(purchased)
end

local function getButtonLaneCenterZ(): number
	local buttonCount = #GameConfig.UPGRADE_ORDER
	local endZ = GameConfig.BUTTON_LANE_START_Z + ((buttonCount - 1) * GameConfig.BUTTON_LANE_STEP_Z)
	return (GameConfig.BUTTON_LANE_START_Z + endZ) / 2
end

local function createUpgradeButton(parent: Instance, laneOrigin: Vector3, accent: Color3, upgradeId: string, index: number): UpgradeButton
	local upgrade = GameConfig.getUpgrade(upgradeId)
	if not upgrade then
		error(string.format("Missing upgrade definition for %s", upgradeId))
	end

	local layout = GameConfig.BUTTON_LAYOUTS[upgradeId]
	local buttonSize = GameConfig.BUTTON_PAD_SIZE
	local position = if layout and typeof(layout.offset) == "Vector3"
		then laneOrigin + layout.offset
		else laneOrigin + Vector3.new(0, 0.6, GameConfig.BUTTON_LANE_START_Z + ((index - 1) * GameConfig.BUTTON_LANE_STEP_Z))

	local buttonPart = createPart(parent, upgradeId, buttonSize, CFrame.new(position), {
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
		createPart(parent, prefix .. "Back", Vector3.new(GameConfig.TYCOON_WALL_BACK_WIDTH, wallHeight, 2), CFrame.new(origin + Vector3.new(0, yOffset, GameConfig.TYCOON_WALL_BACK_Z)), {
			Color = accent,
			Material = Enum.Material.Metal,
		}),
		createPart(parent, prefix .. "Left", Vector3.new(2, wallHeight, GameConfig.TYCOON_WALL_SIDE_LENGTH), CFrame.new(origin + Vector3.new(-GameConfig.TYCOON_WALL_SIDE_X, yOffset, 0)), {
			Color = accent,
			Material = Enum.Material.Metal,
		}),
		createPart(parent, prefix .. "Right", Vector3.new(2, wallHeight, GameConfig.TYCOON_WALL_SIDE_LENGTH), CFrame.new(origin + Vector3.new(GameConfig.TYCOON_WALL_SIDE_X, yOffset, 0)), {
			Color = accent,
			Material = Enum.Material.Metal,
		}),
		createPart(parent, prefix .. "FrontLeft", Vector3.new(GameConfig.TYCOON_WALL_FRONT_SEGMENT_WIDTH, wallHeight, 2), CFrame.new(origin + Vector3.new(GameConfig.TYCOON_WALL_FRONT_LEFT_X, yOffset, GameConfig.TYCOON_WALL_FRONT_Z)), {
			Color = accent,
			Material = Enum.Material.Metal,
		}),
		createPart(parent, prefix .. "FrontRight", Vector3.new(GameConfig.TYCOON_WALL_FRONT_SEGMENT_WIDTH, wallHeight, 2), CFrame.new(origin + Vector3.new(GameConfig.TYCOON_WALL_FRONT_RIGHT_X, yOffset, GameConfig.TYCOON_WALL_FRONT_Z)), {
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
	spawnLocation.CFrame = CFrame.new(origin + GameConfig.TYCOON_SPAWN_OFFSET)
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
	destroyChild(model, "AutoCollectorMachine")
	destroyChild(model, "CollectorPad")
	destroyChild(model, "CollectorPoint")
	destroyChild(model, "CollectorTrigger")
	destroyChild(model, "StarterClicker")
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

	local claimPad = ensurePart(model, "ClaimPad", GameConfig.CLAIM_PAD_UNCLAIMED_SIZE, CFrame.new(origin + GameConfig.CLAIM_PAD_OFFSET), {
		Color = Color3.fromRGB(63, 215, 120),
		Material = Enum.Material.Neon,
	})

	local ownerSign = ensurePart(model, "OwnerSign", Vector3.new(22, 8, 1), CFrame.new(origin + Vector3.new(0, 9, GameConfig.TYCOON_WALL_FRONT_Z - 1)), {
		Color = Color3.fromRGB(22, 24, 31),
		Material = Enum.Material.SmoothPlastic,
	})

	local earningsBoard = ensurePart(model, "EarningsBoard", Vector3.new(20, 8, 1), CFrame.new(origin + GameConfig.EARNINGS_BOARD_OFFSET), {
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
	createPart(structureSocketsFolder, "ConveyorSocket", Vector3.new(1, 1, 1), CFrame.new(origin + Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET, 1, GameConfig.TYCOON_CONVEYOR_Z_OFFSET)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
	createPart(structureSocketsFolder, "CollectorSocket", Vector3.new(1, 1, 1), CFrame.new(origin + Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET, 1, GameConfig.TYCOON_COLLECTOR_Z_OFFSET)), {
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
	local dropperSocketsFolder = ensureFolder(economyFolder, "DropperSockets")
	clearFolder(dropperSocketsFolder)

	local conveyorBase = ensurePart(economyFolder, "ConveyorBase", Vector3.new(10, 1, GameConfig.TYCOON_CONVEYOR_LENGTH), CFrame.new(origin + Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET, 1.25, GameConfig.TYCOON_CONVEYOR_Z_OFFSET)), {
		Color = Color3.fromRGB(52, 58, 71),
		Material = Enum.Material.Metal,
	})
	local conveyorStrip = ensurePart(economyFolder, "ConveyorStrip", Vector3.new(6, 0.35, GameConfig.TYCOON_CONVEYOR_LENGTH), CFrame.new(origin + Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET, 1.9, GameConfig.TYCOON_CONVEYOR_Z_OFFSET)), {
		Color = Color3.fromRGB(109, 122, 255),
		Material = Enum.Material.Neon,
	})
	local conveyorEntry = ensurePart(economyFolder, "ConveyorEntry", Vector3.new(1, 1, 1), CFrame.new(origin + Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET, 5.25, GameConfig.TYCOON_CONVEYOR_ENTRY_Z_OFFSET)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})

	local collectorMachine = createCollectorMachine(economyFolder, "CollectorMachine", CFrame.new(origin + Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET, 0, GameConfig.TYCOON_COLLECTOR_Z_OFFSET)), Color3.fromRGB(255, 182, 72))
	labelMachine(collectorMachine, "Collector", Color3.fromRGB(255, 231, 154))
	local collectorPad = ensurePart(economyFolder, "CollectorPad", Vector3.new(16, 1, 12), CFrame.new(origin + Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET, 1.5, GameConfig.TYCOON_COLLECTOR_PAD_Z_OFFSET)), {
		Color = Color3.fromRGB(255, 182, 72),
		Material = Enum.Material.Neon,
	})
	local collectorLabel = ensureSurfaceLabel(collectorPad, "Stored\n$0", Enum.NormalId.Top, Color3.new(1, 1, 1))
	local collectorPrompt = ensurePrompt(collectorPad, "Collect $0", "Collector", GameConfig.COLLECTOR_PROMPT_RANGE)
	local collectorPoint = ensurePart(economyFolder, "CollectorPoint", Vector3.new(1, 1, 1), CFrame.new(origin + Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET, 3.2, GameConfig.TYCOON_COLLECTOR_Z_OFFSET)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
	local collectorTrigger = ensurePart(economyFolder, "CollectorTrigger", Vector3.new(14, 3, 12), CFrame.new(origin + Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET, 2.5, GameConfig.TYCOON_COLLECTOR_PAD_Z_OFFSET)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = true,
		CanQuery = false,
	})
	local starterClicker = ensurePart(economyFolder, "StarterClicker", Vector3.new(10, 1, 10), CFrame.new(origin + GameConfig.TYCOON_CLICKER_OFFSET), {
		Color = Color3.fromRGB(98, 245, 182),
		Material = Enum.Material.Neon,
	})
	local starterClickerLabel = ensureSurfaceLabel(starterClicker, "Starter Clicker\nTap for cash", Enum.NormalId.Top, Color3.fromRGB(255, 255, 255))
	local starterClickerPrompt = ensurePrompt(starterClicker, "Click Cash", "Starter Clicker", GameConfig.BUTTON_PROMPT_RANGE)
	local runtimeFolder = ensureFolder(model, "Runtime")
	clearFolder(runtimeFolder)
	local moneyPartsFolder = ensureFolder(runtimeFolder, "MoneyParts")
	clearFolder(moneyPartsFolder)

	local structuresFolder = ensureFolder(model, "Structures")
	clearFolder(structuresFolder)
	local wallSetFolder = ensureFolder(structuresFolder, "WallSet1")
	clearFolder(wallSetFolder)
	local highWallsFolder = ensureFolder(structuresFolder, "HighWalls")
	clearFolder(highWallsFolder)
	local doorFolder = ensureFolder(structuresFolder, "Door")
	clearFolder(doorFolder)
	local doorSensor = createPart(doorFolder, "DoorSensor", Vector3.new(4, 4, 2), CFrame.new(origin + GameConfig.TYCOON_ENTRY_SENSOR_OFFSET), {
		Color = Color3.fromRGB(39, 45, 61),
		Material = Enum.Material.Neon,
		Transparency = 0,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
	ensureSurfaceLabel(doorSensor, "Owner\nDoor", Enum.NormalId.Front, Color3.new(1, 1, 1))
	local doorInnerSensor = createPart(doorFolder, "DoorInnerSensor", Vector3.new(4, 4, 2), CFrame.new(origin + GameConfig.TYCOON_ENTRY_INSIDE_SENSOR_OFFSET), {
		Color = Color3.fromRGB(39, 45, 61),
		Material = Enum.Material.Neon,
		Transparency = 0,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
	ensureSurfaceLabel(doorInnerSensor, "Owner\nDoor", Enum.NormalId.Front, Color3.new(1, 1, 1))

	local buttonsFolder = ensureFolder(model, "Buttons")
	clearFolder(buttonsFolder)
	local buttonGuide = createPart(buttonsFolder, "UpgradeGuide", Vector3.new(14, 1, 10), CFrame.new(origin + Vector3.new(40, 1.25, 17)), {
		Color = Color3.fromRGB(31, 34, 45),
		Material = Enum.Material.SmoothPlastic,
	})
	ensureSurfaceLabel(buttonGuide, "Upgrade Pads", Enum.NormalId.Top, Color3.fromRGB(235, 235, 235))

	local buttonsOrigin = origin
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
	for _, upgradeId in GameConfig.DROPPER_ORDER do
		local dropperConfig = GameConfig.DROPPERS[upgradeId]
		local rootCFrame = getDropperRootCFrame(origin, dropperConfig.offset)
		dropperOutputs[upgradeId] = createPart(dropperSocketsFolder, upgradeId .. "OutputSocket", Vector3.new(1, 1, 1), rootCFrame * CFrame.new(0, 5.5, -4.5), {
			Transparency = 1,
			CanCollide = false,
			CanTouch = false,
			CanQuery = false,
		})
	end

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
		AutoCollectorMachine = nil,
		CollectorPad = collectorPad,
		CollectorPrompt = collectorPrompt,
		CollectorLabel = collectorLabel,
		CollectorPoint = collectorPoint,
		CollectorTrigger = collectorTrigger,
		StarterClicker = starterClicker,
		StarterClickerPrompt = starterClickerPrompt,
		StarterClickerLabel = starterClickerLabel,
		RuntimeFolder = runtimeFolder,
		MoneyPartsFolder = moneyPartsFolder,
		EconomyFolder = economyFolder,
		StructuresFolder = structuresFolder,
		ButtonsFolder = buttonsFolder,
		StructureSocketsFolder = structureSocketsFolder,
		SpawnPointsFolder = spawnPointsFolder,
		DropperModels = dropperModels,
		DropperOutputs = dropperOutputs,
		DropperRoots = {},
		LowWallParts = {},
		HighWallParts = {},
		WallSetFolder = wallSetFolder,
		DoorFrame = nil,
		DoorPanel = nil,
		DoorSensor = doorSensor,
		DoorInnerSensor = doorInnerSensor,
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

local function clearBasePartList(parts: { BasePart })
	for index, part in parts do
		if part and part.Parent then
			part:Destroy()
		end
		parts[index] = nil
	end
end

local function formatUpgradeModelName(upgradeId: string): string
	return string.gsub(upgradeId, "_", " "):gsub("(%w)([%w']*)", function(first, rest)
		return string.upper(first) .. rest
	end)
end

local function ensureDropperVisual(selfTable, upgradeId: string)
	local existing = selfTable.DropperModels[upgradeId]
	if existing and existing.Parent then
		return existing
	end

	local dropperConfig = GameConfig.DROPPERS[upgradeId]
	if not dropperConfig then
		return nil
	end

	local droppersFolder = selfTable.EconomyFolder:FindFirstChild("Droppers")
	if not droppersFolder or not droppersFolder:IsA("Folder") then
		return nil
	end

	local model = select(1, createDropperModel(
		droppersFolder,
		formatUpgradeModelName(upgradeId),
		getDropperRootCFrame(selfTable.Origin, dropperConfig.offset),
		dropperConfig.color,
		false
	))
	selfTable.DropperModels[upgradeId] = model
	return model
end

local function clearDropperVisual(selfTable, upgradeId: string)
	local model = selfTable.DropperModels[upgradeId]
	if model then
		model:Destroy()
		selfTable.DropperModels[upgradeId] = nil
	end
end

local function reconcileDropperVisuals(selfTable, purchased: { [string]: boolean })
	for _, upgradeId in GameConfig.DROPPER_ORDER do
		if purchased[upgradeId] then
			ensureDropperVisual(selfTable, upgradeId)
		else
			clearDropperVisual(selfTable, upgradeId)
		end
	end
end

local function ensureAutoCollectorMachine(selfTable)
	if selfTable.AutoCollectorMachine and selfTable.AutoCollectorMachine.Parent then
		return
	end

	selfTable.AutoCollectorMachine = createCollectorMachine(
		selfTable.EconomyFolder,
		"AutoCollectorMachine",
		CFrame.new(selfTable.Origin + Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET, 0, GameConfig.TYCOON_AUTO_COLLECTOR_Z_OFFSET)),
		Color3.fromRGB(98, 245, 182)
	)
	labelMachine(selfTable.AutoCollectorMachine, "Auto\nCollector", Color3.fromRGB(172, 255, 220))
end

local function clearAutoCollectorMachine(selfTable)
	if selfTable.AutoCollectorMachine then
		selfTable.AutoCollectorMachine:Destroy()
		selfTable.AutoCollectorMachine = nil
	end
end

local function ensurePremiumConveyorUpgrade(selfTable)
	local folder = ensureFolder(selfTable.EconomyFolder, "PremiumConveyor")
	if #folder:GetChildren() > 0 then
		return
	end

	createPart(folder, "RailLeft", Vector3.new(1, 2, GameConfig.TYCOON_CONVEYOR_LENGTH), CFrame.new(selfTable.Origin + Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET - 4, 2.3, GameConfig.TYCOON_CONVEYOR_Z_OFFSET)), {
		Color = Color3.fromRGB(120, 255, 197),
		Material = Enum.Material.Neon,
	})
	createPart(folder, "RailRight", Vector3.new(1, 2, GameConfig.TYCOON_CONVEYOR_LENGTH), CFrame.new(selfTable.Origin + Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET + 4, 2.3, GameConfig.TYCOON_CONVEYOR_Z_OFFSET)), {
		Color = Color3.fromRGB(120, 255, 197),
		Material = Enum.Material.Neon,
	})
	createPart(folder, "DriveUnit", Vector3.new(8, 6, 6), CFrame.new(selfTable.Origin + Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET, 4.5, GameConfig.TYCOON_CONVEYOR_ENTRY_Z_OFFSET - 6)), {
		Color = Color3.fromRGB(40, 60, 62),
		Material = Enum.Material.Metal,
	})
end

local function clearPremiumConveyorUpgrade(selfTable)
	local folder = selfTable.EconomyFolder:FindFirstChild("PremiumConveyor")
	if folder and folder:IsA("Folder") then
		clearFolder(folder)
	end
end

local function ensureCashCompressor(selfTable)
	local folder = ensureFolder(selfTable.EconomyFolder, "CashCompressor")
	if folder:FindFirstChild("CashCompressor") then
		return
	end

	local model = createCollectorMachine(
		folder,
		"CashCompressor",
		CFrame.new(selfTable.Origin + Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET + 12, 0, GameConfig.TYCOON_AUTO_COLLECTOR_Z_OFFSET - 2)),
		Color3.fromRGB(255, 110, 110)
	)
	labelMachine(model, "Cash\nCompressor", Color3.fromRGB(255, 222, 173))
end

local function clearCashCompressor(selfTable)
	destroyChild(selfTable.EconomyFolder, "CashCompressor")
end

local function ensureCollectorArray(selfTable)
	local folder = ensureFolder(selfTable.EconomyFolder, "CollectorArray")
	if #folder:GetChildren() > 0 then
		return
	end

	local leftCollector = createCollectorMachine(
		folder,
		"CollectorArrayLeft",
		CFrame.new(selfTable.Origin + Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET - 12, 0, GameConfig.TYCOON_COLLECTOR_Z_OFFSET + 2)),
		Color3.fromRGB(132, 226, 255)
	)
	labelMachine(leftCollector, "Array\nLeft", Color3.fromRGB(214, 246, 255))

	local rightCollector = createCollectorMachine(
		folder,
		"CollectorArrayRight",
		CFrame.new(selfTable.Origin + Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET + 12, 0, GameConfig.TYCOON_COLLECTOR_Z_OFFSET + 2)),
		Color3.fromRGB(132, 226, 255)
	)
	labelMachine(rightCollector, "Array\nRight", Color3.fromRGB(214, 246, 255))
end

local function clearCollectorArray(selfTable)
	destroyChild(selfTable.EconomyFolder, "CollectorArray")
end

local function ensureSecurityLights(selfTable)
	local folder = ensureFolder(selfTable.StructuresFolder, "SecurityLights")
	if #folder:GetChildren() > 0 then
		return
	end

	local offsets = {
		Vector3.new(-42, 18, -57),
		Vector3.new(42, 18, -57),
		Vector3.new(-42, 18, 57),
		Vector3.new(42, 18, 57),
	}

	for index, offset in offsets do
		createPart(folder, "LightPost" .. index, Vector3.new(1.5, 8, 1.5), CFrame.new(selfTable.Origin + offset - Vector3.new(0, 4, 0)), {
			Color = Color3.fromRGB(44, 52, 61),
			Material = Enum.Material.Metal,
		})
		createPart(folder, "LightHead" .. index, Vector3.new(4, 1, 4), CFrame.new(selfTable.Origin + offset), {
			Color = Color3.fromRGB(155, 240, 255),
			Material = Enum.Material.Neon,
		})
	end
end

local function clearSecurityLights(selfTable)
	local folder = selfTable.StructuresFolder:FindFirstChild("SecurityLights")
	if folder and folder:IsA("Folder") then
		clearFolder(folder)
	end
end

local function ensureCornerPosts(selfTable)
	local folder = ensureFolder(selfTable.StructuresFolder, "CornerPosts")
	if #folder:GetChildren() > 0 then
		return
	end

	local offsets = {
		Vector3.new(-51, 14, -60),
		Vector3.new(51, 14, -60),
		Vector3.new(-51, 14, 60),
		Vector3.new(51, 14, 60),
	}

	for index, offset in offsets do
		createPart(folder, "CornerPost" .. index, Vector3.new(3, 28, 3), CFrame.new(selfTable.Origin + offset), {
			Color = Color3.fromRGB(56, 66, 92),
			Material = Enum.Material.Metal,
		})
	end
end

local function clearCornerPosts(selfTable)
	local folder = selfTable.StructuresFolder:FindFirstChild("CornerPosts")
	if folder and folder:IsA("Folder") then
		clearFolder(folder)
	end
end

local function ensureRearExtension(selfTable)
	local folder = ensureFolder(selfTable.StructuresFolder, "RearExtension")
	if #folder:GetChildren() > 0 then
		return
	end

	createPart(folder, "RearDeck", Vector3.new(112, 1, 22), CFrame.new(selfTable.Origin + Vector3.new(0, 1.05, 66)), {
		Color = Color3.fromRGB(58, 64, 78),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "RearTrimLeft", Vector3.new(8, 2, 24), CFrame.new(selfTable.Origin + Vector3.new(-52, 1.5, 66)), {
		Color = selfTable.Accent,
		Material = Enum.Material.Metal,
	})
	createPart(folder, "RearTrimRight", Vector3.new(8, 2, 24), CFrame.new(selfTable.Origin + Vector3.new(52, 1.5, 66)), {
		Color = selfTable.Accent,
		Material = Enum.Material.Metal,
	})
end

local function clearRearExtension(selfTable)
	local folder = selfTable.StructuresFolder:FindFirstChild("RearExtension")
	if folder and folder:IsA("Folder") then
		clearFolder(folder)
	end
end

local function ensureUtilityBay(selfTable)
	local folder = ensureFolder(selfTable.StructuresFolder, "UtilityBay")
	if #folder:GetChildren() > 0 then
		return
	end

	createPart(folder, "BayFloor", Vector3.new(20, 1, 96), CFrame.new(selfTable.Origin + Vector3.new(52, 1.1, 8)), {
		Color = Color3.fromRGB(47, 53, 67),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "BayCabinetA", Vector3.new(8, 10, 8), CFrame.new(selfTable.Origin + Vector3.new(52, 6, -26)), {
		Color = Color3.fromRGB(86, 95, 116),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "BayCabinetB", Vector3.new(8, 10, 8), CFrame.new(selfTable.Origin + Vector3.new(52, 6, 4)), {
		Color = Color3.fromRGB(86, 95, 116),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "BayPipe", Vector3.new(4, 4, 58), CFrame.new(selfTable.Origin + Vector3.new(44, 12, 12)), {
		Color = Color3.fromRGB(125, 147, 167),
		Material = Enum.Material.Metal,
	})
end

local function clearUtilityBay(selfTable)
	local folder = selfTable.StructuresFolder:FindFirstChild("UtilityBay")
	if folder and folder:IsA("Folder") then
		clearFolder(folder)
	end
end

local function ensureRoofFrame(selfTable)
	local folder = ensureFolder(selfTable.StructuresFolder, "RoofFrame")
	if #folder:GetChildren() > 0 then
		return
	end

	local postOffsets = {
		Vector3.new(-46, 16, -38),
		Vector3.new(46, 16, -38),
		Vector3.new(-46, 16, 10),
		Vector3.new(46, 16, 10),
		Vector3.new(-46, 16, 58),
		Vector3.new(46, 16, 58),
	}

	for index, offset in postOffsets do
		createPart(folder, "RoofPost" .. index, Vector3.new(3, 32, 3), CFrame.new(selfTable.Origin + offset), {
			Color = Color3.fromRGB(62, 73, 98),
			Material = Enum.Material.Metal,
		})
	end

	createPart(folder, "RoofBeamFront", Vector3.new(98, 3, 3), CFrame.new(selfTable.Origin + Vector3.new(0, 31, -38)), {
		Color = Color3.fromRGB(76, 92, 120),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "RoofBeamMid", Vector3.new(98, 3, 3), CFrame.new(selfTable.Origin + Vector3.new(0, 31, 10)), {
		Color = Color3.fromRGB(76, 92, 120),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "RoofBeamRear", Vector3.new(98, 3, 3), CFrame.new(selfTable.Origin + Vector3.new(0, 31, 58)), {
		Color = Color3.fromRGB(76, 92, 120),
		Material = Enum.Material.Metal,
	})
end

local function clearRoofFrame(selfTable)
	local folder = selfTable.StructuresFolder:FindFirstChild("RoofFrame")
	if folder and folder:IsA("Folder") then
		clearFolder(folder)
	end
end

local function ensureLowWalls(selfTable)
	if #selfTable.LowWallParts > 0 and selfTable.LowWallParts[1] and selfTable.LowWallParts[1].Parent then
		return
	end

	clearFolder(selfTable.WallSetFolder)
	selfTable.LowWallParts = createWallSet(
		selfTable.WallSetFolder,
		"LowWall",
		selfTable.Origin,
		GameConfig.TYCOON_LOW_WALL_Y_OFFSET,
		GameConfig.TYCOON_LOW_WALL_HEIGHT,
		selfTable.Accent
	)
end

local function clearLowWalls(selfTable)
	clearBasePartList(selfTable.LowWallParts)
	clearFolder(selfTable.WallSetFolder)
end

local function ensureHighWalls(selfTable)
	if #selfTable.HighWallParts > 0 and selfTable.HighWallParts[1] and selfTable.HighWallParts[1].Parent then
		return
	end

	local folder = selfTable.StructuresFolder:FindFirstChild("HighWalls")
	if not folder or not folder:IsA("Folder") then
		folder = ensureFolder(selfTable.StructuresFolder, "HighWalls")
	end

	clearFolder(folder)
	selfTable.HighWallParts = createWallSet(
		folder,
		"HighWall",
		selfTable.Origin,
		GameConfig.TYCOON_HIGH_WALL_Y_OFFSET,
		GameConfig.TYCOON_HIGH_WALL_HEIGHT,
		Color3.fromRGB(49, 61, 104)
	)
end

local function clearHighWalls(selfTable)
	clearBasePartList(selfTable.HighWallParts)
	local folder = selfTable.StructuresFolder:FindFirstChild("HighWalls")
	if folder and folder:IsA("Folder") then
		clearFolder(folder)
	end
end

local function ensureDoorVisuals(selfTable)
	if selfTable.DoorFrame and selfTable.DoorFrame.Parent and selfTable.DoorPanel and selfTable.DoorPanel.Parent then
		return
	end

	local doorFolder = selfTable.StructuresFolder:FindFirstChild("Door")
	if not doorFolder or not doorFolder:IsA("Folder") then
		doorFolder = ensureFolder(selfTable.StructuresFolder, "Door")
	end

	destroyChild(doorFolder, "DoorFrame")
	destroyChild(doorFolder, "DoorPanel")
	destroyChild(doorFolder, "DoorSupportLeft")
	destroyChild(doorFolder, "DoorSupportRight")

	selfTable.DoorFrame = createPart(doorFolder, "DoorFrame", Vector3.new(GameConfig.TYCOON_ENTRY_FRAME_WIDTH, 14, 2), CFrame.new(selfTable.Origin + GameConfig.TYCOON_ENTRY_DOOR_OFFSET), {
		Color = Color3.fromRGB(24, 27, 34),
		Material = Enum.Material.Metal,
	})
	selfTable.DoorPanel = createPart(doorFolder, "DoorPanel", Vector3.new(GameConfig.TYCOON_ENTRY_PANEL_WIDTH, 10, 1), CFrame.new(selfTable.Origin + GameConfig.TYCOON_ENTRY_PANEL_OFFSET), {
		Color = Color3.fromRGB(162, 171, 192),
		Material = Enum.Material.Metal,
	})

	local supportX = (GameConfig.TYCOON_ENTRY_FRAME_WIDTH / 2) - (GameConfig.TYCOON_ENTRY_SIDE_SUPPORT_WIDTH / 2)
	local supportZ = GameConfig.TYCOON_ENTRY_DOOR_OFFSET.Z + ((GameConfig.TYCOON_ENTRY_SIDE_SUPPORT_DEPTH - 2) / 2)
	createPart(doorFolder, "DoorSupportLeft", Vector3.new(GameConfig.TYCOON_ENTRY_SIDE_SUPPORT_WIDTH, 14, GameConfig.TYCOON_ENTRY_SIDE_SUPPORT_DEPTH), CFrame.new(selfTable.Origin + Vector3.new(-supportX, GameConfig.TYCOON_ENTRY_DOOR_OFFSET.Y, supportZ)), {
		Color = Color3.fromRGB(34, 38, 48),
		Material = Enum.Material.Metal,
	})
	createPart(doorFolder, "DoorSupportRight", Vector3.new(GameConfig.TYCOON_ENTRY_SIDE_SUPPORT_WIDTH, 14, GameConfig.TYCOON_ENTRY_SIDE_SUPPORT_DEPTH), CFrame.new(selfTable.Origin + Vector3.new(supportX, GameConfig.TYCOON_ENTRY_DOOR_OFFSET.Y, supportZ)), {
		Color = Color3.fromRGB(34, 38, 48),
		Material = Enum.Material.Metal,
	})
end

local function clearDoorVisuals(selfTable)
	if selfTable.DoorFrame then
		selfTable.DoorFrame:Destroy()
		selfTable.DoorFrame = nil
	end

	if selfTable.DoorPanel then
		selfTable.DoorPanel:Destroy()
		selfTable.DoorPanel = nil
	end
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
		AutoCollectorMachine = refs.AutoCollectorMachine,
		CollectorPad = refs.CollectorPad,
		CollectorPrompt = refs.CollectorPrompt,
		CollectorLabel = refs.CollectorLabel,
		CollectorPoint = refs.CollectorPoint,
		CollectorTrigger = refs.CollectorTrigger,
		StarterClicker = refs.StarterClicker,
		StarterClickerPrompt = refs.StarterClickerPrompt,
		StarterClickerLabel = refs.StarterClickerLabel,
		RuntimeFolder = refs.RuntimeFolder,
		MoneyPartsFolder = refs.MoneyPartsFolder,
		EconomyFolder = refs.EconomyFolder,
		StructuresFolder = refs.StructuresFolder,
		ButtonsFolder = refs.ButtonsFolder,
		StructureSocketsFolder = refs.StructureSocketsFolder,
		SpawnPointsFolder = refs.SpawnPointsFolder,
		DropperModels = refs.DropperModels,
		DropperOutputs = refs.DropperOutputs,
		DropperRoots = refs.DropperRoots,
		LowWallParts = refs.LowWallParts,
		HighWallParts = refs.HighWallParts,
		WallSetFolder = refs.WallSetFolder,
		DoorFrame = refs.DoorFrame,
		DoorPanel = refs.DoorPanel,
		DoorSensor = refs.DoorSensor,
		DoorInnerSensor = refs.DoorInnerSensor,
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
		AutoCollectorMachine = refs.AutoCollectorMachine,
		CollectorPad = refs.CollectorPad,
		CollectorPrompt = refs.CollectorPrompt,
		CollectorLabel = refs.CollectorLabel,
		CollectorPoint = refs.CollectorPoint,
		CollectorTrigger = refs.CollectorTrigger,
		StarterClicker = refs.StarterClicker,
		StarterClickerPrompt = refs.StarterClickerPrompt,
		StarterClickerLabel = refs.StarterClickerLabel,
		RuntimeFolder = refs.RuntimeFolder,
		MoneyPartsFolder = refs.MoneyPartsFolder,
		EconomyFolder = refs.EconomyFolder,
		StructuresFolder = refs.StructuresFolder,
		ButtonsFolder = refs.ButtonsFolder,
		StructureSocketsFolder = refs.StructureSocketsFolder,
		SpawnPointsFolder = refs.SpawnPointsFolder,
		DropperModels = refs.DropperModels,
		DropperOutputs = refs.DropperOutputs,
		DropperRoots = refs.DropperRoots,
		LowWallParts = refs.LowWallParts,
		HighWallParts = refs.HighWallParts,
		WallSetFolder = refs.WallSetFolder,
		DoorFrame = refs.DoorFrame,
		DoorPanel = refs.DoorPanel,
		DoorSensor = refs.DoorSensor,
		DoorInnerSensor = refs.DoorInnerSensor,
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
	self.StarterClickerPrompt.Enabled = player ~= nil
	for _, doorButton in { self.DoorSensor, self.DoorInnerSensor } do
		local doorPrompt = doorButton:FindFirstChildOfClass("ProximityPrompt")
		if doorPrompt then
			doorPrompt.Enabled = player ~= nil
		end
	end

	if player then
		self.OwnerLabel.Text = string.format("%s's Tycoon", player.DisplayName)
		self.ClaimLabel.Text = player.Name
		self.ClaimPrompt.Enabled = false
		self.ClaimPad.Size = GameConfig.CLAIM_PAD_CLAIMED_SIZE
		self.ClaimPad.CFrame = CFrame.new(self.Origin + GameConfig.CLAIM_PAD_OFFSET)
		self.ClaimPad.Color = self.Accent
		self.OwnerUserIdValue.Value = player.UserId
		self.OwnerNameValue.Value = player.Name
		self.IsClaimedValue.Value = true
	else
		self.OwnerLabel.Text = "Unclaimed"
		self.ClaimLabel.Text = "Claim Tycoon"
		self.ClaimPrompt.Enabled = true
		self.ClaimPad.Size = GameConfig.CLAIM_PAD_UNCLAIMED_SIZE
		self.ClaimPad.CFrame = CFrame.new(self.Origin + GameConfig.CLAIM_PAD_OFFSET)
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

function Tycoon:updateCollectorDisplay(amount: number, autoCollectorActive: boolean?)
	if autoCollectorActive then
		self.CollectorLabel.Text = "Auto\nOnline"
		self.CollectorPrompt.ActionText = "Auto Collector"
	else
		self.CollectorLabel.Text = string.format("Stored\n$%d", amount)
		self.CollectorPrompt.ActionText = if amount > 0 then string.format("Collect $%d", amount) else "Collect $0"
	end
end

function Tycoon:applyVisualState(purchased: { [string]: boolean }, collectorStored: number)
	reconcileDropperVisuals(self, purchased)

	local showWallSet = purchased.wall_set_1 == true or purchased.front_door == true or purchased.reinforced_door == true or purchased.high_walls == true
	if showWallSet then
		ensureLowWalls(self)
	else
		clearLowWalls(self)
	end

	if purchased.high_walls == true then
		ensureHighWalls(self)
	else
		clearHighWalls(self)
	end

	local hasDoorUpgrade = purchased.front_door == true or purchased.reinforced_door == true
	if hasDoorUpgrade then
		ensureDoorVisuals(self)
	else
		clearDoorVisuals(self)
	end

	if purchased.auto_collector == true then
		ensureAutoCollectorMachine(self)
	else
		clearAutoCollectorMachine(self)
	end

	if purchased.premium_conveyor == true then
		ensurePremiumConveyorUpgrade(self)
	else
		clearPremiumConveyorUpgrade(self)
	end

	if purchased.cash_compressor == true then
		ensureCashCompressor(self)
	else
		clearCashCompressor(self)
	end

	if purchased.collector_array == true then
		ensureCollectorArray(self)
	else
		clearCollectorArray(self)
	end

	if purchased.security_lights == true then
		ensureSecurityLights(self)
	else
		clearSecurityLights(self)
	end

	if purchased.corner_posts == true then
		ensureCornerPosts(self)
	else
		clearCornerPosts(self)
	end

	if purchased.rear_extension == true then
		ensureRearExtension(self)
	else
		clearRearExtension(self)
	end

	if purchased.utility_bay == true then
		ensureUtilityBay(self)
	else
		clearUtilityBay(self)
	end

	if purchased.roof_frame == true then
		ensureRoofFrame(self)
	else
		clearRoofFrame(self)
	end

	setPartVisible(self.ClaimPad, true, 0)
	setPartVisible(self.OwnerSign, true, 0)
	setPartVisible(self.EarningsBoard, true, 0)
	setPartVisible(self.ConveyorBase, true, 0)
	setPartVisible(self.ConveyorStrip, true, 0)
	setPartVisible(self.ConveyorEntry, false)
	setPartVisible(self.CollectorPad, true, 0)
	setPartVisible(self.CollectorPoint, false)
	setPartVisible(self.CollectorTrigger, false)
	setPartVisible(self.StarterClicker, purchased.basic_dropper ~= true, 0)
	self.StarterClickerPrompt.Enabled = self.Owner ~= nil and purchased.basic_dropper ~= true
	self.StarterClicker.CanCollide = false
	self.StarterClicker.CanTouch = false
	self.StarterClicker.CanQuery = false
	if self.DoorFrame then
		setPartVisible(self.DoorFrame, hasDoorUpgrade, 0)
		self.DoorFrame.CanCollide = false
		self.DoorFrame.CanTouch = false
		self.DoorFrame.CanQuery = false
	end
	if self.DoorPanel then
		setPartVisible(self.DoorPanel, hasDoorUpgrade, 0)
	end
	local doorFolder = self.StructuresFolder:FindFirstChild("Door")
	if doorFolder then
		for _, child in doorFolder:GetChildren() do
			if child:IsA("BasePart") and child ~= self.DoorSensor and child ~= self.DoorInnerSensor and child ~= self.DoorFrame and child ~= self.DoorPanel then
				setPartVisible(child, hasDoorUpgrade, 0)
				child.CanCollide = false
				child.CanTouch = false
				child.CanQuery = false
			end
		end
	end
	setPartVisible(self.DoorSensor, hasDoorUpgrade, 0)
	self.DoorSensor.Color = if purchased.reinforced_door then Color3.fromRGB(255, 178, 79) else self.Accent
	self.DoorSensor.CanCollide = false
	self.DoorSensor.CanTouch = false
	self.DoorSensor.CanQuery = false
	setPartVisible(self.DoorInnerSensor, hasDoorUpgrade, 0)
	self.DoorInnerSensor.Color = if purchased.reinforced_door then Color3.fromRGB(255, 178, 79) else self.Accent
	self.DoorInnerSensor.CanCollide = false
	self.DoorInnerSensor.CanTouch = false
	self.DoorInnerSensor.CanQuery = false

	setModelVisible(self.CollectorMachine, true, 0)
	for upgradeId, model in self.DropperModels do
		if model then
			setModelVisible(model, purchased[upgradeId] == true, 0)
		end
	end
	if self.AutoCollectorMachine then
		setModelVisible(self.AutoCollectorMachine, purchased.auto_collector == true, 0)
		self.AutoCollectorMachine.PrimaryPart.Color = if purchased.auto_collector then Color3.fromRGB(172, 255, 220) else Color3.fromRGB(98, 245, 182)
	end

	if self.DoorPanel then
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
	end

	if purchased.premium_conveyor then
		self.ConveyorStrip.Color = Color3.fromRGB(120, 255, 197)
		self.ConveyorStrip.Material = Enum.Material.Neon
	elseif purchased.conveyor_speed then
		self.ConveyorStrip.Color = Color3.fromRGB(255, 230, 132)
		self.ConveyorStrip.Material = Enum.Material.Neon
	else
		self.ConveyorStrip.Color = Color3.fromRGB(109, 122, 255)
		self.ConveyorStrip.Material = Enum.Material.Neon
	end

	if purchased.cash_compressor then
		self.CollectorMachine.PrimaryPart.Color = Color3.fromRGB(255, 126, 126)
	elseif purchased.collector then
		self.CollectorMachine.PrimaryPart.Color = Color3.fromRGB(255, 215, 128)
	else
		self.CollectorMachine.PrimaryPart.Color = Color3.fromRGB(255, 182, 72)
	end
	self.EarningsLabel.Text = string.format("Earnings\n$%.1f/sec", computeEarningsPerSecond(purchased))
	self:updateCollectorDisplay(collectorStored, purchased.auto_collector == true)
	self.CollectorPrompt.Enabled = self.Owner ~= nil and purchased.auto_collector ~= true
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
