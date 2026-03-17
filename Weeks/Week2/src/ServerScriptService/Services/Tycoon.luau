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

export type Instance = {
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
	UpgradeButtonsFolder: Folder,
	DropperModels: { [string]: Model },
	DropperOutputs: { [string]: BasePart },
	ButtonStates: { [string]: UpgradeButton },
	Owner: Player?,
	ValuesFolder: Folder,
	OwnerUserIdValue: IntValue,
	OwnerNameValue: StringValue,
	IsClaimedValue: BoolValue,
	TycoonIdValue: StringValue,
	setOwner: (self: Instance, player: Player?) -> (),
	isOwnedBy: (self: Instance, player: Player) -> boolean,
	updateCollectorDisplay: (self: Instance, amount: number) -> (),
	applyVisualState: (self: Instance, purchased: { [string]: boolean }, collectorStored: number) -> (),
	updateButtons: (self: Instance, purchased: { [string]: boolean }) -> (),
	teleportToSpawn: (self: Instance, player: Player) -> (),
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

local function createPart(parent: Instance, name: string, size: Vector3, cframe: CFrame, properties: { [string]: any }?): Part
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
		existing.Name = name
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

local function createDropperModel(parent: Instance, name: string, origin: CFrame, accent: Color3, placeholder: boolean)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent

	local bodyColor = if placeholder then Color3.fromRGB(176, 176, 176) else accent
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

	if placeholder then
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

local function setPartVisible(part: BasePart, visible: boolean, transparency: number?)
	part.Transparency = if visible then (transparency or 0) else 1
	part.CanCollide = visible
	part.CanTouch = visible
	part.CanQuery = visible
end

local function setModelVisible(model: Model, visible: boolean, transparency: number?)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") and descendant.Name ~= "OutputPoint" then
			setPartVisible(descendant, visible, transparency)
		end
	end
end

local function createUpgradeButton(parent: Instance, origin: Vector3, accent: Color3, upgradeId: string, index: number): UpgradeButton
	local upgrade = GameConfig.getUpgrade(upgradeId)
	if not upgrade then
		error(string.format("Missing upgrade definition for %s", upgradeId))
	end

	local xOffset = -24 + ((index - 1) % 2) * 18
	local zOffset = 22 + math.floor((index - 1) / 2) * 12
	local buttonPart = createPart(parent, upgradeId, Vector3.new(10, 1, 10), CFrame.new(origin + Vector3.new(xOffset, 0.6, zOffset)), {
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

local function ensureWeek2Scaffolding(model: Model, definition: Definition)
	local origin = definition.Origin

	destroyChild(model, "Structures")
	destroyChild(model, "LowWalls")
	destroyChild(model, "HighWalls")
	destroyChild(model, "SecondFloorParts")
	destroyChild(model, "DoorFrame")
	destroyChild(model, "DoorPanel")
	destroyChild(model, "DoorSensor")

	local baseFloor = ensurePart(model, "BaseFloor", GameConfig.TYCOON_SIZE, CFrame.new(origin), {
		Color = Color3.fromRGB(44, 47, 57),
		Material = Enum.Material.Slate,
	})

	local claimPad = ensurePart(model, "ClaimPad", Vector3.new(16, 1, 16), CFrame.new(origin + Vector3.new(0, 1.5, -30)), {
		Color = Color3.fromRGB(63, 215, 120),
		Material = Enum.Material.Neon,
	})

	local ownerSign = ensurePart(model, "OwnerSign", Vector3.new(20, 8, 1), CFrame.new(origin + Vector3.new(0, 8, -44)), {
		Color = Color3.fromRGB(22, 24, 31),
		Material = Enum.Material.SmoothPlastic,
	})

	local zonesFolder = ensureFolder(model, "Zones")
	clearFolder(zonesFolder)
	createPart(zonesFolder, "ProductionZone", Vector3.new(28, 8, 24), CFrame.new(origin + Vector3.new(0, 4, -10)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = true,
	})
	createPart(zonesFolder, "CollectorZone", Vector3.new(22, 8, 18), CFrame.new(origin + Vector3.new(0, 4, 20)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = true,
	})
	createPart(zonesFolder, "ButtonZone", Vector3.new(34, 8, 18), CFrame.new(origin + Vector3.new(0, 4, 34)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = true,
	})
	createPart(zonesFolder, "EntranceZone", Vector3.new(26, 8, 16), CFrame.new(origin + Vector3.new(0, 4, 40)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = true,
	})

	local boundariesFolder = ensureFolder(model, "Boundaries")
	clearFolder(boundariesFolder)
	local halfX = GameConfig.TYCOON_SIZE.X / 2
	local halfZ = GameConfig.TYCOON_SIZE.Z / 2
	local boundaryHeight = GameConfig.PLOT_BOUNDARY_HEIGHT
	createPart(boundariesFolder, "BackBoundary", Vector3.new(GameConfig.TYCOON_SIZE.X, boundaryHeight, 2), CFrame.new(origin + Vector3.new(0, boundaryHeight / 2, -halfZ)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = true,
	})
	createPart(boundariesFolder, "FrontBoundary", Vector3.new(GameConfig.TYCOON_SIZE.X, boundaryHeight, 2), CFrame.new(origin + Vector3.new(0, boundaryHeight / 2, halfZ)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = true,
	})
	createPart(boundariesFolder, "LeftBoundary", Vector3.new(2, boundaryHeight, GameConfig.TYCOON_SIZE.Z), CFrame.new(origin + Vector3.new(-halfX, boundaryHeight / 2, 0)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = true,
	})
	createPart(boundariesFolder, "RightBoundary", Vector3.new(2, boundaryHeight, GameConfig.TYCOON_SIZE.Z), CFrame.new(origin + Vector3.new(halfX, boundaryHeight / 2, 0)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = true,
	})

	local spawnPointsFolder = ensureFolder(model, "SpawnPoints")
	local spawn = spawnPointsFolder:FindFirstChild("TycoonSpawn")
	if spawn and not spawn:IsA("SpawnLocation") then
		spawn:Destroy()
		spawn = nil
	end

	if not spawn then
		local spawnLocation = Instance.new("SpawnLocation")
		spawnLocation.Name = "TycoonSpawn"
		spawnLocation.Size = Vector3.new(8, 1, 8)
		spawnLocation.CFrame = CFrame.new(origin + Vector3.new(0, 2.5, -18))
		spawnLocation.Neutral = false
		spawnLocation.Anchored = true
		spawnLocation.Enabled = false
		spawnLocation.Color = definition.Accent
		spawnLocation.Parent = spawnPointsFolder
		spawn = spawnLocation
	end

	local valuesFolder = ensureFolder(model, "Values")
	local ownerUserIdValue = ensureValue(valuesFolder, "IntValue", "OwnerUserId", 0)
	local ownerNameValue = ensureValue(valuesFolder, "StringValue", "OwnerName", "")
	local isClaimedValue = ensureValue(valuesFolder, "BoolValue", "IsClaimed", false)
	local tycoonIdValue = ensureValue(valuesFolder, "StringValue", "TycoonId", definition.Id)

	local runtimeFolder = ensureFolder(model, "Runtime")
	clearFolder(runtimeFolder)
	local moneyPartsFolder = ensureFolder(runtimeFolder, "MoneyParts")
	clearFolder(moneyPartsFolder)

	local conveyorBase = ensurePart(model, "ConveyorBase", Vector3.new(10, 1, 44), CFrame.new(origin + Vector3.new(0, 1.25, -4)), {
		Color = Color3.fromRGB(52, 58, 71),
		Material = Enum.Material.Metal,
	})
	local conveyorStrip = ensurePart(model, "ConveyorStrip", Vector3.new(6, 0.35, 44), CFrame.new(origin + Vector3.new(0, 1.9, -4)), {
		Color = Color3.fromRGB(109, 122, 255),
		Material = Enum.Material.Neon,
	})
	local conveyorEntry = ensurePart(model, "ConveyorEntry", Vector3.new(1, 1, 1), CFrame.new(origin + Vector3.new(0, 5.25, -22)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})

	destroyChild(model, "CollectorMachine")
	local collectorMachine = createCollectorMachine(model, "CollectorMachine", CFrame.new(origin + Vector3.new(0, 0, 18)), Color3.fromRGB(255, 182, 72))
	local collectorPad = ensurePart(model, "CollectorPad", Vector3.new(14, 1, 10), CFrame.new(origin + Vector3.new(0, 1.5, 24)), {
		Color = Color3.fromRGB(255, 182, 72),
		Material = Enum.Material.Neon,
	})
	local collectorLabel = ensureSurfaceLabel(collectorPad, "Stored\n$0", Enum.NormalId.Top, Color3.new(1, 1, 1))
	local collectorPrompt = ensurePrompt(collectorPad, "Collect $0", "Collector", GameConfig.COLLECTOR_PROMPT_RANGE)
	local collectorPoint = ensurePart(model, "CollectorPoint", Vector3.new(1, 1, 1), CFrame.new(origin + Vector3.new(0, 3.2, 18)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
	local collectorTrigger = ensurePart(model, "CollectorTrigger", Vector3.new(12, 3, 10), CFrame.new(origin + Vector3.new(0, 2.5, 22)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = true,
		CanQuery = false,
	})

	local dropperModelsFolder = ensureFolder(model, "Droppers")
	clearFolder(dropperModelsFolder)
	local basicDropperModel, basicOutputPoint = createDropperModel(dropperModelsFolder, "BasicDropper", CFrame.new(origin + Vector3.new(-14, 5, -24)), definition.Accent, false)
	local secondDropperModel, secondOutputPoint = createDropperModel(dropperModelsFolder, "SecondDropper", CFrame.new(origin + Vector3.new(14, 5, -24)), Color3.fromRGB(205, 173, 102), true)

	local upgradeButtonsFolder = ensureFolder(model, "UpgradeButtons")
	clearFolder(upgradeButtonsFolder)
	local buttonStates: { [string]: UpgradeButton } = {}
	for index, upgradeId in GameConfig.UPGRADE_ORDER do
		buttonStates[upgradeId] = createUpgradeButton(upgradeButtonsFolder, origin, definition.Accent, upgradeId, index)
	end

	local claimLabel = ensureSurfaceLabel(claimPad, "Claim Tycoon", Enum.NormalId.Top, Color3.new(1, 1, 1))
	local ownerLabel = ensureSurfaceLabel(ownerSign, "Unclaimed", Enum.NormalId.Front, Color3.new(1, 1, 1))

	baseFloor.Name = "BaseFloor"

	return {
		Spawn = spawn :: SpawnLocation,
		ClaimPad = claimPad,
		ClaimPrompt = ensurePrompt(claimPad, "Claim Tycoon", definition.Id, GameConfig.CLAIM_PROMPT_RANGE),
		ClaimLabel = claimLabel,
		OwnerSign = ownerSign,
		OwnerLabel = ownerLabel,
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
		UpgradeButtonsFolder = upgradeButtonsFolder,
		DropperModels = {
			basic_dropper = basicDropperModel,
			second_dropper = secondDropperModel,
		},
		DropperOutputs = {
			basic_dropper = basicOutputPoint,
			second_dropper = secondOutputPoint,
		},
		ButtonStates = buttonStates,
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

function Tycoon.new(definition: Definition, parent: Instance): Instance
	local model = Instance.new("Model")
	model.Name = definition.Id
	model.Parent = parent

	local refs = ensureWeek2Scaffolding(model, definition)

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
		UpgradeButtonsFolder = refs.UpgradeButtonsFolder,
		DropperModels = refs.DropperModels,
		DropperOutputs = refs.DropperOutputs,
		ButtonStates = refs.ButtonStates,
		Owner = nil,
		ValuesFolder = refs.ValuesFolder,
		OwnerUserIdValue = refs.OwnerUserIdValue,
		OwnerNameValue = refs.OwnerNameValue,
		IsClaimedValue = refs.IsClaimedValue,
		TycoonIdValue = refs.TycoonIdValue,
	}, Tycoon)

	self:applyVisualState({}, 0)
	self:updateButtons({})
	self:setOwner(nil)
	return self
end

function Tycoon.bind(model: Model, definition: Definition): Instance
	local refs = ensureWeek2Scaffolding(model, definition)

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
		UpgradeButtonsFolder = refs.UpgradeButtonsFolder,
		DropperModels = refs.DropperModels,
		DropperOutputs = refs.DropperOutputs,
		ButtonStates = refs.ButtonStates,
		Owner = nil,
		ValuesFolder = refs.ValuesFolder,
		OwnerUserIdValue = refs.OwnerUserIdValue,
		OwnerNameValue = refs.OwnerNameValue,
		IsClaimedValue = refs.IsClaimedValue,
		TycoonIdValue = refs.TycoonIdValue,
	}, Tycoon)

	self:applyVisualState({}, 0)
	self:updateButtons({})
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
	setModelVisible(self.DropperModels.basic_dropper, purchased.basic_dropper == true, 0)
	setModelVisible(self.DropperModels.second_dropper, purchased.second_dropper == true, 0)
	setPartVisible(self.ConveyorBase, true, 0)
	setPartVisible(self.ConveyorStrip, true, 0)
	setPartVisible(self.ConveyorEntry, false)
	setPartVisible(self.CollectorPad, true, 0)
	setPartVisible(self.CollectorPoint, false)
	setPartVisible(self.CollectorTrigger, false)

	if self.CollectorMachine.PrimaryPart then
		self.CollectorMachine.PrimaryPart.Color = if purchased.collector then Color3.fromRGB(255, 215, 128) else Color3.fromRGB(255, 182, 72)
	end

	self.ConveyorStrip.Color = if purchased.conveyor_speed then Color3.fromRGB(255, 230, 132) else Color3.fromRGB(109, 122, 255)
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
