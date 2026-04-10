local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)
local SecondFloorConfig = require(ReplicatedStorage.Modules.SecondFloorConfig)
local ThirdFloorConfig = require(ReplicatedStorage.Modules.ThirdFloorConfig)

local Tycoon = {}
Tycoon.__index = Tycoon

local SECOND_FLOOR_UPGRADE_ORDER = {
	"second_floor",
	"upper_walls",
	"upper_conveyor",
	"upper_collector",
	"upper_dropper_1",
	"upper_dropper_2",
	"upper_dropper_3",
	"upper_dropper_4",
}

local SECOND_FLOOR_DROPPER_ORDER = {
	"upper_dropper_1",
	"upper_dropper_2",
	"upper_dropper_3",
	"upper_dropper_4",
}

local THIRD_FLOOR_UPGRADE_ORDER = {
	"third_floor",
	"third_floor_walls",
	"third_conveyor",
	"third_dropper_1",
	"third_dropper_2",
	"third_dropper_3",
	"third_dropper_4",
	"third_collector",
}

local THIRD_FLOOR_DROPPER_ORDER = {
	"third_dropper_1",
	"third_dropper_2",
	"third_dropper_3",
	"third_dropper_4",
}

local SECOND_FLOOR_BUTTON_LAYOUTS = {
	second_floor = {
		offset = Vector3.new(48, 1.3, 72),
	},
	upper_walls = {
		offset = Vector3.new(-42, SecondFloorConfig.BASE_Y_OFFSET + 1.3, 24),
	},
	upper_conveyor = {
		offset = Vector3.new(SecondFloorConfig.UPPER_CONVEYOR_X_OFFSET - 11, SecondFloorConfig.BASE_Y_OFFSET + 1.3, SecondFloorConfig.UPPER_CONVEYOR_Z_OFFSET - 10),
	},
	upper_collector = {
		offset = Vector3.new(SecondFloorConfig.UPPER_CONVEYOR_X_OFFSET - 11, SecondFloorConfig.BASE_Y_OFFSET + 1.3, SecondFloorConfig.UPPER_COLLECTOR_PAD_Z_OFFSET),
	},
	upper_dropper_1 = {
		offset = Vector3.new(-22, SecondFloorConfig.BASE_Y_OFFSET + 1.3, 22),
	},
	upper_dropper_2 = {
		offset = Vector3.new(30, SecondFloorConfig.BASE_Y_OFFSET + 1.3, 22),
	},
	upper_dropper_3 = {
		offset = Vector3.new(-22, SecondFloorConfig.BASE_Y_OFFSET + 1.3, 44),
	},
	upper_dropper_4 = {
		offset = Vector3.new(30, SecondFloorConfig.BASE_Y_OFFSET + 1.3, 44),
	},
}

local SECOND_FLOOR_DROPPER_COLORS = {
	upper_dropper_1 = Color3.fromRGB(116, 235, 255),
	upper_dropper_2 = Color3.fromRGB(255, 202, 102),
	upper_dropper_3 = Color3.fromRGB(255, 135, 182),
	upper_dropper_4 = Color3.fromRGB(168, 255, 190),
}

local THIRD_FLOOR_DROPPER_COLORS = {
	third_dropper_1 = Color3.fromRGB(255, 168, 228),
	third_dropper_2 = Color3.fromRGB(170, 245, 255),
	third_dropper_3 = Color3.fromRGB(255, 220, 148),
	third_dropper_4 = Color3.fromRGB(208, 168, 255),
}

