local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)
local Tycoon = require(script.Parent.Tycoon)
local TycoonOwnershipRegistry = require(script.Parent.TycoonOwnershipRegistry)

local TycoonService = {}

export type TycoonRecord = Tycoon.TycoonObject

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

local function ensureNamedInstance(parent: Instance, className: string, name: string): Instance
	local existing = parent:FindFirstChild(name)
	if existing and existing.ClassName == className then
		return existing
	end

	if existing then
		existing:Destroy()
	end

	local instance = Instance.new(className)
	instance.Name = name
	instance.Parent = parent
	return instance
end

local function clearFolder(folder: Folder)
	for _, child in folder:GetChildren() do
		child:Destroy()
	end
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

local function getRuntimeTycoonDefinitions(): { Tycoon.Definition }
	return table.clone(GameConfig.TYCOONS)
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
	local spawnZ = centerZ
	local plazaSize = Vector3.new(
		math.max(84, GameConfig.MAP_CENTRAL_PLAZA_SIZE.X * 0.58),
		1,
		math.max(30, GameConfig.MAP_CENTRAL_PLAZA_SIZE.Z * 0.58)
	)

	local lobbyPad = ensurePart(lobbyFolder, "SpawnPlatform", Vector3.new(34, 1, 34), CFrame.new(centerX, 2.2, spawnZ), {
		Color = Color3.fromRGB(245, 245, 245),
		Material = Enum.Material.SmoothPlastic,
	})

	ensureSurfaceLabel(lobbyPad, "Shared Spawn", Enum.NormalId.Top, Color3.fromRGB(25, 25, 25))

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

	lobbySpawn.Size = Vector3.new(14, 1, 14)
	lobbySpawn.CFrame = CFrame.new(centerX, 3.2, spawnZ)
	lobbySpawn.Neutral = true
	lobbySpawn.Anchored = true
	lobbySpawn.Enabled = true

	local plaza = ensurePart(lobbyFolder, "LobbyPlaza", plazaSize, CFrame.new(centerX, 1.25, spawnZ), {
		Color = Color3.fromRGB(222, 226, 234),
		Material = Enum.Material.Concrete,
	})
	ensureSurfaceLabel(plaza, "Central Spawn", Enum.NormalId.Top, Color3.fromRGB(26, 30, 40))

	if GameConfig.VIP_STARTER_PACK.ENABLED then
		local vipPad = ensurePart(lobbyFolder, "VipStarterPackPad", Vector3.new(18, 1, 18), CFrame.new(centerX + 36, 2.3, spawnZ - 36), {
			Color = Color3.fromRGB(255, 203, 82),
			Material = Enum.Material.Neon,
		})
		ensureSurfaceLabel(
			vipPad,
			string.format("%s\n%d Robux", GameConfig.VIP_STARTER_PACK.NAME, GameConfig.VIP_STARTER_PACK.PRICE_ROBUX),
			Enum.NormalId.Top,
			Color3.fromRGB(58, 35, 18)
		)
		ensurePrompt(vipPad, "Buy Pass", GameConfig.VIP_STARTER_PACK.NAME, GameConfig.CLAIM_PROMPT_RANGE)

		local vipSign = ensurePart(lobbyFolder, "VipStarterPackSign", Vector3.new(20, 10, 1), CFrame.new(centerX + 36, 9, spawnZ - 48), {
			Color = Color3.fromRGB(40, 31, 30),
			Material = Enum.Material.SmoothPlastic,
		})
		ensureSurfaceLabel(
			vipSign,
			string.format("VIP MONEY STARTER PACK\n+$%d STARTING CASH", GameConfig.VIP_STARTER_PACK.CASH_BONUS),
			Enum.NormalId.Front,
			Color3.fromRGB(255, 240, 191)
		)
	end
end

