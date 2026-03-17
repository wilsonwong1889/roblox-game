local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)
local Tycoon = require(script.Parent.Tycoon)
local TycoonOwnershipRegistry = require(script.Parent.TycoonOwnershipRegistry)

local TycoonService = {}

export type TycoonRecord = Tycoon.Instance

local tycoonsById: { [string]: TycoonRecord } = {}
local ownershipRegistry = TycoonOwnershipRegistry.new()

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

local function getTycoonBounds()
	local minX = math.huge
	local maxX = -math.huge

	for _, definition in GameConfig.TYCOONS do
		minX = math.min(minX, definition.Origin.X)
		maxX = math.max(maxX, definition.Origin.X)
	end

	if minX == math.huge then
		minX = 0
		maxX = 0
	end

	local totalWidth = (maxX - minX) + GameConfig.TYCOON_SIZE.X + GameConfig.TYCOON_PADDING * 2
	local centerX = (minX + maxX) / 2
	local totalDepth = GameConfig.TYCOON_SIZE.Z + GameConfig.TYCOON_PADDING * 2

	return centerX, totalWidth, totalDepth, minX, maxX
end

local function ensureLobby(lobbyFolder: Folder)
	local centerX, _, _, _, _ = getTycoonBounds()
	local spawnZ = -(GameConfig.TYCOON_SIZE.Z / 2 + 44)

	local lobbyPad = ensurePart(lobbyFolder, "SpawnPlatform", Vector3.new(40, 1, 20), CFrame.new(centerX, 1.5, spawnZ), {
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
end

local function ensureSharedMap(sharedMapFolder: Folder)
	local centerX, groundWidth, groundDepth, minX, maxX = getTycoonBounds()

	ensurePart(sharedMapFolder, "Ground", Vector3.new(groundWidth, 2, groundDepth), CFrame.new(centerX, -1, 0), {
		Color = Color3.fromRGB(94, 118, 80),
		Material = Enum.Material.Grass,
	})

	if #GameConfig.TYCOONS == 2 then
		ensurePart(sharedMapFolder, "Divider", Vector3.new(6, 26, groundDepth - 2 * GameConfig.TYCOON_PADDING), CFrame.new((minX + maxX) / 2, 13, 0), {
			Color = Color3.fromRGB(29, 31, 39),
			Material = Enum.Material.SmoothPlastic,
		})
	end
end

function TycoonService.initialize()
	local legacyMap = workspace:FindFirstChild("CompetitiveTycoonMap")
	if legacyMap then
		legacyMap:Destroy()
	end

	if #GameConfig.TYCOONS ~= GameConfig.ACTIVE_TYCOON_COUNT then
		warn(string.format(
			"Week 2 expects exactly %d tycoons, but GameConfig defines %d.",
			GameConfig.ACTIVE_TYCOON_COUNT,
			#GameConfig.TYCOONS
		))
	end

	local lobbyFolder = ensureFolder(workspace, GameConfig.WORKSPACE_FOLDERS.Lobby)
	local sharedMapFolder = ensureFolder(workspace, GameConfig.WORKSPACE_FOLDERS.SharedMap)
	local tycoonPlotsFolder = ensureFolder(workspace, GameConfig.WORKSPACE_FOLDERS.TycoonPlots)

	ensureLobby(lobbyFolder)
	ensureSharedMap(sharedMapFolder)

	tycoonsById = {}
	ownershipRegistry = TycoonOwnershipRegistry.new()

	for _, definition in GameConfig.TYCOONS do
		local existingModel = tycoonPlotsFolder:FindFirstChild(definition.Id)
		local tycoon: TycoonRecord

		if existingModel and existingModel:IsA("Model") then
			local ok, result = pcall(Tycoon.bind, existingModel, definition)
			if ok then
				tycoon = result
			else
				warn(string.format("Failed to bind prebuilt tycoon %s. Rebuilding default Week 2 scaffold. %s", definition.Id, tostring(result)))
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