export type Definition = {
	Id: string,
	Origin: Vector3,
	Accent: Color3,
	MapSide: string?,
	FacingYaw: number?,
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
	FacingYaw: number,
	BaseCFrame: CFrame,
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
	RepairConsole: BasePart,
	RepairPrompt: ProximityPrompt,
	RepairLabel: TextLabel,
	RaidConsole: BasePart,
	RaidPrompt: ProximityPrompt,
	RaidLabel: TextLabel,
	RaidBreachPad: BasePart,
	RaidBreachPrompt: ProximityPrompt,
	RaidBreachLabel: TextLabel,
	RaidStatusSign: BasePart,
	RaidStatusLabel: TextLabel,
	StarterDropperModel: Model,
	StarterClicker: BasePart,
	StarterClickerOutput: BasePart,
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
	WallHealthStates: { [string]: { current: number, max: number, part: BasePart? } },
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
	updateWallRepairDisplay: (self: TycoonObject) -> (),
	updateRaidDisplay: (self: TycoonObject, isOpen: boolean, summaryText: string, breachEnabled: boolean, isBreached: boolean) -> (),
	resetWallHealth: (self: TycoonObject) -> (),
	damageWallPart: (self: TycoonObject, wallPart: BasePart, amount: number) -> boolean,
	repairWalls: (self: TycoonObject, repairAmount: number?) -> number,
	getWallRepairCost: (self: TycoonObject) -> number,
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

local function getFacingYaw(source): number
	return source.FacingYaw or 0
end

local function getBaseCFrame(source): CFrame
	return source.BaseCFrame or (CFrame.new(source.Origin) * CFrame.Angles(0, math.rad(getFacingYaw(source)), 0))
end

local function getWorldPosition(source, localOffset: Vector3): Vector3
	return getBaseCFrame(source):PointToWorldSpace(localOffset)
end

local function getWorldCFrame(source, localOffset: Vector3, localYawDegrees: number?): CFrame
	return getBaseCFrame(source) * CFrame.new(localOffset) * CFrame.Angles(0, math.rad(localYawDegrees or 0), 0)
end

local function getDropperRootCFrame(source, dropperOffset: Vector3): CFrame
	local localYaw = if dropperOffset.X < GameConfig.TYCOON_CONVEYOR_X_OFFSET then -90 else 90
	return getWorldCFrame(source, dropperOffset, localYaw)
end

local function createCollectorMachine(parent: Instance, name: string, origin: CFrame, accent: Color3)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent

	createPart(model, "Base", Vector3.new(12, 2, 10), origin * CFrame.new(0, 1, 0), {
		Color = Color3.fromRGB(42, 48, 59),
		Material = Enum.Material.Metal,
	})
	local core = createPart(model, "Core", Vector3.new(8, 6, 6), origin * CFrame.new(0, 5, 0), {
		Color = accent,
		Material = Enum.Material.Neon,
	})
	createPart(model, "Pipe", Vector3.new(2, 4, 2), origin * CFrame.new(0, 7, -2), {
		Color = Color3.fromRGB(110, 118, 130),
		Material = Enum.Material.Metal,
	})
	createPart(model, "Display", Vector3.new(4, 2, 0.5), origin * CFrame.new(0, 5, 3), {
		Color = Color3.fromRGB(23, 26, 33),
		Material = Enum.Material.SmoothPlastic,
	})

	model.PrimaryPart = core
	return model
end

local function createStarterDropperMachine(parent: Instance, source)
	local model = Instance.new("Model")
	model.Name = "StarterDropperMachine"
	model.Parent = parent

	local base = createPart(model, "Base", Vector3.new(14, 2, 12), getWorldCFrame(source, GameConfig.TYCOON_CLICKER_OFFSET), {
		Color = Color3.fromRGB(46, 52, 66),
		Material = Enum.Material.Metal,
	})
	local body = createPart(model, "Body", Vector3.new(10, 6, 8), getWorldCFrame(source, GameConfig.TYCOON_CLICKER_OFFSET + Vector3.new(0, 4, 0)), {
		Color = Color3.fromRGB(91, 234, 176),
		Material = Enum.Material.Metal,
	})
	local trim = createPart(model, "Trim", Vector3.new(10, 1, 8), getWorldCFrame(source, GameConfig.TYCOON_CLICKER_OFFSET + Vector3.new(0, 7.5, 0)), {
		Color = Color3.fromRGB(181, 255, 221),
		Material = Enum.Material.Neon,
	})
	local nozzle = createPart(model, "Nozzle", Vector3.new(3, 2, 5), getWorldCFrame(source, GameConfig.TYCOON_CLICKER_OFFSET + Vector3.new(-2.5, 5.2, -4), -90), {
		Color = Color3.fromRGB(210, 218, 232),
		Material = Enum.Material.SmoothPlastic,
	})
	local button = createPart(model, "Button", Vector3.new(5, 1, 5), getWorldCFrame(source, GameConfig.TYCOON_STARTER_BUTTON_OFFSET), {
		Color = Color3.fromRGB(255, 208, 118),
		Material = Enum.Material.Neon,
	})
	button.CanCollide = false
	button.CanTouch = false
	button.CanQuery = false

	local outputPoint = createPart(model, "OutputPoint", Vector3.new(1, 1, 1), getWorldCFrame(source, GameConfig.TYCOON_STARTER_OUTPUT_OFFSET), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
	model.PrimaryPart = body

	ensureSurfaceLabel(body, "Starter\nDropper", Enum.NormalId.Front, Color3.fromRGB(255, 255, 255))
	local buttonLabel = ensureSurfaceLabel(button, "DROP\nCASH", Enum.NormalId.Top, Color3.fromRGB(63, 44, 18))

	return model, button, outputPoint, buttonLabel
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

local function getUpgradeDefinition(upgradeId: string)
	return GameConfig.getUpgrade(upgradeId) or SecondFloorConfig.getUpgrade(upgradeId)
end

local function getAllUpgradeOrder(): { string }
	local upgradeOrder = table.clone(GameConfig.UPGRADE_ORDER)

	for _, upgradeId in SECOND_FLOOR_UPGRADE_ORDER do
		if not table.find(upgradeOrder, upgradeId) then
			table.insert(upgradeOrder, upgradeId)
		end
	end

	return upgradeOrder
end

local function getButtonLaneCenterZ(): number
	local buttonCount = #GameConfig.UPGRADE_ORDER
	local endZ = GameConfig.BUTTON_LANE_START_Z + ((buttonCount - 1) * GameConfig.BUTTON_LANE_STEP_Z)
	return (GameConfig.BUTTON_LANE_START_Z + endZ) / 2
end

local function createUpgradeButton(parent: Instance, source, accent: Color3, upgradeId: string, index: number): UpgradeButton
	local upgrade = getUpgradeDefinition(upgradeId)
	if not upgrade then
		error(string.format("Missing upgrade definition for %s", upgradeId))
	end

	local layout = GameConfig.BUTTON_LAYOUTS[upgradeId] or SECOND_FLOOR_BUTTON_LAYOUTS[upgradeId]
	local buttonSize = GameConfig.BUTTON_PAD_SIZE
	local localPosition = if layout and typeof(layout.offset) == "Vector3"
		then layout.offset
		else Vector3.new(0, 0.6, GameConfig.BUTTON_LANE_START_Z + ((index - 1) * GameConfig.BUTTON_LANE_STEP_Z))

	local buttonPart = createPart(parent, upgradeId, buttonSize, getWorldCFrame(source, localPosition), {
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

local function createWallSet(parent: Instance, source, prefix: string, yOffset: number, wallHeight: number, accent: Color3)
	return {
		createPart(parent, prefix .. "Back", Vector3.new(GameConfig.TYCOON_WALL_BACK_WIDTH, wallHeight, 2), getWorldCFrame(source, Vector3.new(0, yOffset, GameConfig.TYCOON_WALL_BACK_Z)), {
			Color = accent,
			Material = Enum.Material.Metal,
		}),
		createPart(parent, prefix .. "Left", Vector3.new(2, wallHeight, GameConfig.TYCOON_WALL_SIDE_LENGTH), getWorldCFrame(source, Vector3.new(-GameConfig.TYCOON_WALL_SIDE_X, yOffset, 0)), {
			Color = accent,
			Material = Enum.Material.Metal,
		}),
		createPart(parent, prefix .. "Right", Vector3.new(2, wallHeight, GameConfig.TYCOON_WALL_SIDE_LENGTH), getWorldCFrame(source, Vector3.new(GameConfig.TYCOON_WALL_SIDE_X, yOffset, 0)), {
			Color = accent,
			Material = Enum.Material.Metal,
		}),
		createPart(parent, prefix .. "FrontLeft", Vector3.new(GameConfig.TYCOON_WALL_FRONT_SEGMENT_WIDTH, wallHeight, 2), getWorldCFrame(source, Vector3.new(GameConfig.TYCOON_WALL_FRONT_LEFT_X, yOffset, GameConfig.TYCOON_WALL_FRONT_Z)), {
			Color = accent,
			Material = Enum.Material.Metal,
		}),
		createPart(parent, prefix .. "FrontRight", Vector3.new(GameConfig.TYCOON_WALL_FRONT_SEGMENT_WIDTH, wallHeight, 2), getWorldCFrame(source, Vector3.new(GameConfig.TYCOON_WALL_FRONT_RIGHT_X, yOffset, GameConfig.TYCOON_WALL_FRONT_Z)), {
			Color = accent,
			Material = Enum.Material.Metal,
		}),
	}
end

local function refreshWallPartState(wallState, part: BasePart?)
	local targetPart = part or wallState.part
	if not targetPart then
		return
	end

	local ratio = if wallState.max > 0 then math.clamp(wallState.current / wallState.max, 0, 1) else 0
	targetPart:SetAttribute("WallSegmentId", targetPart.Name)
	targetPart:SetAttribute("WallHealth", wallState.current)
	targetPart:SetAttribute("WallMaxHealth", wallState.max)

	if ratio <= 0 then
		targetPart.Transparency = 1
		targetPart.CanCollide = false
		targetPart.CanTouch = false
		targetPart.CanQuery = false
		return
	end

	local baseColor = targetPart:GetAttribute("WallBaseColor")
	local healthyColor = if typeof(baseColor) == "Color3" then baseColor else targetPart.Color
	targetPart.Color = healthyColor:Lerp(Color3.fromRGB(190, 74, 74), 1 - ratio)
	targetPart.Transparency = 0.04 + ((1 - ratio) * 0.32)
	targetPart.CanCollide = true
	targetPart.CanTouch = true
	targetPart.CanQuery = true
end

local function registerWallParts(selfTable, parts: { BasePart })
	for _, part in parts do
		local wallId = part.Name
		local existingState = selfTable.WallHealthStates[wallId]
		if not existingState then
			existingState = {
				current = GameConfig.TYCOON_WALL_MAX_HEALTH,
				max = GameConfig.TYCOON_WALL_MAX_HEALTH,
				part = part,
			}
			selfTable.WallHealthStates[wallId] = existingState
		else
			existingState.max = GameConfig.TYCOON_WALL_MAX_HEALTH
			existingState.current = math.clamp(existingState.current, 0, existingState.max)
			existingState.part = part
		end

		part:SetAttribute("WallTycoonId", selfTable.Id)
		part:SetAttribute("WallBaseColor", part.Color)
		refreshWallPartState(existingState, part)
	end
end

local function clearRegisteredWallParts(parts: { BasePart }, wallStates)
	for _, part in parts do
		local wallId = part.Name
		local wallState = wallStates[wallId]
		if wallState then
			wallState.part = nil
		end
	end
end

local function createDeckTrim(parent: Instance, source, prefix: string, centerOffset: Vector3, deckSize: Vector3, accent: Color3, baseColor: Color3)
	local halfX = deckSize.X / 2
	local halfZ = deckSize.Z / 2
	local y = centerOffset.Y + (deckSize.Y / 2) + 0.55

	createPart(parent, prefix .. "OutlineFront", Vector3.new(deckSize.X, 0.6, 2), getWorldCFrame(source, Vector3.new(centerOffset.X, y, centerOffset.Z - halfZ + 1)), {
		Color = baseColor,
		Material = Enum.Material.Metal,
	})
	createPart(parent, prefix .. "OutlineBack", Vector3.new(deckSize.X, 0.6, 2), getWorldCFrame(source, Vector3.new(centerOffset.X, y, centerOffset.Z + halfZ - 1)), {
		Color = baseColor,
		Material = Enum.Material.Metal,
	})
	createPart(parent, prefix .. "OutlineLeft", Vector3.new(2, 0.6, deckSize.Z - 4), getWorldCFrame(source, Vector3.new(centerOffset.X - halfX + 1, y, centerOffset.Z)), {
		Color = baseColor,
		Material = Enum.Material.Metal,
	})
	createPart(parent, prefix .. "OutlineRight", Vector3.new(2, 0.6, deckSize.Z - 4), getWorldCFrame(source, Vector3.new(centerOffset.X + halfX - 1, y, centerOffset.Z)), {
		Color = baseColor,
		Material = Enum.Material.Metal,
	})
	createPart(parent, prefix .. "GlowLineA", Vector3.new(deckSize.X - 12, 0.18, 1.2), getWorldCFrame(source, Vector3.new(centerOffset.X, y + 0.15, centerOffset.Z - (halfZ * 0.28))), {
		Color = accent,
		Material = Enum.Material.Neon,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
	createPart(parent, prefix .. "GlowLineB", Vector3.new(deckSize.X - 12, 0.18, 1.2), getWorldCFrame(source, Vector3.new(centerOffset.X, y + 0.15, centerOffset.Z + (halfZ * 0.28))), {
		Color = accent,
		Material = Enum.Material.Neon,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
end

local function createBaseFloorDecor(parent: Instance, source, accent: Color3)
	local decorFolder = ensureFolder(parent, "BaseFloorDecor")
	clearFolder(decorFolder)

	createDeckTrim(decorFolder, source, "Base", Vector3.zero, GameConfig.TYCOON_SIZE, accent, Color3.fromRGB(70, 77, 95))
	createPart(decorFolder, "EntryWalkway", Vector3.new(28, 0.4, 24), getWorldCFrame(source, Vector3.new(0, 1.25, -44)), {
		Color = Color3.fromRGB(73, 81, 99),
		Material = Enum.Material.DiamondPlate,
	})
	createPart(decorFolder, "FactoryWalkway", Vector3.new(22, 0.35, 96), getWorldCFrame(source, Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET + 10, 1.22, 2)), {
		Color = Color3.fromRGB(58, 64, 79),
		Material = Enum.Material.Metal,
	})
	createPart(decorFolder, "UtilityWalkway", Vector3.new(24, 0.35, 106), getWorldCFrame(source, Vector3.new(49, 1.22, 4)), {
		Color = Color3.fromRGB(53, 59, 75),
		Material = Enum.Material.Metal,
	})
	createPart(decorFolder, "CenterStrip", Vector3.new(12, 0.2, 128), getWorldCFrame(source, Vector3.new(0, 1.28, 0)), {
		Color = accent,
		Material = Enum.Material.Neon,
		Transparency = 0.2,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
	createPart(decorFolder, "ArmoryStencil", Vector3.new(18, 0.2, 28), getWorldCFrame(source, Vector3.new(47, 1.3, 2)), {
		Color = Color3.fromRGB(255, 196, 118),
		Material = Enum.Material.Neon,
		Transparency = 0.35,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
end

local function ensureSpawnPoints(model: Model, source): Folder
	local spawnPoints = ensureFolder(model, "SpawnPoints")
	clearFolder(spawnPoints)

	local spawnLocation = Instance.new("SpawnLocation")
	spawnLocation.Name = "TycoonSpawn"
	spawnLocation.Size = Vector3.new(12, 1, 12)
	spawnLocation.CFrame = getWorldCFrame(source, GameConfig.TYCOON_SPAWN_OFFSET)
	spawnLocation.Anchored = true
	spawnLocation.Enabled = false
	spawnLocation.Neutral = false
	spawnLocation.Parent = spawnPoints

	createPart(spawnPoints, "SpawnMarker", Vector3.new(1, 1, 1), spawnLocation.CFrame * CFrame.new(0, 1.5, 0), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})

	return spawnPoints
end

local function ensureWeek3Scaffolding(model: Model, definition: Definition)
	local origin = definition.Origin
	local source = {
		Origin = definition.Origin,
		FacingYaw = definition.FacingYaw or 0,
	}

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
	destroyChild(model, "BaseFloorDecor")
	destroyChild(model, "LowWalls")
	destroyChild(model, "HighWalls")
	destroyChild(model, "Door")

	local baseFloor = ensurePart(model, "BaseFloor", GameConfig.TYCOON_SIZE, getWorldCFrame(source, Vector3.zero), {
		Color = Color3.fromRGB(44, 47, 57),
		Material = Enum.Material.Slate,
	})
	createBaseFloorDecor(model, source, definition.Accent)

	local claimPad = ensurePart(model, "ClaimPad", GameConfig.CLAIM_PAD_UNCLAIMED_SIZE, getWorldCFrame(source, GameConfig.CLAIM_PAD_OFFSET), {
		Color = Color3.fromRGB(63, 215, 120),
		Material = Enum.Material.Neon,
	})

	local ownerSign = ensurePart(model, "OwnerSign", Vector3.new(22, 8, 1), getWorldCFrame(source, Vector3.new(0, 9, GameConfig.TYCOON_WALL_FRONT_Z - 1)), {
		Color = Color3.fromRGB(22, 24, 31),
		Material = Enum.Material.SmoothPlastic,
	})

	local earningsBoard = ensurePart(model, "EarningsBoard", Vector3.new(20, 8, 1), getWorldCFrame(source, GameConfig.EARNINGS_BOARD_OFFSET), {
		Color = Color3.fromRGB(26, 31, 41),
		Material = Enum.Material.SmoothPlastic,
	})

	local spawnPointsFolder = ensureSpawnPoints(model, source)

	local structureSocketsFolder = ensureFolder(model, "StructureSockets")
	clearFolder(structureSocketsFolder)
	createPart(structureSocketsFolder, "ClaimSocket", Vector3.new(1, 1, 1), getWorldCFrame(source, Vector3.new(0, 1, -32)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
	createPart(structureSocketsFolder, "ConveyorSocket", Vector3.new(1, 1, 1), getWorldCFrame(source, Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET, 1, GameConfig.TYCOON_CONVEYOR_Z_OFFSET)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
	createPart(structureSocketsFolder, "CollectorSocket", Vector3.new(1, 1, 1), getWorldCFrame(source, Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET, 1, GameConfig.TYCOON_COLLECTOR_Z_OFFSET)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
	createPart(structureSocketsFolder, "ButtonLaneSocket", Vector3.new(1, 1, 1), getWorldCFrame(source, Vector3.new(GameConfig.BUTTON_LANE_X_OFFSET, 1, 0)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
	createPart(structureSocketsFolder, "DoorSocket", Vector3.new(1, 1, 1), getWorldCFrame(source, Vector3.new(GameConfig.TYCOON_ENTRY_DOOR_OFFSET.X, 1, GameConfig.TYCOON_ENTRY_DOOR_OFFSET.Z)), {
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

	local conveyorBase = ensurePart(economyFolder, "ConveyorBase", Vector3.new(10, 1, GameConfig.TYCOON_CONVEYOR_LENGTH), getWorldCFrame(source, Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET, 1.25, GameConfig.TYCOON_CONVEYOR_Z_OFFSET)), {
		Color = Color3.fromRGB(52, 58, 71),
		Material = Enum.Material.Metal,
	})
	local conveyorStrip = ensurePart(economyFolder, "ConveyorStrip", Vector3.new(6, 0.35, GameConfig.TYCOON_CONVEYOR_LENGTH), getWorldCFrame(source, Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET, 1.9, GameConfig.TYCOON_CONVEYOR_Z_OFFSET)), {
		Color = Color3.fromRGB(109, 122, 255),
		Material = Enum.Material.Neon,
	})
	local conveyorEntry = ensurePart(economyFolder, "ConveyorEntry", Vector3.new(1, 1, 1), getWorldCFrame(source, Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET, 5.25, GameConfig.TYCOON_CONVEYOR_ENTRY_Z_OFFSET)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})

	local collectorMachine = createCollectorMachine(economyFolder, "CollectorMachine", getWorldCFrame(source, Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET, 0, GameConfig.TYCOON_COLLECTOR_Z_OFFSET)), Color3.fromRGB(255, 182, 72))
	labelMachine(collectorMachine, "Collector", Color3.fromRGB(255, 231, 154))
	local collectorPad = ensurePart(economyFolder, "CollectorPad", Vector3.new(16, 1, 12), getWorldCFrame(source, Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET, 1.5, GameConfig.TYCOON_COLLECTOR_PAD_Z_OFFSET)), {
		Color = Color3.fromRGB(255, 182, 72),
		Material = Enum.Material.Neon,
	})
	local collectorLabel = ensureSurfaceLabel(collectorPad, "Stored\n$0", Enum.NormalId.Top, Color3.new(1, 1, 1))
	local collectorPrompt = ensurePrompt(collectorPad, "Collect $0", "Collector", GameConfig.COLLECTOR_PROMPT_RANGE)
	local collectorPoint = ensurePart(economyFolder, "CollectorPoint", Vector3.new(1, 1, 1), getWorldCFrame(source, Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET, 3.2, GameConfig.TYCOON_COLLECTOR_Z_OFFSET)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
	local collectorTrigger = ensurePart(economyFolder, "CollectorTrigger", Vector3.new(14, 3, 12), getWorldCFrame(source, Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET, 2.5, GameConfig.TYCOON_COLLECTOR_PAD_Z_OFFSET)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = true,
		CanQuery = false,
	})
	local repairConsole = ensurePart(economyFolder, "RepairConsole", Vector3.new(12, 6, 8), getWorldCFrame(source, GameConfig.TYCOON_WALL_REPAIR_CONSOLE_OFFSET), {
		Color = Color3.fromRGB(46, 56, 68),
		Material = Enum.Material.Metal,
	})
	local repairLabel = ensureSurfaceLabel(repairConsole, "Walls\n5000/5000", Enum.NormalId.Front, Color3.fromRGB(255, 230, 196))
	local repairPrompt = ensurePrompt(repairConsole, "Rebuild Walls", "Wall Repair Console", GameConfig.TYCOON_WALL_REPAIR_PROMPT_RANGE)
	local raidConsole = ensurePart(economyFolder, "RaidConsole", Vector3.new(12, 6, 8), getWorldCFrame(source, GameConfig.TYCOON_RAID_CONSOLE_OFFSET), {
		Color = Color3.fromRGB(58, 64, 86),
		Material = Enum.Material.Metal,
	})
	local raidLabel = ensureSurfaceLabel(raidConsole, "Raid\nClosed", Enum.NormalId.Front, Color3.fromRGB(216, 226, 255))
	local raidPrompt = ensurePrompt(raidConsole, "Open Raid", "Raid Console", GameConfig.TYCOON_WALL_REPAIR_PROMPT_RANGE)
	local raidStatusSign = ensurePart(economyFolder, "RaidStatusSign", Vector3.new(18, 7, 1), getWorldCFrame(source, GameConfig.TYCOON_RAID_STATUS_SIGN_OFFSET), {
		Color = Color3.fromRGB(23, 27, 38),
		Material = Enum.Material.SmoothPlastic,
	})
	local raidStatusLabel = ensureSurfaceLabel(raidStatusSign, "Raid Closed", Enum.NormalId.Front, Color3.fromRGB(210, 220, 240))
	local raidBreachPad = ensurePart(economyFolder, "RaidBreachPad", Vector3.new(12, 1, 8), getWorldCFrame(source, GameConfig.TYCOON_RAID_BREACH_PAD_OFFSET), {
		Color = Color3.fromRGB(210, 96, 96),
		Material = Enum.Material.Neon,
	})
	local raidBreachLabel = ensureSurfaceLabel(raidBreachPad, "Raid\nLocked", Enum.NormalId.Top, Color3.fromRGB(52, 16, 16))
	local raidBreachPrompt = ensurePrompt(raidBreachPad, "Breach Door", "Raid Breach", GameConfig.BUTTON_PROMPT_RANGE)
	local starterDropperModel, starterClicker, starterClickerOutput, starterClickerLabel = createStarterDropperMachine(economyFolder, source)
	local starterClickerPrompt = ensurePrompt(starterClicker, "Drop Cash", "Starter Dropper", GameConfig.BUTTON_PROMPT_RANGE)
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
	local doorSensor = createPart(doorFolder, "DoorSensor", Vector3.new(4, 4, 2), getWorldCFrame(source, GameConfig.TYCOON_ENTRY_SENSOR_OFFSET), {
		Color = Color3.fromRGB(39, 45, 61),
		Material = Enum.Material.Neon,
		Transparency = 0,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
	ensureSurfaceLabel(doorSensor, "Owner\nDoor", Enum.NormalId.Front, Color3.new(1, 1, 1))
	local doorInnerSensor = createPart(doorFolder, "DoorInnerSensor", Vector3.new(4, 4, 2), getWorldCFrame(source, GameConfig.TYCOON_ENTRY_INSIDE_SENSOR_OFFSET), {
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
	local buttonGuide = createPart(buttonsFolder, "UpgradeGuide", Vector3.new(14, 1, 10), getWorldCFrame(source, Vector3.new(40, 1.25, 17)), {
		Color = Color3.fromRGB(31, 34, 45),
		Material = Enum.Material.SmoothPlastic,
	})
	ensureSurfaceLabel(buttonGuide, "Upgrade Pads", Enum.NormalId.Top, Color3.fromRGB(235, 235, 235))

	local buttonsOrigin = source
	local upgradeButtons = {}
	for index, upgradeId in getAllUpgradeOrder() do
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
		local rootCFrame = getDropperRootCFrame(source, dropperConfig.offset)
		dropperOutputs[upgradeId] = createPart(dropperSocketsFolder, upgradeId .. "OutputSocket", Vector3.new(1, 1, 1), rootCFrame * CFrame.new(0, 5.5, -4.5), {
			Transparency = 1,
			CanCollide = false,
			CanTouch = false,
			CanQuery = false,
		})
	end

	for index, upgradeId in SECOND_FLOOR_DROPPER_ORDER do
		local offset = SecondFloorConfig.UPPER_DROP_OFFSETS[index]
		local localYaw = if offset.X < SecondFloorConfig.UPPER_CONVEYOR_X_OFFSET then -90 else 90
		local rootCFrame = getWorldCFrame(source, Vector3.new(offset.X, SecondFloorConfig.BASE_Y_OFFSET + offset.Y, offset.Z), localYaw)

		dropperOutputs[upgradeId] = createPart(dropperSocketsFolder, upgradeId .. "OutputSocket", Vector3.new(1, 1, 1), rootCFrame * CFrame.new(0, 5.5, -4.5), {
			Transparency = 1,
			CanCollide = false,
			CanTouch = false,
			CanQuery = false,
		})
	end

	for index, upgradeId in THIRD_FLOOR_DROPPER_ORDER do
		local offset = ThirdFloorConfig.DROP_OFFSETS[index]
		local localYaw = if offset.X < ThirdFloorConfig.CONVEYOR_X_OFFSET then -90 else 90
		local rootCFrame = getWorldCFrame(source, Vector3.new(offset.X, ThirdFloorConfig.BASE_Y_OFFSET + offset.Y, offset.Z), localYaw)

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
		RepairConsole = repairConsole,
		RepairPrompt = repairPrompt,
		RepairLabel = repairLabel,
		RaidConsole = raidConsole,
		RaidPrompt = raidPrompt,
		RaidLabel = raidLabel,
		RaidBreachPad = raidBreachPad,
		RaidBreachPrompt = raidBreachPrompt,
		RaidBreachLabel = raidBreachLabel,
		RaidStatusSign = raidStatusSign,
		RaidStatusLabel = raidStatusLabel,
		StarterDropperModel = starterDropperModel,
		StarterClicker = starterClicker,
		StarterClickerOutput = starterClickerOutput,
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
		WallHealthStates = {},
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
		getDropperRootCFrame(selfTable, dropperConfig.offset),
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

local function getUpperDropperRootCFrame(source, index: number): CFrame
	local offset = SecondFloorConfig.UPPER_DROP_OFFSETS[index]
	local localYaw = if offset.X < SecondFloorConfig.UPPER_CONVEYOR_X_OFFSET then -90 else 90
	return getWorldCFrame(source, Vector3.new(offset.X, SecondFloorConfig.BASE_Y_OFFSET + offset.Y, offset.Z), localYaw)
end

local function ensureUpperDropperVisual(selfTable, upgradeId: string)
	local existing = selfTable.DropperModels[upgradeId]
	if existing and existing.Parent then
		return existing
	end

	local dropperIndex = table.find(SECOND_FLOOR_DROPPER_ORDER, upgradeId)
	if not dropperIndex then
		return nil
	end

	local droppersFolder = selfTable.EconomyFolder:FindFirstChild("Droppers")
	if not droppersFolder or not droppersFolder:IsA("Folder") then
		return nil
	end

	local model = select(1, createDropperModel(
		droppersFolder,
		formatUpgradeModelName(upgradeId),
		getUpperDropperRootCFrame(selfTable, dropperIndex),
		SECOND_FLOOR_DROPPER_COLORS[upgradeId] or selfTable.Accent,
		false
	))
	selfTable.DropperModels[upgradeId] = model
	return model
end

local function getThirdDropperRootCFrame(source, index: number): CFrame
	local offset = ThirdFloorConfig.DROP_OFFSETS[index]
	local localYaw = if offset.X < ThirdFloorConfig.CONVEYOR_X_OFFSET then -90 else 90
	return getWorldCFrame(source, Vector3.new(offset.X, ThirdFloorConfig.BASE_Y_OFFSET + offset.Y, offset.Z), localYaw)
end

local function ensureThirdDropperVisual(selfTable, upgradeId: string)
	local existing = selfTable.DropperModels[upgradeId]
	if existing and existing.Parent then
		return existing
	end

	local dropperIndex = table.find(THIRD_FLOOR_DROPPER_ORDER, upgradeId)
	if not dropperIndex then
		return nil
	end

	local droppersFolder = selfTable.EconomyFolder:FindFirstChild("Droppers")
	if not droppersFolder or not droppersFolder:IsA("Folder") then
		return nil
	end

	local model = select(1, createDropperModel(
		droppersFolder,
		formatUpgradeModelName(upgradeId),
		getThirdDropperRootCFrame(selfTable, dropperIndex),
		THIRD_FLOOR_DROPPER_COLORS[upgradeId] or selfTable.Accent,
		false
	))
	selfTable.DropperModels[upgradeId] = model
	return model
end

local function ensureSecondFloorFoundation(selfTable)
	local folder = ensureFolder(selfTable.StructuresFolder, "SecondFloor")
	if #folder:GetChildren() > 0 then
		return
	end

	local upperOrigin = SecondFloorConfig.FOUNDATION_OFFSET
	local foundationSize = SecondFloorConfig.FOUNDATION_SIZE
	local stairWellOrigin = SecondFloorConfig.FOUNDATION_OFFSET + SecondFloorConfig.STAIR_WELL_OFFSET
	local stairWellSize = SecondFloorConfig.STAIR_WELL_SIZE
	local foundationMinX = upperOrigin.X - (foundationSize.X / 2)
	local foundationMaxX = upperOrigin.X + (foundationSize.X / 2)
	local foundationMinZ = upperOrigin.Z - (foundationSize.Z / 2)
	local foundationMaxZ = upperOrigin.Z + (foundationSize.Z / 2)
	local stairWellMinX = stairWellOrigin.X - (stairWellSize.X / 2)
	local stairWellMaxX = stairWellOrigin.X + (stairWellSize.X / 2)
	local stairWellMinZ = stairWellOrigin.Z - (stairWellSize.Z / 2)
	local stairWellMaxZ = stairWellOrigin.Z + (stairWellSize.Z / 2)
	local foundationColor = Color3.fromRGB(57, 64, 80)
	local supportX = (foundationSize.X / 2) - 8
	local supportFrontZ = foundationMinZ + 14
	local supportRearZ = foundationMaxZ - 14

	local function createFoundationSegment(name: string, minX: number, maxX: number, minZ: number, maxZ: number)
		local width = maxX - minX
		local depth = maxZ - minZ
		if width <= 0.05 or depth <= 0.05 then
			return
		end

		createPart(folder, name, Vector3.new(width, foundationSize.Y, depth), getWorldCFrame(selfTable, Vector3.new((minX + maxX) / 2, upperOrigin.Y, (minZ + maxZ) / 2)), {
			Color = foundationColor,
			Material = Enum.Material.Metal,
		})
	end

	createFoundationSegment("FoundationFront", foundationMinX, foundationMaxX, foundationMinZ, stairWellMinZ)
	createFoundationSegment("FoundationBack", foundationMinX, foundationMaxX, stairWellMaxZ, foundationMaxZ)
	createFoundationSegment("FoundationLeft", foundationMinX, stairWellMinX, stairWellMinZ, stairWellMaxZ)
	createFoundationSegment("FoundationRight", stairWellMaxX, foundationMaxX, stairWellMinZ, stairWellMaxZ)
	createPart(folder, "Landing", SecondFloorConfig.LANDING_SIZE, getWorldCFrame(selfTable, SecondFloorConfig.LANDING_OFFSET), {
		Color = Color3.fromRGB(66, 74, 92),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "LandingTrim", Vector3.new(SecondFloorConfig.LANDING_SIZE.X, 1, 3), getWorldCFrame(selfTable, SecondFloorConfig.LANDING_OFFSET + Vector3.new(0, 1.5, (SecondFloorConfig.LANDING_SIZE.Z / 2) - 1.5)), {
		Color = selfTable.Accent,
		Material = Enum.Material.Neon,
	})

	local stairOrigin = SecondFloorConfig.STAIR_OFFSET
	local stepCount = 10
	local stepDepth = SecondFloorConfig.STAIR_SIZE.Z / stepCount
	local stairBottomY = stairOrigin.Y - (SecondFloorConfig.STAIR_SIZE.Y / 2) + 1.5
	local stairStartZ = stairOrigin.Z - (SecondFloorConfig.STAIR_SIZE.Z / 2) + (stepDepth / 2)

	for stepIndex = 1, stepCount do
		local alpha = stepIndex / stepCount
		local stepY = stairBottomY + ((SecondFloorConfig.BASE_Y_OFFSET + 2 - stairBottomY) * alpha)
		local stepZ = stairStartZ + ((stepIndex - 1) * stepDepth)
		createPart(folder, "StairStep" .. stepIndex, Vector3.new(SecondFloorConfig.STAIR_SIZE.X, 1.2, stepDepth + 0.15), getWorldCFrame(selfTable, Vector3.new(SecondFloorConfig.STAIR_OFFSET.X, stepY, stepZ)), {
			Color = Color3.fromRGB(73, 80, 99),
			Material = Enum.Material.Metal,
		})
	end

	for _, railX in { -((SecondFloorConfig.STAIR_SIZE.X / 2) - 0.75), (SecondFloorConfig.STAIR_SIZE.X / 2) - 0.75 } do
		createPart(folder, railX < 0 and "StairRailLeft" or "StairRailRight", Vector3.new(1.25, SecondFloorConfig.STAIR_SIZE.Y, SecondFloorConfig.STAIR_SIZE.Z + 2), getWorldCFrame(selfTable, Vector3.new(SecondFloorConfig.STAIR_OFFSET.X + railX, stairOrigin.Y, stairOrigin.Z)), {
			Color = Color3.fromRGB(43, 48, 61),
			Material = Enum.Material.Metal,
		})
	end

	createPart(folder, "SupportFrontLeft", Vector3.new(3, SecondFloorConfig.BASE_Y_OFFSET, 3), getWorldCFrame(selfTable, Vector3.new(-supportX, SecondFloorConfig.BASE_Y_OFFSET / 2, supportFrontZ)), {
		Color = Color3.fromRGB(56, 63, 79),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "SupportFrontRight", Vector3.new(3, SecondFloorConfig.BASE_Y_OFFSET, 3), getWorldCFrame(selfTable, Vector3.new(supportX, SecondFloorConfig.BASE_Y_OFFSET / 2, supportFrontZ)), {
		Color = Color3.fromRGB(56, 63, 79),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "SupportRearLeft", Vector3.new(3, SecondFloorConfig.BASE_Y_OFFSET, 3), getWorldCFrame(selfTable, Vector3.new(-supportX, SecondFloorConfig.BASE_Y_OFFSET / 2, supportRearZ)), {
		Color = Color3.fromRGB(56, 63, 79),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "SupportRearRight", Vector3.new(3, SecondFloorConfig.BASE_Y_OFFSET, 3), getWorldCFrame(selfTable, Vector3.new(supportX, SecondFloorConfig.BASE_Y_OFFSET / 2, supportRearZ)), {
		Color = Color3.fromRGB(56, 63, 79),
		Material = Enum.Material.Metal,
	})
	createDeckTrim(folder, selfTable, "UpperDeck", SecondFloorConfig.FOUNDATION_OFFSET, SecondFloorConfig.FOUNDATION_SIZE, selfTable.Accent, Color3.fromRGB(88, 96, 118))
	createPart(folder, "UpperCrossWalk", Vector3.new(20, 0.35, 54), getWorldCFrame(selfTable, Vector3.new(-10, SecondFloorConfig.BASE_Y_OFFSET + 1.25, 48)), {
		Color = Color3.fromRGB(79, 87, 108),
		Material = Enum.Material.DiamondPlate,
	})
	createPart(folder, "UpperFactoryPad", Vector3.new(42, 0.35, 42), getWorldCFrame(selfTable, Vector3.new(4, SecondFloorConfig.BASE_Y_OFFSET + 1.25, 40)), {
		Color = Color3.fromRGB(63, 70, 88),
		Material = Enum.Material.Metal,
	})
end

local function clearSecondFloorFoundation(selfTable)
	local folder = selfTable.StructuresFolder:FindFirstChild("SecondFloor")
	if folder and folder:IsA("Folder") then
		clearFolder(folder)
	end
end

local function ensureUpperWalls(selfTable)
	local folder = ensureFolder(selfTable.StructuresFolder, "UpperWalls")
	if #folder:GetChildren() > 0 then
		return
	end

	local wallY = SecondFloorConfig.BASE_Y_OFFSET + 1 + (SecondFloorConfig.UPPER_WALL_HEIGHT / 2)
	local thickness = SecondFloorConfig.UPPER_WALL_THICKNESS
	local depth = SecondFloorConfig.UPPER_WALL_DEPTH
	local wallColor = Color3.fromRGB(66, 78, 112)
	local backWallWidth = (SecondFloorConfig.UPPER_WALL_RIGHT_X - SecondFloorConfig.UPPER_WALL_LEFT_X) - 4
	local sideWallLength = SecondFloorConfig.UPPER_WALL_BACK_Z - SecondFloorConfig.UPPER_WALL_FRONT_Z
	local frontSegmentWidth = (SecondFloorConfig.UPPER_WALL_FRONT_RIGHT_X - SecondFloorConfig.UPPER_WALL_FRONT_LEFT_X) - 10

	createPart(folder, "BackWall", Vector3.new(backWallWidth, SecondFloorConfig.UPPER_WALL_HEIGHT, depth), getWorldCFrame(selfTable, Vector3.new(0, wallY, SecondFloorConfig.UPPER_WALL_BACK_Z)), {
		Color = wallColor,
		Material = Enum.Material.Metal,
	})
	createPart(folder, "LeftWall", Vector3.new(thickness, SecondFloorConfig.UPPER_WALL_HEIGHT, sideWallLength), getWorldCFrame(selfTable, Vector3.new(SecondFloorConfig.UPPER_WALL_LEFT_X, wallY, (SecondFloorConfig.UPPER_WALL_FRONT_Z + SecondFloorConfig.UPPER_WALL_BACK_Z) / 2)), {
		Color = wallColor,
		Material = Enum.Material.Metal,
	})
	createPart(folder, "RightWall", Vector3.new(thickness, SecondFloorConfig.UPPER_WALL_HEIGHT, sideWallLength), getWorldCFrame(selfTable, Vector3.new(SecondFloorConfig.UPPER_WALL_RIGHT_X, wallY, (SecondFloorConfig.UPPER_WALL_FRONT_Z + SecondFloorConfig.UPPER_WALL_BACK_Z) / 2)), {
		Color = wallColor,
		Material = Enum.Material.Metal,
	})
	createPart(folder, "FrontLeftWall", Vector3.new(frontSegmentWidth, SecondFloorConfig.UPPER_WALL_HEIGHT, depth), getWorldCFrame(selfTable, Vector3.new(SecondFloorConfig.UPPER_WALL_FRONT_LEFT_X, wallY, SecondFloorConfig.UPPER_WALL_FRONT_Z)), {
		Color = wallColor,
		Material = Enum.Material.Metal,
	})
	createPart(folder, "FrontRightWall", Vector3.new(frontSegmentWidth, SecondFloorConfig.UPPER_WALL_HEIGHT, depth), getWorldCFrame(selfTable, Vector3.new(SecondFloorConfig.UPPER_WALL_FRONT_RIGHT_X, wallY, SecondFloorConfig.UPPER_WALL_FRONT_Z)), {
		Color = wallColor,
		Material = Enum.Material.Metal,
	})
end

local function clearUpperWalls(selfTable)
	local folder = selfTable.StructuresFolder:FindFirstChild("UpperWalls")
	if folder and folder:IsA("Folder") then
		clearFolder(folder)
	end
end

local function ensureUpperConveyor(selfTable)
	local folder = ensureFolder(selfTable.EconomyFolder, "UpperConveyor")
	if #folder:GetChildren() > 0 then
		return
	end

	local conveyorOrigin = Vector3.new(SecondFloorConfig.UPPER_CONVEYOR_X_OFFSET, SecondFloorConfig.BASE_Y_OFFSET + 2, SecondFloorConfig.UPPER_CONVEYOR_Z_OFFSET)
	createPart(folder, "UpperConveyorBase", Vector3.new(10, 1, SecondFloorConfig.UPPER_CONVEYOR_LENGTH), getWorldCFrame(selfTable, conveyorOrigin), {
		Color = Color3.fromRGB(52, 58, 71),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "UpperConveyorStrip", Vector3.new(SecondFloorConfig.UPPER_CONVEYOR_WIDTH, 0.35, SecondFloorConfig.UPPER_CONVEYOR_LENGTH), getWorldCFrame(selfTable, conveyorOrigin + Vector3.new(0, 0.65, 0)), {
		Color = Color3.fromRGB(120, 189, 255),
		Material = Enum.Material.Neon,
	})
	createPart(folder, "UpperConveyorRailLeft", Vector3.new(1, 2, SecondFloorConfig.UPPER_CONVEYOR_LENGTH), getWorldCFrame(selfTable, conveyorOrigin + Vector3.new(-4, 1.1, 0)), {
		Color = Color3.fromRGB(39, 44, 56),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "UpperConveyorRailRight", Vector3.new(1, 2, SecondFloorConfig.UPPER_CONVEYOR_LENGTH), getWorldCFrame(selfTable, conveyorOrigin + Vector3.new(4, 1.1, 0)), {
		Color = Color3.fromRGB(39, 44, 56),
		Material = Enum.Material.Metal,
	})
end

local function clearUpperConveyor(selfTable)
	local folder = selfTable.EconomyFolder:FindFirstChild("UpperConveyor")
	if folder and folder:IsA("Folder") then
		clearFolder(folder)
	end
end

local function ensureUpperCollector(selfTable)
	local folder = ensureFolder(selfTable.EconomyFolder, "UpperCollector")
	if #folder:GetChildren() > 0 then
		return
	end

	local machine = createCollectorMachine(
		folder,
		"UpperCollectorMachine",
		getWorldCFrame(selfTable, Vector3.new(SecondFloorConfig.UPPER_CONVEYOR_X_OFFSET, SecondFloorConfig.BASE_Y_OFFSET + 2, SecondFloorConfig.UPPER_COLLECTOR_Z_OFFSET)),
		Color3.fromRGB(130, 214, 255)
	)
	labelMachine(machine, "Upper\nCollector", Color3.fromRGB(232, 246, 255))
	createPart(folder, "UpperCollectorPad", Vector3.new(16, 1, 10), getWorldCFrame(selfTable, Vector3.new(SecondFloorConfig.UPPER_CONVEYOR_X_OFFSET, SecondFloorConfig.BASE_Y_OFFSET + 1.5, SecondFloorConfig.UPPER_COLLECTOR_PAD_Z_OFFSET)), {
		Color = Color3.fromRGB(130, 214, 255),
		Material = Enum.Material.Neon,
	})
end

local function clearUpperCollector(selfTable)
	local folder = selfTable.EconomyFolder:FindFirstChild("UpperCollector")
	if folder and folder:IsA("Folder") then
		clearFolder(folder)
	end
end

local function ensureThirdFloorFoundation(selfTable)
	local folder = ensureFolder(selfTable.StructuresFolder, "ThirdFloor")
	if #folder:GetChildren() > 0 then
		return
	end

	local upperOrigin = ThirdFloorConfig.FOUNDATION_OFFSET
	local foundationSize = ThirdFloorConfig.FOUNDATION_SIZE
	local stairWellOrigin = ThirdFloorConfig.FOUNDATION_OFFSET + ThirdFloorConfig.STAIR_WELL_OFFSET
	local stairWellSize = ThirdFloorConfig.STAIR_WELL_SIZE
	local foundationMinX = upperOrigin.X - (foundationSize.X / 2)
	local foundationMaxX = upperOrigin.X + (foundationSize.X / 2)
	local foundationMinZ = upperOrigin.Z - (foundationSize.Z / 2)
	local foundationMaxZ = upperOrigin.Z + (foundationSize.Z / 2)
	local stairWellMinX = stairWellOrigin.X - (stairWellSize.X / 2)
	local stairWellMaxX = stairWellOrigin.X + (stairWellSize.X / 2)
	local stairWellMinZ = stairWellOrigin.Z - (stairWellSize.Z / 2)
	local stairWellMaxZ = stairWellOrigin.Z + (stairWellSize.Z / 2)
	local foundationColor = Color3.fromRGB(61, 68, 88)
	local supportX = (foundationSize.X / 2) - 8
	local supportFrontZ = foundationMinZ + 16
	local supportRearZ = foundationMaxZ - 16

	local function createFoundationSegment(name: string, minX: number, maxX: number, minZ: number, maxZ: number)
		local width = maxX - minX
		local depth = maxZ - minZ
		if width <= 0.05 or depth <= 0.05 then
			return
		end

		createPart(folder, name, Vector3.new(width, foundationSize.Y, depth), getWorldCFrame(selfTable, Vector3.new((minX + maxX) / 2, upperOrigin.Y, (minZ + maxZ) / 2)), {
			Color = foundationColor,
			Material = Enum.Material.Metal,
		})
	end

	createFoundationSegment("FoundationFront", foundationMinX, foundationMaxX, foundationMinZ, stairWellMinZ)
	createFoundationSegment("FoundationBack", foundationMinX, foundationMaxX, stairWellMaxZ, foundationMaxZ)
	createFoundationSegment("FoundationLeft", foundationMinX, stairWellMinX, stairWellMinZ, stairWellMaxZ)
	createFoundationSegment("FoundationRight", stairWellMaxX, foundationMaxX, stairWellMinZ, stairWellMaxZ)
	createPart(folder, "Landing", ThirdFloorConfig.LANDING_SIZE, getWorldCFrame(selfTable, ThirdFloorConfig.LANDING_OFFSET), {
		Color = Color3.fromRGB(72, 80, 102),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "LandingTrim", Vector3.new(ThirdFloorConfig.LANDING_SIZE.X, 1, 3), getWorldCFrame(selfTable, ThirdFloorConfig.LANDING_OFFSET + Vector3.new(0, 1.5, (ThirdFloorConfig.LANDING_SIZE.Z / 2) - 1.5)), {
		Color = selfTable.Accent,
		Material = Enum.Material.Neon,
	})

	local stairOrigin = ThirdFloorConfig.STAIR_OFFSET
	local stepCount = 10
	local stepDepth = ThirdFloorConfig.STAIR_SIZE.Z / stepCount
	local stairBottomY = stairOrigin.Y - (ThirdFloorConfig.STAIR_SIZE.Y / 2) + 1.5
	local stairStartZ = stairOrigin.Z - (ThirdFloorConfig.STAIR_SIZE.Z / 2) + (stepDepth / 2)

	for stepIndex = 1, stepCount do
		local alpha = stepIndex / stepCount
		local stepY = stairBottomY + ((ThirdFloorConfig.BASE_Y_OFFSET + 2 - stairBottomY) * alpha)
		local stepZ = stairStartZ + ((stepIndex - 1) * stepDepth)
		createPart(folder, "TopStairStep" .. stepIndex, Vector3.new(ThirdFloorConfig.STAIR_SIZE.X, 1.2, stepDepth + 0.15), getWorldCFrame(selfTable, Vector3.new(ThirdFloorConfig.STAIR_OFFSET.X, stepY, stepZ)), {
			Color = Color3.fromRGB(82, 90, 114),
			Material = Enum.Material.Metal,
		})
	end

	for _, railX in { -((ThirdFloorConfig.STAIR_SIZE.X / 2) - 0.75), (ThirdFloorConfig.STAIR_SIZE.X / 2) - 0.75 } do
		createPart(folder, railX < 0 and "TopStairRailLeft" or "TopStairRailRight", Vector3.new(1.25, ThirdFloorConfig.STAIR_SIZE.Y, ThirdFloorConfig.STAIR_SIZE.Z + 2), getWorldCFrame(selfTable, Vector3.new(ThirdFloorConfig.STAIR_OFFSET.X + railX, stairOrigin.Y, stairOrigin.Z)), {
			Color = Color3.fromRGB(49, 55, 69),
			Material = Enum.Material.Metal,
		})
	end

	createPart(folder, "SupportFrontLeft", Vector3.new(3, ThirdFloorConfig.BASE_Y_OFFSET - SecondFloorConfig.BASE_Y_OFFSET, 3), getWorldCFrame(selfTable, Vector3.new(-supportX, SecondFloorConfig.BASE_Y_OFFSET + ((ThirdFloorConfig.BASE_Y_OFFSET - SecondFloorConfig.BASE_Y_OFFSET) / 2), supportFrontZ)), {
		Color = Color3.fromRGB(60, 68, 86),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "SupportFrontRight", Vector3.new(3, ThirdFloorConfig.BASE_Y_OFFSET - SecondFloorConfig.BASE_Y_OFFSET, 3), getWorldCFrame(selfTable, Vector3.new(supportX, SecondFloorConfig.BASE_Y_OFFSET + ((ThirdFloorConfig.BASE_Y_OFFSET - SecondFloorConfig.BASE_Y_OFFSET) / 2), supportFrontZ)), {
		Color = Color3.fromRGB(60, 68, 86),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "SupportRearLeft", Vector3.new(3, ThirdFloorConfig.BASE_Y_OFFSET - SecondFloorConfig.BASE_Y_OFFSET, 3), getWorldCFrame(selfTable, Vector3.new(-supportX, SecondFloorConfig.BASE_Y_OFFSET + ((ThirdFloorConfig.BASE_Y_OFFSET - SecondFloorConfig.BASE_Y_OFFSET) / 2), supportRearZ)), {
		Color = Color3.fromRGB(60, 68, 86),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "SupportRearRight", Vector3.new(3, ThirdFloorConfig.BASE_Y_OFFSET - SecondFloorConfig.BASE_Y_OFFSET, 3), getWorldCFrame(selfTable, Vector3.new(supportX, SecondFloorConfig.BASE_Y_OFFSET + ((ThirdFloorConfig.BASE_Y_OFFSET - SecondFloorConfig.BASE_Y_OFFSET) / 2), supportRearZ)), {
		Color = Color3.fromRGB(60, 68, 86),
		Material = Enum.Material.Metal,
	})
	createDeckTrim(folder, selfTable, "ThirdDeck", ThirdFloorConfig.FOUNDATION_OFFSET, ThirdFloorConfig.FOUNDATION_SIZE, selfTable.Accent, Color3.fromRGB(94, 102, 126))
	createPart(folder, "ThirdCatwalk", Vector3.new(22, 0.35, 50), getWorldCFrame(selfTable, Vector3.new(-12, ThirdFloorConfig.BASE_Y_OFFSET + 1.25, 52)), {
		Color = Color3.fromRGB(85, 93, 116),
		Material = Enum.Material.DiamondPlate,
	})
	createPart(folder, "ThirdFactoryPad", Vector3.new(40, 0.35, 40), getWorldCFrame(selfTable, Vector3.new(18, ThirdFloorConfig.BASE_Y_OFFSET + 1.25, 44)), {
		Color = Color3.fromRGB(67, 74, 94),
		Material = Enum.Material.Metal,
	})
end

local function clearThirdFloorFoundation(selfTable)
	local folder = selfTable.StructuresFolder:FindFirstChild("ThirdFloor")
	if folder and folder:IsA("Folder") then
		clearFolder(folder)
	end
end

local function ensureThirdFloorWalls(selfTable)
	local folder = ensureFolder(selfTable.StructuresFolder, "ThirdFloorWalls")
	if #folder:GetChildren() > 0 then
		return
	end

	local wallY = ThirdFloorConfig.BASE_Y_OFFSET + 1 + (ThirdFloorConfig.WALL_HEIGHT / 2)
	local wallColor = Color3.fromRGB(82, 97, 136)

	createPart(folder, "BackWall", Vector3.new(ThirdFloorConfig.BACK_WALL_WIDTH, ThirdFloorConfig.WALL_HEIGHT, ThirdFloorConfig.WALL_DEPTH), getWorldCFrame(selfTable, Vector3.new(0, wallY, ThirdFloorConfig.WALL_BACK_Z)), {
		Color = wallColor,
		Material = Enum.Material.Metal,
	})
	createPart(folder, "LeftWall", Vector3.new(ThirdFloorConfig.WALL_THICKNESS, ThirdFloorConfig.WALL_HEIGHT, ThirdFloorConfig.SIDE_WALL_LENGTH), getWorldCFrame(selfTable, Vector3.new(ThirdFloorConfig.WALL_LEFT_X, wallY, (ThirdFloorConfig.WALL_FRONT_Z + ThirdFloorConfig.WALL_BACK_Z) / 2)), {
		Color = wallColor,
		Material = Enum.Material.Metal,
	})
	createPart(folder, "RightWall", Vector3.new(ThirdFloorConfig.WALL_THICKNESS, ThirdFloorConfig.WALL_HEIGHT, ThirdFloorConfig.SIDE_WALL_LENGTH), getWorldCFrame(selfTable, Vector3.new(ThirdFloorConfig.WALL_RIGHT_X, wallY, (ThirdFloorConfig.WALL_FRONT_Z + ThirdFloorConfig.WALL_BACK_Z) / 2)), {
		Color = wallColor,
		Material = Enum.Material.Metal,
	})
	createPart(folder, "FrontLeftWall", Vector3.new(ThirdFloorConfig.FRONT_SEGMENT_WIDTH, ThirdFloorConfig.WALL_HEIGHT, ThirdFloorConfig.WALL_DEPTH), getWorldCFrame(selfTable, Vector3.new(ThirdFloorConfig.WALL_FRONT_LEFT_X, wallY, ThirdFloorConfig.WALL_FRONT_Z)), {
		Color = wallColor,
		Material = Enum.Material.Metal,
	})
	createPart(folder, "FrontRightWall", Vector3.new(ThirdFloorConfig.FRONT_SEGMENT_WIDTH, ThirdFloorConfig.WALL_HEIGHT, ThirdFloorConfig.WALL_DEPTH), getWorldCFrame(selfTable, Vector3.new(ThirdFloorConfig.WALL_FRONT_RIGHT_X, wallY, ThirdFloorConfig.WALL_FRONT_Z)), {
		Color = wallColor,
		Material = Enum.Material.Metal,
	})
	createPart(folder, "FrontBridge", Vector3.new(18, 2, 4), getWorldCFrame(selfTable, Vector3.new(0, ThirdFloorConfig.BASE_Y_OFFSET + 1, ThirdFloorConfig.WALL_FRONT_Z + 1)), {
		Color = Color3.fromRGB(108, 128, 176),
		Material = Enum.Material.Metal,
	})
end

local function clearThirdFloorWalls(selfTable)
	local folder = selfTable.StructuresFolder:FindFirstChild("ThirdFloorWalls")
	if folder and folder:IsA("Folder") then
		clearFolder(folder)
	end
end

local function ensureThirdConveyor(selfTable)
	local folder = ensureFolder(selfTable.EconomyFolder, "ThirdConveyor")
	if #folder:GetChildren() > 0 then
		return
	end

	local conveyorOrigin = Vector3.new(ThirdFloorConfig.CONVEYOR_X_OFFSET, ThirdFloorConfig.BASE_Y_OFFSET + 2, ThirdFloorConfig.CONVEYOR_Z_OFFSET)
	createPart(folder, "ThirdConveyorBase", Vector3.new(10, 1, ThirdFloorConfig.CONVEYOR_LENGTH), getWorldCFrame(selfTable, conveyorOrigin), {
		Color = Color3.fromRGB(60, 66, 80),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "ThirdConveyorStrip", Vector3.new(ThirdFloorConfig.CONVEYOR_WIDTH, 0.35, ThirdFloorConfig.CONVEYOR_LENGTH), getWorldCFrame(selfTable, conveyorOrigin + Vector3.new(0, 0.65, 0)), {
		Color = Color3.fromRGB(255, 152, 220),
		Material = Enum.Material.Neon,
	})
	createPart(folder, "ThirdConveyorRailLeft", Vector3.new(1, 2, ThirdFloorConfig.CONVEYOR_LENGTH), getWorldCFrame(selfTable, conveyorOrigin + Vector3.new(-4, 1.1, 0)), {
		Color = Color3.fromRGB(48, 52, 64),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "ThirdConveyorRailRight", Vector3.new(1, 2, ThirdFloorConfig.CONVEYOR_LENGTH), getWorldCFrame(selfTable, conveyorOrigin + Vector3.new(4, 1.1, 0)), {
		Color = Color3.fromRGB(48, 52, 64),
		Material = Enum.Material.Metal,
	})
end

local function clearThirdConveyor(selfTable)
	local folder = selfTable.EconomyFolder:FindFirstChild("ThirdConveyor")
	if folder and folder:IsA("Folder") then
		clearFolder(folder)
	end
end

local function ensureThirdCollector(selfTable)
	local folder = ensureFolder(selfTable.EconomyFolder, "ThirdCollector")
	if #folder:GetChildren() > 0 then
		return
	end

	local machine = createCollectorMachine(
		folder,
		"ThirdCollectorMachine",
		getWorldCFrame(selfTable, Vector3.new(ThirdFloorConfig.CONVEYOR_X_OFFSET, ThirdFloorConfig.BASE_Y_OFFSET + 2, ThirdFloorConfig.COLLECTOR_Z_OFFSET)),
		Color3.fromRGB(255, 162, 222)
	)
	labelMachine(machine, "Third\nCollector", Color3.fromRGB(255, 234, 246))
	createPart(folder, "ThirdCollectorPad", Vector3.new(16, 1, 10), getWorldCFrame(selfTable, Vector3.new(ThirdFloorConfig.CONVEYOR_X_OFFSET, ThirdFloorConfig.BASE_Y_OFFSET + 1.5, ThirdFloorConfig.COLLECTOR_PAD_Z_OFFSET)), {
		Color = Color3.fromRGB(255, 162, 222),
		Material = Enum.Material.Neon,
	})
end

local function clearThirdCollector(selfTable)
	local folder = selfTable.EconomyFolder:FindFirstChild("ThirdCollector")
	if folder and folder:IsA("Folder") then
		clearFolder(folder)
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

	for _, upgradeId in SECOND_FLOOR_DROPPER_ORDER do
		if purchased.second_floor and purchased[upgradeId] then
			ensureUpperDropperVisual(selfTable, upgradeId)
		else
			clearDropperVisual(selfTable, upgradeId)
		end
	end

	for _, upgradeId in THIRD_FLOOR_DROPPER_ORDER do
		if purchased.third_floor and purchased[upgradeId] then
			ensureThirdDropperVisual(selfTable, upgradeId)
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
		getWorldCFrame(selfTable, Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET, 0, GameConfig.TYCOON_AUTO_COLLECTOR_Z_OFFSET)),
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

	createPart(folder, "RailLeft", Vector3.new(1, 2, GameConfig.TYCOON_CONVEYOR_LENGTH), getWorldCFrame(selfTable, Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET - 4, 2.3, GameConfig.TYCOON_CONVEYOR_Z_OFFSET)), {
		Color = Color3.fromRGB(120, 255, 197),
		Material = Enum.Material.Neon,
	})
	createPart(folder, "RailRight", Vector3.new(1, 2, GameConfig.TYCOON_CONVEYOR_LENGTH), getWorldCFrame(selfTable, Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET + 4, 2.3, GameConfig.TYCOON_CONVEYOR_Z_OFFSET)), {
		Color = Color3.fromRGB(120, 255, 197),
		Material = Enum.Material.Neon,
	})
	createPart(folder, "DriveUnit", Vector3.new(8, 6, 6), getWorldCFrame(selfTable, Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET, 4.5, GameConfig.TYCOON_CONVEYOR_ENTRY_Z_OFFSET - 6)), {
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
		getWorldCFrame(selfTable, Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET + 12, 0, GameConfig.TYCOON_AUTO_COLLECTOR_Z_OFFSET - 2)),
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
		getWorldCFrame(selfTable, Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET - 12, 0, GameConfig.TYCOON_COLLECTOR_Z_OFFSET + 2)),
		Color3.fromRGB(132, 226, 255)
	)
	labelMachine(leftCollector, "Array\nLeft", Color3.fromRGB(214, 246, 255))

	local rightCollector = createCollectorMachine(
		folder,
		"CollectorArrayRight",
		getWorldCFrame(selfTable, Vector3.new(GameConfig.TYCOON_CONVEYOR_X_OFFSET + 12, 0, GameConfig.TYCOON_COLLECTOR_Z_OFFSET + 2)),
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
		createPart(folder, "LightPost" .. index, Vector3.new(1.5, 8, 1.5), getWorldCFrame(selfTable, offset - Vector3.new(0, 4, 0)), {
			Color = Color3.fromRGB(44, 52, 61),
			Material = Enum.Material.Metal,
		})
		createPart(folder, "LightHead" .. index, Vector3.new(4, 1, 4), getWorldCFrame(selfTable, offset), {
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
		createPart(folder, "CornerPost" .. index, Vector3.new(3, 28, 3), getWorldCFrame(selfTable, offset), {
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

	createPart(folder, "RearDeck", Vector3.new(112, 1, 22), getWorldCFrame(selfTable, Vector3.new(0, 1.05, 66)), {
		Color = Color3.fromRGB(58, 64, 78),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "RearTrimLeft", Vector3.new(8, 2, 24), getWorldCFrame(selfTable, Vector3.new(-52, 1.5, 66)), {
		Color = selfTable.Accent,
		Material = Enum.Material.Metal,
	})
	createPart(folder, "RearTrimRight", Vector3.new(8, 2, 24), getWorldCFrame(selfTable, Vector3.new(52, 1.5, 66)), {
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

	createPart(folder, "BayFloor", Vector3.new(20, 1, 96), getWorldCFrame(selfTable, Vector3.new(52, 1.1, 8)), {
		Color = Color3.fromRGB(47, 53, 67),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "BayCabinetA", Vector3.new(8, 10, 8), getWorldCFrame(selfTable, Vector3.new(52, 6, -26)), {
		Color = Color3.fromRGB(86, 95, 116),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "BayCabinetB", Vector3.new(8, 10, 8), getWorldCFrame(selfTable, Vector3.new(52, 6, 4)), {
		Color = Color3.fromRGB(86, 95, 116),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "BayPipe", Vector3.new(4, 4, 58), getWorldCFrame(selfTable, Vector3.new(44, 12, 12)), {
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

local function createArmoryDisplay(folder: Folder, selfTable, name: string, labelText: string, localPosition: Vector3, accent: Color3)
	local base = createPart(folder, name .. "Base", Vector3.new(8, 1, 8), getWorldCFrame(selfTable, localPosition + Vector3.new(0, 0.6, 0)), {
		Color = Color3.fromRGB(42, 47, 57),
		Material = Enum.Material.Metal,
	})
	createPart(folder, name .. "Pad", Vector3.new(6, 0.3, 6), getWorldCFrame(selfTable, localPosition + Vector3.new(0, 1.28, 0)), {
		Color = accent,
		Material = Enum.Material.Neon,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
	local model = createPart(folder, name .. "Display", Vector3.new(1.2, 3, 4), getWorldCFrame(selfTable, localPosition + Vector3.new(0, 3.1, 0)), {
		Color = accent,
		Material = Enum.Material.Metal,
	})
	createPart(folder, name .. "Barrel", Vector3.new(0.8, 0.8, 3.4), model.CFrame * CFrame.new(0, 0.3, -2.6), {
		Color = Color3.fromRGB(225, 230, 240),
		Material = Enum.Material.Neon,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
	local sign = createPart(folder, name .. "Sign", Vector3.new(7, 4, 1), getWorldCFrame(selfTable, localPosition + Vector3.new(0, 5.2, 4.2)), {
		Color = Color3.fromRGB(24, 28, 37),
		Material = Enum.Material.SmoothPlastic,
	})
	ensureSurfaceLabel(sign, labelText, Enum.NormalId.Front, Color3.fromRGB(255, 245, 226))

	return base
end

local function ensureArmoryBay(selfTable)
	local folder = ensureFolder(selfTable.StructuresFolder, "ArmoryBay")
	if #folder:GetChildren() > 0 then
		return
	end

	createPart(folder, "ArmoryFloor", Vector3.new(30, 1, 36), getWorldCFrame(selfTable, Vector3.new(48, 1.1, 3)), {
		Color = Color3.fromRGB(40, 44, 55),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "ArmoryBackWall", Vector3.new(30, 14, 2), getWorldCFrame(selfTable, Vector3.new(48, 7, -15)), {
		Color = Color3.fromRGB(56, 62, 78),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "ArmoryAccent", Vector3.new(28, 0.4, 30), getWorldCFrame(selfTable, Vector3.new(48, 1.5, 3)), {
		Color = Color3.fromRGB(255, 204, 122),
		Material = Enum.Material.Neon,
		Transparency = 0.18,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
	local sign = createPart(folder, "ArmorySign", Vector3.new(20, 5, 1), getWorldCFrame(selfTable, Vector3.new(48, 12, -14)), {
		Color = Color3.fromRGB(23, 26, 34),
		Material = Enum.Material.SmoothPlastic,
	})
	ensureSurfaceLabel(sign, "TYCOON ARMORY", Enum.NormalId.Front, Color3.fromRGB(255, 232, 194))
	createPart(folder, "ArmoryRackLeft", Vector3.new(2, 10, 28), getWorldCFrame(selfTable, Vector3.new(34, 6, 3)), {
		Color = Color3.fromRGB(77, 85, 104),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "ArmoryRackRight", Vector3.new(2, 10, 28), getWorldCFrame(selfTable, Vector3.new(62, 6, 3)), {
		Color = Color3.fromRGB(77, 85, 104),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "ArmoryShelf", Vector3.new(24, 2, 4), getWorldCFrame(selfTable, Vector3.new(48, 3.6, -8)), {
		Color = Color3.fromRGB(77, 85, 104),
		Material = Enum.Material.Metal,
	})
end

local function clearArmoryBay(selfTable)
	local folder = selfTable.StructuresFolder:FindFirstChild("ArmoryBay")
	if folder and folder:IsA("Folder") then
		clearFolder(folder)
	end
end

local function ensureCombatKnifeDisplay(selfTable)
	local folder = ensureFolder(selfTable.StructuresFolder, "CombatKnifeDisplay")
	if #folder:GetChildren() > 0 then
		return
	end

	createArmoryDisplay(folder, selfTable, "Knife", "Combat\nKnife", Vector3.new(39, 1, 5), Color3.fromRGB(194, 216, 242))
end

local function clearCombatKnifeDisplay(selfTable)
	local folder = selfTable.StructuresFolder:FindFirstChild("CombatKnifeDisplay")
	if folder and folder:IsA("Folder") then
		clearFolder(folder)
	end
end

local function ensureMoneyBlasterDisplay(selfTable)
	local folder = ensureFolder(selfTable.StructuresFolder, "MoneyBlasterDisplay")
	if #folder:GetChildren() > 0 then
		return
	end

	createArmoryDisplay(folder, selfTable, "Blaster", "Money\nBlaster", Vector3.new(48, 1, 5), Color3.fromRGB(118, 255, 171))
end

local function clearMoneyBlasterDisplay(selfTable)
	local folder = selfTable.StructuresFolder:FindFirstChild("MoneyBlasterDisplay")
	if folder and folder:IsA("Folder") then
		clearFolder(folder)
	end
end

local function ensureMoneyRpgDisplay(selfTable)
	local folder = ensureFolder(selfTable.StructuresFolder, "MoneyRpgDisplay")
	if #folder:GetChildren() > 0 then
		return
	end

	createArmoryDisplay(folder, selfTable, "Rpg", "Money\nRPG", Vector3.new(57, 1, 5), Color3.fromRGB(255, 162, 98))
end

local function clearMoneyRpgDisplay(selfTable)
	local folder = selfTable.StructuresFolder:FindFirstChild("MoneyRpgDisplay")
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
		createPart(folder, "RoofPost" .. index, Vector3.new(3, 32, 3), getWorldCFrame(selfTable, offset), {
			Color = Color3.fromRGB(62, 73, 98),
			Material = Enum.Material.Metal,
		})
	end

	createPart(folder, "RoofBeamFront", Vector3.new(98, 3, 3), getWorldCFrame(selfTable, Vector3.new(0, 31, -38)), {
		Color = Color3.fromRGB(76, 92, 120),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "RoofBeamMid", Vector3.new(98, 3, 3), getWorldCFrame(selfTable, Vector3.new(0, 31, 10)), {
		Color = Color3.fromRGB(76, 92, 120),
		Material = Enum.Material.Metal,
	})
	createPart(folder, "RoofBeamRear", Vector3.new(98, 3, 3), getWorldCFrame(selfTable, Vector3.new(0, 31, 58)), {
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
		selfTable,
		"LowWall",
		GameConfig.TYCOON_LOW_WALL_Y_OFFSET,
		GameConfig.TYCOON_LOW_WALL_HEIGHT,
		selfTable.Accent
	)
	registerWallParts(selfTable, selfTable.LowWallParts)
end

local function clearLowWalls(selfTable)
	clearRegisteredWallParts(selfTable.LowWallParts, selfTable.WallHealthStates)
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
		selfTable,
		"HighWall",
		GameConfig.TYCOON_HIGH_WALL_Y_OFFSET,
		GameConfig.TYCOON_HIGH_WALL_HEIGHT,
		Color3.fromRGB(49, 61, 104)
	)
	registerWallParts(selfTable, selfTable.HighWallParts)
end

local function clearHighWalls(selfTable)
	clearRegisteredWallParts(selfTable.HighWallParts, selfTable.WallHealthStates)
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
	destroyChild(doorFolder, "DoorHeaderLow")
	destroyChild(doorFolder, "DoorHeaderHigh")

	selfTable.DoorFrame = createPart(doorFolder, "DoorFrame", Vector3.new(GameConfig.TYCOON_ENTRY_FRAME_WIDTH, 14, 2), getWorldCFrame(selfTable, GameConfig.TYCOON_ENTRY_DOOR_OFFSET), {
		Color = Color3.fromRGB(24, 27, 34),
		Material = Enum.Material.Metal,
	})
	selfTable.DoorPanel = createPart(doorFolder, "DoorPanel", Vector3.new(GameConfig.TYCOON_ENTRY_PANEL_WIDTH, 10, 1), getWorldCFrame(selfTable, GameConfig.TYCOON_ENTRY_PANEL_OFFSET), {
		Color = Color3.fromRGB(162, 171, 192),
		Material = Enum.Material.Metal,
	})

	local supportX = (GameConfig.TYCOON_ENTRY_FRAME_WIDTH / 2) - (GameConfig.TYCOON_ENTRY_SIDE_SUPPORT_WIDTH / 2)
	local supportZ = GameConfig.TYCOON_ENTRY_DOOR_OFFSET.Z + ((GameConfig.TYCOON_ENTRY_SIDE_SUPPORT_DEPTH - 2) / 2)
	createPart(doorFolder, "DoorSupportLeft", Vector3.new(GameConfig.TYCOON_ENTRY_SIDE_SUPPORT_WIDTH, 14, GameConfig.TYCOON_ENTRY_SIDE_SUPPORT_DEPTH), getWorldCFrame(selfTable, Vector3.new(-supportX, GameConfig.TYCOON_ENTRY_DOOR_OFFSET.Y, supportZ)), {
		Color = Color3.fromRGB(34, 38, 48),
		Material = Enum.Material.Metal,
	})
	createPart(doorFolder, "DoorSupportRight", Vector3.new(GameConfig.TYCOON_ENTRY_SIDE_SUPPORT_WIDTH, 14, GameConfig.TYCOON_ENTRY_SIDE_SUPPORT_DEPTH), getWorldCFrame(selfTable, Vector3.new(supportX, GameConfig.TYCOON_ENTRY_DOOR_OFFSET.Y, supportZ)), {
		Color = Color3.fromRGB(34, 38, 48),
		Material = Enum.Material.Metal,
	})

	local lowHeaderHeight = math.max(2, GameConfig.TYCOON_LOW_WALL_HEIGHT - selfTable.DoorPanel.Size.Y)
	local lowHeaderY = GameConfig.TYCOON_LOW_WALL_Y_OFFSET + (GameConfig.TYCOON_LOW_WALL_HEIGHT / 2) - (lowHeaderHeight / 2)
	createPart(doorFolder, "DoorHeaderLow", Vector3.new(GameConfig.TYCOON_ENTRY_FRAME_WIDTH, lowHeaderHeight, 2), getWorldCFrame(selfTable, Vector3.new(0, lowHeaderY, GameConfig.TYCOON_WALL_FRONT_Z)), {
		Color = selfTable.Accent,
		Material = Enum.Material.Metal,
	})

	local highHeader = createPart(doorFolder, "DoorHeaderHigh", Vector3.new(GameConfig.TYCOON_ENTRY_FRAME_WIDTH, GameConfig.TYCOON_HIGH_WALL_HEIGHT, 2), getWorldCFrame(selfTable, Vector3.new(0, GameConfig.TYCOON_HIGH_WALL_Y_OFFSET, GameConfig.TYCOON_WALL_FRONT_Z)), {
		Color = Color3.fromRGB(49, 61, 104),
		Material = Enum.Material.Metal,
	})
	highHeader:SetAttribute("RequiresHighWalls", true)
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
		FacingYaw = definition.FacingYaw or 0,
		BaseCFrame = getBaseCFrame(definition),
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
		RepairConsole = refs.RepairConsole,
		RepairPrompt = refs.RepairPrompt,
		RepairLabel = refs.RepairLabel,
		RaidConsole = refs.RaidConsole,
		RaidPrompt = refs.RaidPrompt,
		RaidLabel = refs.RaidLabel,
		RaidBreachPad = refs.RaidBreachPad,
		RaidBreachPrompt = refs.RaidBreachPrompt,
		RaidBreachLabel = refs.RaidBreachLabel,
		RaidStatusSign = refs.RaidStatusSign,
		RaidStatusLabel = refs.RaidStatusLabel,
		StarterDropperModel = refs.StarterDropperModel,
		StarterClicker = refs.StarterClicker,
		StarterClickerOutput = refs.StarterClickerOutput,
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
		WallHealthStates = refs.WallHealthStates,
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
		FacingYaw = definition.FacingYaw or 0,
		BaseCFrame = getBaseCFrame(definition),
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
		RepairConsole = refs.RepairConsole,
		RepairPrompt = refs.RepairPrompt,
		RepairLabel = refs.RepairLabel,
		RaidConsole = refs.RaidConsole,
		RaidPrompt = refs.RaidPrompt,
		RaidLabel = refs.RaidLabel,
		RaidBreachPad = refs.RaidBreachPad,
		RaidBreachPrompt = refs.RaidBreachPrompt,
		RaidBreachLabel = refs.RaidBreachLabel,
		RaidStatusSign = refs.RaidStatusSign,
		RaidStatusLabel = refs.RaidStatusLabel,
		StarterDropperModel = refs.StarterDropperModel,
		StarterClicker = refs.StarterClicker,
		StarterClickerOutput = refs.StarterClickerOutput,
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
		WallHealthStates = refs.WallHealthStates,
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
	self.RaidPrompt.Enabled = player ~= nil
	self.RaidBreachPrompt.Enabled = false
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
		self.ClaimPad.CFrame = getWorldCFrame(self, GameConfig.CLAIM_PAD_OFFSET)
		self.ClaimPad.Color = self.Accent
		self.OwnerUserIdValue.Value = player.UserId
		self.OwnerNameValue.Value = player.Name
		self.IsClaimedValue.Value = true
	else
		self.OwnerLabel.Text = "Unclaimed"
		self.ClaimLabel.Text = "Claim Tycoon"
		self.ClaimPrompt.Enabled = true
		self.ClaimPad.Size = GameConfig.CLAIM_PAD_UNCLAIMED_SIZE
		self.ClaimPad.CFrame = getWorldCFrame(self, GameConfig.CLAIM_PAD_OFFSET)
		self.ClaimPad.Color = Color3.fromRGB(63, 215, 120)
		self.OwnerUserIdValue.Value = 0
		self.OwnerNameValue.Value = ""
		self.IsClaimedValue.Value = false
	end

	self.TycoonIdValue.Value = self.Id
	self:updateWallRepairDisplay()
	self:updateRaidDisplay(false, "Raid Closed", false, false)
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

function Tycoon:getWallRepairCost(): number
	local totalMissing = 0
	for _, wallState in self.WallHealthStates do
		if wallState.part then
			totalMissing += math.max(0, wallState.max - wallState.current)
		end
	end
	return totalMissing
end

function Tycoon:updateWallRepairDisplay()
	local totalCurrent = 0
	local totalMax = 0
	for _, wallState in self.WallHealthStates do
		if wallState.part then
			totalCurrent += wallState.current
			totalMax += wallState.max
			refreshWallPartState(wallState)
		end
	end

	local missing = math.max(0, totalMax - totalCurrent)
	if totalMax <= 0 then
		self.RepairLabel.Text = "Walls\nLocked"
		self.RepairPrompt.ActionText = "Walls Locked"
		self.RepairPrompt.Enabled = false
		return
	end

	self.RepairLabel.Text = string.format("Walls\n%d/%d", totalCurrent, totalMax)
	self.RepairPrompt.ActionText = if missing > 0 then string.format("Rebuild $%d", missing) else "Walls Full"
	self.RepairPrompt.Enabled = self.Owner ~= nil and missing > 0
end

function Tycoon:updateRaidDisplay(isOpen: boolean, summaryText: string, breachEnabled: boolean, isBreached: boolean)
	local controlsVisible = self.RaidConsole.Transparency < 1
	self.RaidLabel.Text = if isOpen then "Raid\nOpen" else "Raid\nClosed"
	self.RaidStatusLabel.Text = summaryText
	self.RaidPrompt.ActionText = if isOpen then "Close Raid" else "Open Raid"
	self.RaidPrompt.Enabled = controlsVisible and self.Owner ~= nil and GameConfig.RAID_ENABLED
	self.RaidBreachPrompt.Enabled = controlsVisible and breachEnabled
	self.RaidBreachLabel.Text = if isBreached then "Door\nBreached" elseif breachEnabled then "Breach\nDoor" else "Raid\nLocked"
	self.RaidBreachPad.Color = if isBreached then Color3.fromRGB(255, 178, 79) elseif breachEnabled then Color3.fromRGB(255, 110, 110) else Color3.fromRGB(98, 108, 128)
end

function Tycoon:resetWallHealth()
	for wallId, wallState in self.WallHealthStates do
		wallState.current = wallState.max
		if wallState.part == nil then
			self.WallHealthStates[wallId] = {
				current = wallState.max,
				max = wallState.max,
				part = nil,
			}
		end
	end
	self:updateWallRepairDisplay()
end

function Tycoon:damageWallPart(wallPart: BasePart, amount: number): boolean
	if amount <= 0 then
		return false
	end

	local wallId = wallPart:GetAttribute("WallSegmentId")
	if type(wallId) ~= "string" then
		return false
	end

	local wallState = self.WallHealthStates[wallId]
	if not wallState then
		return false
	end

	local previous = wallState.current
	wallState.current = math.max(0, wallState.current - math.floor(amount + 0.5))
	wallState.part = wallPart
	refreshWallPartState(wallState)
	self:updateWallRepairDisplay()
	return wallState.current < previous
end

function Tycoon:repairWalls(repairAmount: number?): number
	local remaining = math.max(0, math.floor((repairAmount or self:getWallRepairCost()) + 0.5))
	local spent = 0
	if remaining <= 0 then
		self:updateWallRepairDisplay()
		return 0
	end

	local orderedWallIds = {}
	for wallId, wallState in self.WallHealthStates do
		if wallState.part then
			table.insert(orderedWallIds, wallId)
		end
	end
	table.sort(orderedWallIds)

	for _, wallId in orderedWallIds do
		if remaining <= 0 then
			break
		end

		local wallState = self.WallHealthStates[wallId]
		local missing = math.max(0, wallState.max - wallState.current)
		if missing > 0 then
			local applied = math.min(remaining, missing)
			wallState.current += applied
			remaining -= applied
			spent += applied
			if wallState.part then
				refreshWallPartState(wallState)
			end
		end
	end

	self:updateWallRepairDisplay()
	return spent
end

function Tycoon:applyVisualState(purchased: { [string]: boolean }, collectorStored: number)
	reconcileDropperVisuals(self, purchased)

	if purchased.second_floor == true then
		ensureSecondFloorFoundation(self)
	else
		clearSecondFloorFoundation(self)
	end

	if purchased.second_floor == true and purchased.upper_walls == true then
		ensureUpperWalls(self)
	else
		clearUpperWalls(self)
	end

	if purchased.second_floor == true and purchased.upper_conveyor == true then
		ensureUpperConveyor(self)
	else
		clearUpperConveyor(self)
	end

	if purchased.second_floor == true and purchased.upper_collector == true then
		ensureUpperCollector(self)
	else
		clearUpperCollector(self)
	end

	if purchased.third_floor == true then
		ensureThirdFloorFoundation(self)
	else
		clearThirdFloorFoundation(self)
	end

	if purchased.third_floor == true and purchased.third_floor_walls == true then
		ensureThirdFloorWalls(self)
	else
		clearThirdFloorWalls(self)
	end

	if purchased.third_floor == true and purchased.third_conveyor == true then
		ensureThirdConveyor(self)
	else
		clearThirdConveyor(self)
	end

	if purchased.third_floor == true and purchased.third_collector == true then
		ensureThirdCollector(self)
	else
		clearThirdCollector(self)
	end

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

	setPartVisible(self.RepairConsole, showWallSet, 0)
	self.RepairConsole.CanCollide = false
	self.RepairConsole.CanTouch = false
	self.RepairConsole.CanQuery = false

	local hasDoorUpgrade = purchased.front_door == true or purchased.reinforced_door == true
	local showRaidControls = showWallSet and hasDoorUpgrade and GameConfig.RAID_ENABLED
	setPartVisible(self.RaidConsole, showRaidControls, 0)
	self.RaidConsole.CanCollide = false
	self.RaidConsole.CanTouch = false
	self.RaidConsole.CanQuery = false
	setPartVisible(self.RaidStatusSign, showRaidControls, 0)
	self.RaidStatusSign.CanCollide = false
	self.RaidStatusSign.CanTouch = false
	self.RaidStatusSign.CanQuery = false
	setPartVisible(self.RaidBreachPad, showRaidControls, 0)
	self.RaidBreachPad.CanCollide = false
	self.RaidBreachPad.CanTouch = false
	self.RaidBreachPad.CanQuery = false
	if not showRaidControls then
		self.RaidPrompt.Enabled = false
		self.RaidBreachPrompt.Enabled = false
	end

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

	if purchased.armory_bay == true then
		ensureArmoryBay(self)
	else
		clearArmoryBay(self)
	end

	if purchased.armory_bay == true and purchased.combat_knife == true then
		ensureCombatKnifeDisplay(self)
	else
		clearCombatKnifeDisplay(self)
	end

	if purchased.armory_bay == true and purchased.money_blaster == true then
		ensureMoneyBlasterDisplay(self)
	else
		clearMoneyBlasterDisplay(self)
	end

	if purchased.armory_bay == true and purchased.money_rpg == true then
		ensureMoneyRpgDisplay(self)
	else
		clearMoneyRpgDisplay(self)
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
	setModelVisible(self.StarterDropperModel, purchased.basic_dropper ~= true, 0)
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
				local requiresHighWalls = child:GetAttribute("RequiresHighWalls") == true
				local shouldShow = hasDoorUpgrade and (not requiresHighWalls or purchased.high_walls == true)
				setPartVisible(child, shouldShow, 0)
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
	self:updateWallRepairDisplay()
end

function Tycoon:updateButtons(purchased: { [string]: boolean })
	for _, upgradeId in getAllUpgradeOrder() do
		local buttonState = self.ButtonStates[upgradeId]
		local upgrade = getUpgradeDefinition(upgradeId)
		if not buttonState or not upgrade then
			continue
		end

		local isLiveUpgrade = GameConfig.getUpgrade(upgradeId) ~= nil
		local isPurchased = purchased[upgradeId] == true
		local isUpperFloorPad = table.find(SECOND_FLOOR_UPGRADE_ORDER, upgradeId) ~= nil and upgradeId ~= "second_floor"
		local isThirdFloorPad = table.find(THIRD_FLOOR_UPGRADE_ORDER, upgradeId) ~= nil and upgradeId ~= "third_floor"
		local secondFloorUnlocked = purchased.second_floor == true
		local thirdFloorUnlocked = purchased.third_floor == true
		local passesFloorGate = if isUpperFloorPad
			then secondFloorUnlocked
			elseif isThirdFloorPad
			then thirdFloorUnlocked
			else true
		local canBuy = self.Owner ~= nil and isLiveUpgrade and passesFloorGate and not isPurchased and GameConfig.areRequirementsMet(purchased, upgradeId)

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