local function buildPlanterCluster(parent: Instance, name: string, center: Vector3, accent: Color3)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent

	createPart(folder, "Base", Vector3.new(26, 2, 26), CFrame.new(center + Vector3.new(0, 1, 0)), {
		Color = Color3.fromRGB(201, 207, 215),
		Material = Enum.Material.Concrete,
	})
	createPart(folder, "Trim", Vector3.new(20, 1, 20), CFrame.new(center + Vector3.new(0, 2.1, 0)), {
		Color = accent,
		Material = Enum.Material.SmoothPlastic,
	})
	createPart(folder, "Trunk", Vector3.new(3, 18, 3), CFrame.new(center + Vector3.new(0, 11, 0)), {
		Color = Color3.fromRGB(102, 79, 56),
		Material = Enum.Material.Wood,
	})
	createPart(folder, "CanopyLower", Vector3.new(14, 8, 14), CFrame.new(center + Vector3.new(0, 21, 0)), {
		Color = Color3.fromRGB(88, 156, 98),
		Material = Enum.Material.Grass,
		Shape = Enum.PartType.Ball,
	})
	createPart(folder, "CanopyUpper", Vector3.new(10, 7, 10), CFrame.new(center + Vector3.new(0, 26, 0)), {
		Color = Color3.fromRGB(109, 177, 116),
		Material = Enum.Material.Grass,
		Shape = Enum.PartType.Ball,
	})
	createPart(folder, "BenchA", Vector3.new(10, 2, 3), CFrame.new(center + Vector3.new(-10, 2.5, 0)), {
		Color = Color3.fromRGB(124, 96, 72),
		Material = Enum.Material.WoodPlanks,
	})
	createPart(folder, "BenchB", Vector3.new(10, 2, 3), CFrame.new(center + Vector3.new(10, 2.5, 0)), {
		Color = Color3.fromRGB(124, 96, 72),
		Material = Enum.Material.WoodPlanks,
	})
end

local function buildTreeCluster(parent: Instance, name: string, center: Vector3, canopyColor: Color3, scale: number?)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent

	local sizeScale = scale or 1
	createPart(folder, "Trunk", Vector3.new(4, 22 * sizeScale, 4), CFrame.new(center + Vector3.new(0, 11 * sizeScale, 0)), {
		Color = Color3.fromRGB(109, 79, 60),
		Material = Enum.Material.Wood,
	})
	createPart(folder, "CanopyLow", Vector3.new(18 * sizeScale, 10 * sizeScale, 18 * sizeScale), CFrame.new(center + Vector3.new(0, 23 * sizeScale, 0)), {
		Color = canopyColor,
		Material = Enum.Material.Grass,
		Shape = Enum.PartType.Ball,
	})
	createPart(folder, "CanopyMid", Vector3.new(14 * sizeScale, 9 * sizeScale, 14 * sizeScale), CFrame.new(center + Vector3.new(0, 29 * sizeScale, 0)), {
		Color = canopyColor:Lerp(Color3.new(1, 1, 1), 0.08),
		Material = Enum.Material.Grass,
		Shape = Enum.PartType.Ball,
	})
	createPart(folder, "CanopyTop", Vector3.new(10 * sizeScale, 8 * sizeScale, 10 * sizeScale), CFrame.new(center + Vector3.new(0, 34 * sizeScale, 0)), {
		Color = canopyColor:Lerp(Color3.new(1, 1, 1), 0.14),
		Material = Enum.Material.Grass,
		Shape = Enum.PartType.Ball,
	})
end

local function buildBoundaryForestPatch(parent: Instance, name: string, center: Vector3, spreadX: number, spreadZ: number, count: number)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent

	for index = 1, count do
		local xAlpha = ((index * 29) % 100) / 100
		local zAlpha = ((index * 53) % 100) / 100
		local x = center.X + ((xAlpha - 0.5) * spreadX)
		local z = center.Z + ((zAlpha - 0.5) * spreadZ)
		local canopyColor = Color3.fromRGB(86 + (index % 4) * 10, 144 + (index % 3) * 16, 102 + (index % 5) * 8)
		buildTreeCluster(folder, "PatchTree" .. index, Vector3.new(x, 0, z), canopyColor, if index % 4 == 0 then 1.22 else 0.92)
	end
end

