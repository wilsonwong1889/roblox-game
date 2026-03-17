local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)
local Tycoon = require(script.Parent.Tycoon)
local TycoonOwnershipRegistry = require(script.Parent.TycoonOwnershipRegistry)

local TycoonService = {}

export type TycoonRecord = Tycoon.TycoonObject

local tycoonsById: { [string]: TycoonRecord } = {}
local ownershipRegistry = TycoonOwnershipRegistry.new()
local TARGET_TYCOON_COUNT = 8
local GRID_COLUMNS = 4
local GRID_ROWS = 2
local GRID_COLUMN_SPACING = 260
local GRID_ROW_SPACING = 252
local LOBBY_OFFSET_FROM_MAP = 132
local MAP_EDGE_PADDING = 92
local TYCOON_ACCENTS = {
	Color3.fromRGB(73, 170, 255),
	Color3.fromRGB(255, 125, 96),
	Color3.fromRGB(124, 255, 174),
	Color3.fromRGB(255, 214, 102),
	Color3.fromRGB(185, 126, 255),
	Color3.fromRGB(102, 224, 255),
	Color3.fromRGB(255, 142, 188),
	Color3.fromRGB(172, 255, 220),
}

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
		existing.Size = size
		existing.CFrame = cframe
		existing.Anchored = true
		existing.TopSurface = Enum.SurfaceType.Smooth
		existing.BottomSurface = Enum.SurfaceType.Smooth
		if properties then
			for key, value in properties do
				(existing :: any)[key] = value
			end
		end
		return existing
	end

	if existing then
		existing:Destroy()
	end

	return createPart(parent, name, size, cframe, properties)
end

local function createSurfaceLabel(parent: BasePart, text: string, face: Enum.NormalId, textColor: Color3): TextLabel
	local gui = Instance.new("SurfaceGui")
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 28
	gui.Parent = parent

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = textColor
	label.Text = text
	label.Parent = gui

	return label
end

local function getGeneratedTycoonId(index: number): string
	return string.format("Tycoon%s", string.char(64 + index))
end

