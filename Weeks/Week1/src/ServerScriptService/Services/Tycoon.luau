local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

local Tycoon = {}
Tycoon.__index = Tycoon

export type Definition = {
	Id: string,
	Origin: Vector3,
	Accent: Color3,
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
	ValuesFolder: Folder,
	OwnerUserIdValue: IntValue,
	OwnerNameValue: StringValue,
	IsClaimedValue: BoolValue,
	TycoonIdValue: StringValue,
	setOwner: (self: Instance, player: Player?) -> (),
	isOwnedBy: (self: Instance, player: Player) -> boolean,
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

local function createPart(parent: Instance, name: string, size: Vector3, cframe: CFrame, properties: { [string]: any }?): Part
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

local function ensurePart(parent: Instance, name: string, size: Vector3, cframe: CFrame, properties: { [string]: any }?): BasePart
	local existing = parent:FindFirstChild(name)
	if existing and existing:IsA("BasePart") then
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
	gui.Parent = parent

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = textColor
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
				if label.Text == "" then
					label.Text = text
				end
				return label
			end
		end
	end

	return createSurfaceLabel(parent, text, face, textColor)
end

local function ensurePrompt(parent: BasePart, actionText: string, objectText: string): ProximityPrompt
	local prompt = parent:FindFirstChildWhichIsA("ProximityPrompt")
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

local function ensureValue<T>(parent: Instance, className: string, name: string, defaultValue: T)
	local existing = parent:FindFirstChild(name)
	if existing and existing:IsA(className) then
		if existing.Value == nil or existing.Value == "" or existing.Value == false or existing.Value == 0 then
			existing.Value = defaultValue
		end
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

local function createZonePart(parent: Instance, name: string, size: Vector3, cframe: CFrame)
	return ensurePart(parent, name, size, cframe, {
		Transparency = 1,
		Color = Color3.fromRGB(255, 255, 255),
		CanCollide = false,
		CanTouch = false,
		CanQuery = true,
	})
end

local function createBoundaryPart(parent: Instance, name: string, size: Vector3, cframe: CFrame)
	return ensurePart(parent, name, size, cframe, {
		Transparency = 1,
		Color = Color3.fromRGB(255, 255, 255),
		CanCollide = false,
		CanTouch = false,
		CanQuery = true,
	})
end

local function ensureWeek1Scaffolding(model: Model, definition: Definition)
	local origin = definition.Origin

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
	createZonePart(zonesFolder, "ProductionZone", Vector3.new(30, 8, 28), CFrame.new(origin + Vector3.new(0, 4, -8)))
	createZonePart(zonesFolder, "StashZone", Vector3.new(24, 8, 20), CFrame.new(origin + Vector3.new(-22, 4, 20)))
	createZonePart(zonesFolder, "VaultZone", Vector3.new(24, 8, 20), CFrame.new(origin + Vector3.new(22, 4, 20)))
	createZonePart(zonesFolder, "EntranceZone", Vector3.new(26, 8, 18), CFrame.new(origin + Vector3.new(0, 4, 34)))

	local boundariesFolder = ensureFolder(model, "Boundaries")
	local halfX = GameConfig.TYCOON_SIZE.X / 2
	local halfZ = GameConfig.TYCOON_SIZE.Z / 2
	local boundaryHeight = GameConfig.PLOT_BOUNDARY_HEIGHT
	createBoundaryPart(boundariesFolder, "BackBoundary", Vector3.new(GameConfig.TYCOON_SIZE.X, boundaryHeight, 2), CFrame.new(origin + Vector3.new(0, boundaryHeight / 2, -halfZ)))
	createBoundaryPart(boundariesFolder, "FrontBoundary", Vector3.new(GameConfig.TYCOON_SIZE.X, boundaryHeight, 2), CFrame.new(origin + Vector3.new(0, boundaryHeight / 2, halfZ)))
	createBoundaryPart(boundariesFolder, "LeftBoundary", Vector3.new(2, boundaryHeight, GameConfig.TYCOON_SIZE.Z), CFrame.new(origin + Vector3.new(-halfX, boundaryHeight / 2, 0)))
	createBoundaryPart(boundariesFolder, "RightBoundary", Vector3.new(2, boundaryHeight, GameConfig.TYCOON_SIZE.Z), CFrame.new(origin + Vector3.new(halfX, boundaryHeight / 2, 0)))

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

	local upgradeButtonsFolder = ensureFolder(model, "UpgradeButtons")
	local structureSocketsFolder = ensureFolder(model, "StructureSockets")
	ensurePart(structureSocketsFolder, "GeneratorSocket", Vector3.new(10, 1, 10), CFrame.new(origin + Vector3.new(0, 1.5, -10)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = true,
	})
	ensurePart(structureSocketsFolder, "CollectorSocket", Vector3.new(10, 1, 10), CFrame.new(origin + Vector3.new(0, 1.5, 16)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = true,
	})
	ensurePart(structureSocketsFolder, "DoorSocket", Vector3.new(12, 8, 4), CFrame.new(origin + Vector3.new(0, 4, 40)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = true,
	})
	ensurePart(structureSocketsFolder, "SecondFloorSocket", Vector3.new(30, 1, 18), CFrame.new(origin + Vector3.new(0, 10, -2)), {
		Transparency = 1,
		CanCollide = false,
		CanTouch = false,
		CanQuery = true,
	})

	local valuesFolder = ensureFolder(model, "Values")
	local ownerUserIdValue = ensureValue(valuesFolder, "IntValue", "OwnerUserId", 0)
	local ownerNameValue = ensureValue(valuesFolder, "StringValue", "OwnerName", "")
	local isClaimedValue = ensureValue(valuesFolder, "BoolValue", "IsClaimed", false)
	local tycoonIdValue = ensureValue(valuesFolder, "StringValue", "TycoonId", definition.Id)

	local claimLabel = ensureSurfaceLabel(claimPad, "Claim Tycoon", Enum.NormalId.Top, Color3.new(1, 1, 1))
	local ownerLabel = ensureSurfaceLabel(ownerSign, "Unclaimed", Enum.NormalId.Front, Color3.new(1, 1, 1))
	local claimPrompt = ensurePrompt(claimPad, "Claim Tycoon", definition.Id)

	baseFloor.Name = "BaseFloor"
	upgradeButtonsFolder.Name = "UpgradeButtons"
	structureSocketsFolder.Name = "StructureSockets"

	return {
		Spawn = spawn :: SpawnLocation,
		ClaimPad = claimPad,
		ClaimPrompt = claimPrompt,
		ClaimLabel = claimLabel,
		OwnerSign = ownerSign,
		OwnerLabel = ownerLabel,
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

	local refs = ensureWeek1Scaffolding(model, definition)

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
		ValuesFolder = refs.ValuesFolder,
		OwnerUserIdValue = refs.OwnerUserIdValue,
		OwnerNameValue = refs.OwnerNameValue,
		IsClaimedValue = refs.IsClaimedValue,
		TycoonIdValue = refs.TycoonIdValue,
	})

	self:setOwner(nil)
	return self
end

function Tycoon.bind(model: Model, definition: Definition): Instance
	local refs = ensureWeek1Scaffolding(model, definition)

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
		ValuesFolder = refs.ValuesFolder,
		OwnerUserIdValue = refs.OwnerUserIdValue,
		OwnerNameValue = refs.OwnerNameValue,
		IsClaimedValue = refs.IsClaimedValue,
		TycoonIdValue = refs.TycoonIdValue,
	})

	self:setOwner(nil)
	return self
end

function Tycoon:setOwner(player: Player?)
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

function Tycoon:teleportToSpawn(player: Player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = self.Spawn.CFrame + Vector3.new(0, 4, 0)
	end
end

return Tycoon