local function buildMountainCluster(parent: Instance, name: string, center: Vector3, primary: Color3, accent: Color3, yawDegrees: number)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent

	local baseCFrame = CFrame.new(center) * CFrame.Angles(0, math.rad(yawDegrees), 0)
	createPart(folder, "Base", Vector3.new(72, 18, 46), baseCFrame * CFrame.new(0, 9, 0), {
		Color = primary,
		Material = Enum.Material.Slate,
	})
	createPart(folder, "PeakA", Vector3.new(32, 50, 28), baseCFrame * CFrame.new(-14, 34, -4), {
		Color = accent,
		Material = Enum.Material.Rock,
		Shape = Enum.PartType.Wedge,
	})
	createPart(folder, "PeakB", Vector3.new(36, 62, 30), baseCFrame * CFrame.new(12, 39, 4), {
		Color = primary:Lerp(Color3.new(1, 1, 1), 0.1),
		Material = Enum.Material.Rock,
		Shape = Enum.PartType.Wedge,
	})
	createPart(folder, "SnowCapA", Vector3.new(22, 10, 18), baseCFrame * CFrame.new(-10, 58, -2), {
		Color = Color3.fromRGB(255, 236, 246),
		Material = Enum.Material.SmoothPlastic,
	})
	createPart(folder, "SnowCapB", Vector3.new(24, 12, 20), baseCFrame * CFrame.new(14, 68, 2), {
		Color = Color3.fromRGB(255, 231, 243),
		Material = Enum.Material.SmoothPlastic,
	})
end

local function ensurePinkSky()
	if not GameConfig.PINK_SKY_ENABLED then
		return
	end

	Lighting.ClockTime = 17.35
	Lighting.Brightness = 2.6
	Lighting.ExposureCompensation = 0.15
	Lighting.Ambient = GameConfig.PINK_SKY_AMBIENT
	Lighting.OutdoorAmbient = GameConfig.PINK_SKY_OUTDOOR_AMBIENT
	Lighting.FogColor = GameConfig.PINK_SKY_FOG_COLOR
	Lighting.FogStart = 420
	Lighting.FogEnd = 2200
	Lighting.ColorShift_Top = GameConfig.PINK_SKY_TOP_COLOR
	Lighting.ColorShift_Bottom = GameConfig.PINK_SKY_BOTTOM_COLOR
	Lighting.EnvironmentDiffuseScale = 0.45
	Lighting.EnvironmentSpecularScale = 0.35

	local atmosphere = ensureNamedInstance(Lighting, "Atmosphere", "PinkSkyAtmosphere") :: Atmosphere
	atmosphere.Color = GameConfig.PINK_SKY_BOTTOM_COLOR
	atmosphere.Decay = Color3.fromRGB(255, 154, 208)
	atmosphere.Density = 0.31
	atmosphere.Glare = 0.22
	atmosphere.Haze = 1.25
	atmosphere.Offset = 0

	local bloom = ensureNamedInstance(Lighting, "BloomEffect", "PinkSkyBloom") :: BloomEffect
	bloom.Enabled = true
	bloom.Intensity = 0.42
	bloom.Size = 30
	bloom.Threshold = 1.15

	local colorCorrection = ensureNamedInstance(Lighting, "ColorCorrectionEffect", "PinkSkyColorCorrection") :: ColorCorrectionEffect
	colorCorrection.Enabled = true
	colorCorrection.Brightness = 0.03
	colorCorrection.Contrast = 0.08
	colorCorrection.Saturation = 0.2
	colorCorrection.TintColor = Color3.fromRGB(255, 215, 235)

	local sunRays = ensureNamedInstance(Lighting, "SunRaysEffect", "PinkSkySunRays") :: SunRaysEffect
	sunRays.Enabled = true
	sunRays.Intensity = 0.08
	sunRays.Spread = 0.86

	local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds")
	if not clouds then
		clouds = Instance.new("Clouds")
		clouds.Parent = workspace.Terrain
	end
	clouds.Cover = 0.68
	clouds.Density = 0.95
	clouds.Color = Color3.fromRGB(255, 188, 228)
end