local function getRuntimeTycoonDefinitions(): { Tycoon.Definition }
	local configuredDefinitions = table.clone(GameConfig.TYCOONS)
	if #configuredDefinitions >= TARGET_TYCOON_COUNT then
		local definitions = {}
		for index = 1, TARGET_TYCOON_COUNT do
			definitions[index] = configuredDefinitions[index]
		end
		return definitions
	end

	local definitions = {}
	local index = 0
	local xStart = -((GRID_COLUMNS - 1) * GRID_COLUMN_SPACING) / 2
	local zStart = -((GRID_ROWS - 1) * GRID_ROW_SPACING) / 2

	for row = 1, GRID_ROWS do
		for column = 1, GRID_COLUMNS do
			index += 1
			local configured = configuredDefinitions[index]
			local origin = Vector3.new(
				xStart + ((column - 1) * GRID_COLUMN_SPACING),
				0,
				zStart + ((row - 1) * GRID_ROW_SPACING)
			)
			definitions[index] = {
				Id = if configured and configured.Id then configured.Id else getGeneratedTycoonId(index),
				Origin = origin,
				Accent = if configured and configured.Accent then configured.Accent else TYCOON_ACCENTS[((index - 1) % #TYCOON_ACCENTS) + 1],
			}
		end
	end

	return definitions
end

local function getTycoonBounds(definitions: { Tycoon.Definition })
	local minX = math.huge
	local maxX = -math.huge
	local minZ = math.huge
	local maxZ = -math.huge

	for _, definition in definitions do
		minX = math.min(minX, definition.Origin.X)
		maxX = math.max(maxX, definition.Origin.X)
		minZ = math.min(minZ, definition.Origin.Z)
		maxZ = math.max(maxZ, definition.Origin.Z)
	end

	if minX == math.huge then
		minX = 0
		maxX = 0
		minZ = 0
		maxZ = 0
	end

	local totalWidth = (maxX - minX) + GameConfig.TYCOON_SIZE.X + GameConfig.TYCOON_PADDING * 2
	local totalDepth = (maxZ - minZ) + GameConfig.TYCOON_SIZE.Z + GameConfig.TYCOON_PADDING * 2
	local centerX = (minX + maxX) / 2
	local centerZ = (minZ + maxZ) / 2

	return centerX, centerZ, totalWidth, totalDepth, minX, maxX, minZ, maxZ
end

local function ensureLobby(lobbyFolder: Folder, centerX: number, centerZ: number, depth: number)
	local spawnZ = centerZ - (depth / 2) - LOBBY_OFFSET_FROM_MAP
	local plazaSize = Vector3.new(math.max(72, GRID_COLUMNS * 20), 1, 30)

	local lobbyPad = ensurePart(lobbyFolder, "SpawnPlatform", Vector3.new(84, 1, 32), CFrame.new(centerX, 1.5, spawnZ), {
		Color = Color3.fromRGB(245, 245, 245),
		Material = Enum.Material.SmoothPlastic,
	})

	if not lobbyPad:FindFirstChildWhichIsA("SurfaceGui") then
		createSurfaceLabel(lobbyPad, "Shared Spawn", Enum.NormalId.Top, Color3.fromRGB(25, 25, 25))
	end

	local lobbySpawn = lobbyFolder:FindFirstChild("SpawnLocation")
	if lobbySpawn and not lobbySpawn:IsA("SpawnLocation") then
		lobbySpawn:Destroy()
		lobbySpawn = nil
	end

	if not lobbySpawn then
		lobbySpawn = Instance.new("SpawnLocation")
		lobbySpawn.Name = "SpawnLocation"
		lobbySpawn.Parent = lobbyFolder
	end

	lobbySpawn.Size = Vector3.new(12, 1, 12)
	lobbySpawn.CFrame = CFrame.new(centerX, 2.5, spawnZ)
	lobbySpawn.Neutral = true
	lobbySpawn.Anchored = true
	lobbySpawn.Enabled = true

	local plaza = ensurePart(lobbyFolder, "LobbyPlaza", plazaSize, CFrame.new(centerX, 1.25, spawnZ + 28), {
		Color = Color3.fromRGB(222, 226, 234),
		Material = Enum.Material.Concrete,
	})
	createSurfaceLabel(plaza, "Central Hub", Enum.NormalId.Top, Color3.fromRGB(26, 30, 40))
end

local function ensureSharedMap(sharedMapFolder: Folder, centerX: number, centerZ: number, groundWidth: number, groundDepth: number)
	local roadColor = Color3.fromRGB(33, 36, 44)
	local roadMat = Enum.Material.Asphalt

	ensurePart(sharedMapFolder, "Ground", Vector3.new(groundWidth + MAP_EDGE_PADDING * 2, 2, groundDepth + MAP_EDGE_PADDING * 2), CFrame.new(centerX, -1, centerZ), {
		Color = Color3.fromRGB(94, 118, 80),
		Material = Enum.Material.Grass,
	})

	ensurePart(sharedMapFolder, "RoadEastWest", Vector3.new(groundWidth + MAP_EDGE_PADDING, 0.5, 14), CFrame.new(centerX, 0.1, centerZ), {
		Color = roadColor,
		Material = roadMat,
	})
	ensurePart(sharedMapFolder, "RoadNorthSouth", Vector3.new(14, 0.5, groundDepth + MAP_EDGE_PADDING), CFrame.new(centerX, 0.1, centerZ), {
		Color = roadColor,
		Material = roadMat,
	})
	local centralPlaza = ensurePart(sharedMapFolder, "CentralPlaza", Vector3.new(84, 1, 84), CFrame.new(centerX, 1.25, centerZ), {
		Color = Color3.fromRGB(225, 231, 236),
		Material = Enum.Material.Concrete,
	})
	createSurfaceLabel(centralPlaza, "Map Hub", Enum.NormalId.Top, Color3.fromRGB(26, 30, 40))
end

function TycoonService.initialize()
	local legacyMap = workspace:FindFirstChild("CompetitiveTycoonMap")
	if legacyMap then
		legacyMap:Destroy()
	end

	local definitions = getRuntimeTycoonDefinitions()
	local centerX, centerZ, groundWidth, groundDepth = getTycoonBounds(definitions)

	local lobbyFolder = ensureFolder(workspace, GameConfig.WORKSPACE_FOLDERS.Lobby)
	local sharedMapFolder = ensureFolder(workspace, GameConfig.WORKSPACE_FOLDERS.SharedMap)
	local tycoonPlotsFolder = ensureFolder(workspace, GameConfig.WORKSPACE_FOLDERS.TycoonPlots)

	ensureLobby(lobbyFolder, centerX, centerZ, groundDepth)
	ensureSharedMap(sharedMapFolder, centerX, centerZ, groundWidth, groundDepth)

	tycoonsById = {}
	ownershipRegistry = TycoonOwnershipRegistry.new()

	for _, definition in definitions do
		local existingModel = tycoonPlotsFolder:FindFirstChild(definition.Id)
		local tycoon: TycoonRecord

		if existingModel and existingModel:IsA("Model") then
			local ok, result = pcall(Tycoon.bind, existingModel, definition)
			if ok then
				tycoon = result
			else
				warn(string.format("Failed to bind prebuilt tycoon %s. Rebuilding default Week 4 scaffold. %s", definition.Id, tostring(result)))
				existingModel:Destroy()
				tycoon = Tycoon.new(definition, tycoonPlotsFolder)
			end
		else
			if existingModel then
				existingModel:Destroy()
			end
			tycoon = Tycoon.new(definition, tycoonPlotsFolder)
		end

		tycoonsById[tycoon.Id] = tycoon
	end
end

function TycoonService.getTycoons(): { [string]: TycoonRecord }
	return tycoonsById
end

function TycoonService.getTycoon(tycoonId: string): TycoonRecord?
	return tycoonsById[tycoonId]
end

function TycoonService.getPlayerTycoon(player: Player): TycoonRecord?
	local tycoonId = TycoonOwnershipRegistry.getPlayerTycoonId(ownershipRegistry, player)
	return if tycoonId then tycoonsById[tycoonId] else nil
end

function TycoonService.isOwnedBy(tycoonId: string, player: Player): boolean
	local tycoon = tycoonsById[tycoonId]
	return tycoon ~= nil and tycoon:isOwnedBy(player)
end

function TycoonService.claimTycoon(player: Player, tycoonId: string): boolean
	local tycoon = tycoonsById[tycoonId]
	if not tycoon then
		return false
	end

	if not TycoonOwnershipRegistry.claim(ownershipRegistry, player, tycoonId) then
		return false
	end

	tycoon:setOwner(player)
	return true
end

function TycoonService.releaseTycoon(player: Player): string?
	local tycoonId = TycoonOwnershipRegistry.releasePlayer(ownershipRegistry, player)
	if not tycoonId then
		return nil
	end

	local tycoon = tycoonsById[tycoonId]
	if tycoon then
		tycoon:setOwner(nil)
	end

	return tycoonId
end

function TycoonService.teleportToSpawn(player: Player, tycoonId: string)
	local tycoon = tycoonsById[tycoonId]
	if tycoon then
		tycoon:teleportToSpawn(player)
	end
end

function TycoonService.applyVisualState(tycoonId: string, purchased: { [string]: boolean }, collectorStored: number)
	local tycoon = tycoonsById[tycoonId]
	if tycoon then
		tycoon:applyVisualState(purchased, collectorStored)
	end
end

function TycoonService.updateButtons(tycoonId: string, purchased: { [string]: boolean })
	local tycoon = tycoonsById[tycoonId]
	if tycoon then
		tycoon:updateButtons(purchased)
	end
end

return TycoonService