local function buildBoundaryShowpiece(parent: Instance, name: string, baseCFrame: CFrame, primary: Color3, secondary: Color3, accent: Color3)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent

	local function place(localOffset: CFrame, partName: string, size: Vector3, properties: { [string]: any }?)
		createPart(folder, partName, size, baseCFrame * localOffset, properties)
	end

	place(CFrame.new(0, 1, 0), "Base", Vector3.new(38, 2, 22), {
		Color = Color3.fromRGB(230, 218, 232),
		Material = Enum.Material.Marble,
	})
	place(CFrame.new(0, 2.1, 0), "InnerBase", Vector3.new(28, 1, 14), {
		Color = secondary,
		Material = Enum.Material.SmoothPlastic,
	})
	place(CFrame.new(-12, 13, 0), "PylonLeft", Vector3.new(4, 24, 4), {
		Color = primary,
		Material = Enum.Material.SmoothPlastic,
	})
	place(CFrame.new(12, 13, 0), "PylonRight", Vector3.new(4, 24, 4), {
		Color = primary,
		Material = Enum.Material.SmoothPlastic,
	})
	place(CFrame.new(0, 24, 0), "ArchBeam", Vector3.new(28, 3, 4), {
		Color = secondary,
		Material = Enum.Material.SmoothPlastic,
	})
	place(CFrame.new(0, 16, -3), "CenterOrb", Vector3.new(7, 7, 7), {
		Color = accent,
		Material = Enum.Material.Neon,
		Shape = Enum.PartType.Ball,
	})
	place(CFrame.new(-7.5, 11, 6) * CFrame.Angles(0, math.rad(18), 0), "WingLeft", Vector3.new(7, 16, 1), {
		Color = primary,
		Material = Enum.Material.Neon,
		Transparency = 0.1,
	})
	place(CFrame.new(7.5, 11, 6) * CFrame.Angles(0, math.rad(-18), 0), "WingRight", Vector3.new(7, 16, 1), {
		Color = primary,
		Material = Enum.Material.Neon,
		Transparency = 0.1,
	})
	place(CFrame.new(-6, 6.5, 5), "CrystalLeft", Vector3.new(2.5, 11, 2.5), {
		Color = secondary,
		Material = Enum.Material.Neon,
	})
	place(CFrame.new(0, 8, 7), "CrystalMid", Vector3.new(3, 14, 3), {
		Color = accent,
		Material = Enum.Material.Neon,
	})
	place(CFrame.new(6, 6.5, 5), "CrystalRight", Vector3.new(2.5, 11, 2.5), {
		Color = secondary,
		Material = Enum.Material.Neon,
	})
end

local function ensureSharedMap(sharedMapFolder: Folder, centerX: number, centerZ: number, groundWidth: number, groundDepth: number)
	local roadColor = Color3.fromRGB(33, 36, 44)
	local roadMat = Enum.Material.Asphalt
	local boundaryHeight = GameConfig.MAP_BOUNDARY_HEIGHT
	local boundaryThickness = GameConfig.MAP_BOUNDARY_THICKNESS
	local boundaryInset = GameConfig.MAP_BOUNDARY_INSET
	local halfWidth = groundWidth / 2
	local halfDepth = groundDepth / 2
	local boundaryColor = GameConfig.MAP_BOUNDARY_COLOR
	local boundaryGlowColor = GameConfig.MAP_BOUNDARY_GLOW_COLOR
	local decorPrimary = GameConfig.MAP_DECOR_PRIMARY
	local decorSecondary = GameConfig.MAP_DECOR_SECONDARY
	local decorAccent = GameConfig.MAP_DECOR_ACCENT

	ensurePart(sharedMapFolder, "Ground", Vector3.new(groundWidth, 2, groundDepth), CFrame.new(centerX, -1, centerZ), {
		Color = Color3.fromRGB(120, 110, 132),
		Material = Enum.Material.Grass,
	})

	ensurePart(sharedMapFolder, "RoadEastWest", Vector3.new(groundWidth - 42, 0.5, 16), CFrame.new(centerX, 0.1, centerZ), {
		Color = roadColor,
		Material = roadMat,
	})
	ensurePart(sharedMapFolder, "RoadNorthSouth", Vector3.new(16, 0.5, groundDepth - 42), CFrame.new(centerX, 0.1, centerZ), {
		Color = roadColor,
		Material = roadMat,
	})
	local centralPlaza = ensurePart(sharedMapFolder, "CentralPlaza", GameConfig.MAP_CENTRAL_PLAZA_SIZE, CFrame.new(centerX, 1.25, centerZ), {
		Color = Color3.fromRGB(242, 225, 238),
		Material = Enum.Material.Concrete,
	})
	ensureSurfaceLabel(centralPlaza, "Pink Sky Hub", Enum.NormalId.Top, Color3.fromRGB(94, 50, 92))

	local decorationsFolder = ensureFolder(sharedMapFolder, "Decorations")
	clearFolder(decorationsFolder)

	local centerDecor = ensureFolder(decorationsFolder, "CenterDecor")
	createPart(centerDecor, "SpawnRing", Vector3.new(56, 1, 56), CFrame.new(centerX, 1.8, centerZ), {
		Color = Color3.fromRGB(255, 232, 246),
		Material = Enum.Material.Marble,
	})
	createPart(centerDecor, "SpawnGlow", Vector3.new(46, 0.6, 46), CFrame.new(centerX, 2.35, centerZ), {
		Color = boundaryGlowColor,
		Material = Enum.Material.Neon,
		Transparency = 0.08,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
	})
	createPart(centerDecor, "NorthPylon", Vector3.new(6, 20, 6), CFrame.new(centerX, 11, centerZ - 28), {
		Color = decorPrimary,
		Material = Enum.Material.SmoothPlastic,
	})
	createPart(centerDecor, "SouthPylon", Vector3.new(6, 20, 6), CFrame.new(centerX, 11, centerZ + 28), {
		Color = decorPrimary,
		Material = Enum.Material.SmoothPlastic,
	})
	createPart(centerDecor, "WestPylon", Vector3.new(6, 20, 6), CFrame.new(centerX - 28, 11, centerZ), {
		Color = decorPrimary,
		Material = Enum.Material.SmoothPlastic,
	})
	createPart(centerDecor, "EastPylon", Vector3.new(6, 20, 6), CFrame.new(centerX + 28, 11, centerZ), {
		Color = decorPrimary,
		Material = Enum.Material.SmoothPlastic,
	})
	createPart(centerDecor, "CenterCrystal", Vector3.new(12, 12, 12), CFrame.new(centerX, 10, centerZ), {
		Color = decorAccent,
		Material = Enum.Material.Neon,
		Shape = Enum.PartType.Ball,
	})

	local centerRadius = GameConfig.MAP_CENTER_DECORATION_RADIUS
	buildPlanterCluster(decorationsFolder, "CenterNorth", Vector3.new(centerX, 0, centerZ - centerRadius), Color3.fromRGB(73, 170, 255))
	buildPlanterCluster(decorationsFolder, "CenterSouth", Vector3.new(centerX, 0, centerZ + centerRadius), Color3.fromRGB(255, 125, 96))
	buildPlanterCluster(decorationsFolder, "CenterWest", Vector3.new(centerX - centerRadius, 0, centerZ), Color3.fromRGB(145, 255, 158))
	buildPlanterCluster(decorationsFolder, "CenterEast", Vector3.new(centerX + centerRadius, 0, centerZ), Color3.fromRGB(255, 211, 103))

	local outerBoundaryFolder = ensureFolder(decorationsFolder, "Boundaries")
	createPart(outerBoundaryFolder, "NorthBoundary", Vector3.new(groundWidth - 8, boundaryHeight, boundaryThickness), CFrame.new(centerX, boundaryHeight / 2, centerZ - halfDepth + (boundaryThickness / 2)), {
		Color = boundaryColor,
		Material = Enum.Material.Slate,
		Transparency = 0.12,
	})
	createPart(outerBoundaryFolder, "SouthBoundary", Vector3.new(groundWidth - 8, boundaryHeight, boundaryThickness), CFrame.new(centerX, boundaryHeight / 2, centerZ + halfDepth - (boundaryThickness / 2)), {
		Color = boundaryColor,
		Material = Enum.Material.Slate,
		Transparency = 0.12,
	})
	createPart(outerBoundaryFolder, "WestBoundary", Vector3.new(boundaryThickness, boundaryHeight, groundDepth - 8), CFrame.new(centerX - halfWidth + (boundaryThickness / 2), boundaryHeight / 2, centerZ), {
		Color = boundaryColor,
		Material = Enum.Material.Slate,
		Transparency = 0.12,
	})
	createPart(outerBoundaryFolder, "EastBoundary", Vector3.new(boundaryThickness, boundaryHeight, groundDepth - 8), CFrame.new(centerX + halfWidth - (boundaryThickness / 2), boundaryHeight / 2, centerZ), {
		Color = boundaryColor,
		Material = Enum.Material.Slate,
		Transparency = 0.12,
	})
	createPart(outerBoundaryFolder, "NorthGlow", Vector3.new(groundWidth - 26, 5, 4), CFrame.new(centerX, 6, centerZ - halfDepth + boundaryInset), {
		Color = boundaryGlowColor,
		Material = Enum.Material.Neon,
		Transparency = 0.05,
	})
	createPart(outerBoundaryFolder, "SouthGlow", Vector3.new(groundWidth - 26, 5, 4), CFrame.new(centerX, 6, centerZ + halfDepth - boundaryInset), {
		Color = boundaryGlowColor,
		Material = Enum.Material.Neon,
		Transparency = 0.05,
	})
	createPart(outerBoundaryFolder, "WestGlow", Vector3.new(4, 5, groundDepth - 26), CFrame.new(centerX - halfWidth + boundaryInset, 6, centerZ), {
		Color = boundaryGlowColor,
		Material = Enum.Material.Neon,
		Transparency = 0.05,
	})
	createPart(outerBoundaryFolder, "EastGlow", Vector3.new(4, 5, groundDepth - 26), CFrame.new(centerX + halfWidth - boundaryInset, 6, centerZ), {
		Color = boundaryGlowColor,
		Material = Enum.Material.Neon,
		Transparency = 0.05,
	})

	local showcaseFolder = ensureFolder(decorationsFolder, "BoundaryShowpieces")
	local function inwardFacingCFrame(position: Vector3): CFrame
		return CFrame.lookAt(position, Vector3.new(centerX, position.Y, centerZ))
	end

	buildBoundaryShowpiece(showcaseFolder, "NorthShowpiece", inwardFacingCFrame(Vector3.new(centerX, 0, centerZ - halfDepth + 38)), decorPrimary, decorSecondary, decorAccent)
	buildBoundaryShowpiece(showcaseFolder, "SouthShowpiece", inwardFacingCFrame(Vector3.new(centerX, 0, centerZ + halfDepth - 38)), decorPrimary, decorSecondary, decorAccent)
	buildBoundaryShowpiece(showcaseFolder, "WestShowpiece", inwardFacingCFrame(Vector3.new(centerX - halfWidth + 38, 0, centerZ)), decorPrimary, decorSecondary, decorAccent)
	buildBoundaryShowpiece(showcaseFolder, "EastShowpiece", inwardFacingCFrame(Vector3.new(centerX + halfWidth - 38, 0, centerZ)), decorPrimary, decorSecondary, decorAccent)

	local cornerHalfWidth = halfWidth - GameConfig.MAP_CORNER_DECORATION_INSET
	local cornerHalfDepth = halfDepth - GameConfig.MAP_CORNER_DECORATION_INSET
	buildPlanterCluster(decorationsFolder, "CornerNorthWest", Vector3.new(centerX - cornerHalfWidth, 0, centerZ - cornerHalfDepth), Color3.fromRGB(196, 144, 255))
	buildPlanterCluster(decorationsFolder, "CornerNorthEast", Vector3.new(centerX + cornerHalfWidth, 0, centerZ - cornerHalfDepth), Color3.fromRGB(125, 225, 255))
	buildPlanterCluster(decorationsFolder, "CornerSouthWest", Vector3.new(centerX - cornerHalfWidth, 0, centerZ + cornerHalfDepth), Color3.fromRGB(255, 146, 196))
	buildPlanterCluster(decorationsFolder, "CornerSouthEast", Vector3.new(centerX + cornerHalfWidth, 0, centerZ + cornerHalfDepth), Color3.fromRGB(159, 255, 211))

	local forestFolder = ensureFolder(decorationsFolder, "ForestRing")
	local treeRadius = GameConfig.MAP_TREE_RING_RADIUS
	for treeIndex = 1, GameConfig.MAP_TREE_CLUSTER_COUNT do
		local alpha = ((treeIndex - 1) / GameConfig.MAP_TREE_CLUSTER_COUNT) * math.pi * 2
		local position = Vector3.new(
			centerX + math.cos(alpha) * treeRadius,
			0,
			centerZ + math.sin(alpha) * (treeRadius * 0.92)
		)
		local canopyColor = Color3.fromRGB(94 + (treeIndex % 4) * 12, 150 + (treeIndex % 3) * 18, 116 + (treeIndex % 5) * 9)
		buildTreeCluster(forestFolder, "TreeCluster" .. treeIndex, position, canopyColor, if treeIndex % 3 == 0 then 1.18 else 1)
	end

	local boundaryForestFolder = ensureFolder(decorationsFolder, "BoundaryForest")
	buildBoundaryForestPatch(boundaryForestFolder, "NorthPatch", Vector3.new(centerX, 0, centerZ - halfDepth + 46), groundWidth - 180, 36, 10)
	buildBoundaryForestPatch(boundaryForestFolder, "SouthPatch", Vector3.new(centerX, 0, centerZ + halfDepth - 46), groundWidth - 180, 36, 10)
	buildBoundaryForestPatch(boundaryForestFolder, "WestPatch", Vector3.new(centerX - halfWidth + 46, 0, centerZ), 36, groundDepth - 180, 10)
	buildBoundaryForestPatch(boundaryForestFolder, "EastPatch", Vector3.new(centerX + halfWidth - 46, 0, centerZ), 36, groundDepth - 180, 10)

	local mountainFolder = ensureFolder(decorationsFolder, "MountainRing")
	local mountainRadius = GameConfig.MAP_MOUNTAIN_RING_RADIUS
	for mountainIndex = 1, GameConfig.MAP_MOUNTAIN_CLUSTER_COUNT do
		local alpha = ((mountainIndex - 1) / GameConfig.MAP_MOUNTAIN_CLUSTER_COUNT) * math.pi * 2
		local position = Vector3.new(
			centerX + math.cos(alpha) * mountainRadius,
			0,
			centerZ + math.sin(alpha) * (mountainRadius * 0.9)
		)
		buildMountainCluster(
			mountainFolder,
			"Mountain" .. mountainIndex,
			position,
			Color3.fromRGB(122, 102, 132),
			Color3.fromRGB(164, 132, 176),
			math.deg(alpha) + 90
		)
	end

	buildMountainCluster(mountainFolder, "NorthFoothill", Vector3.new(centerX, 0, centerZ - halfDepth + 78), Color3.fromRGB(96, 104, 110), Color3.fromRGB(138, 146, 152), 180)
	buildMountainCluster(mountainFolder, "SouthFoothill", Vector3.new(centerX, 0, centerZ + halfDepth - 78), Color3.fromRGB(96, 104, 110), Color3.fromRGB(138, 146, 152), 0)
	buildMountainCluster(mountainFolder, "WestFoothill", Vector3.new(centerX - halfWidth + 78, 0, centerZ), Color3.fromRGB(96, 104, 110), Color3.fromRGB(138, 146, 152), 90)
	buildMountainCluster(mountainFolder, "EastFoothill", Vector3.new(centerX + halfWidth - 78, 0, centerZ), Color3.fromRGB(96, 104, 110), Color3.fromRGB(138, 146, 152), -90)
end

function TycoonService.initialize()
	local legacyMap = workspace:FindFirstChild("CompetitiveTycoonMap")
	if legacyMap then
		legacyMap:Destroy()
	end

	ensurePinkSky()

	local definitions = getRuntimeTycoonDefinitions()
	if #definitions ~= GameConfig.ACTIVE_TYCOON_COUNT then
		warn(string.format(
			"Configured tycoon count mismatch. Expected %d active tycoons but found %d definitions.",
			GameConfig.ACTIVE_TYCOON_COUNT,
			#definitions
		))
	end
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
				warn(string.format("Failed to bind prebuilt tycoon %s. Rebuilding default scaffold. %s", definition.Id, tostring(result)))
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

function TycoonService.getLobbyFolder(): Folder?
	local lobby = workspace:FindFirstChild(GameConfig.WORKSPACE_FOLDERS.Lobby)
	if lobby and lobby:IsA("Folder") then
		return lobby
	end

	return nil
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
