local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

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

local function ensurePart(parent: Instance, name: string, size: Vector3, cframe: CFrame, properties: { [string]: any }?): BasePart
	local existing = parent:FindFirstChild(name)
	if existing and existing:IsA("BasePart") then
		existing.Size = size
		existing.CFrame = cframe
		existing.Anchored = true
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

local function ensureSurfaceLabel(parent: BasePart, text: string)
	local gui = parent:FindFirstChildWhichIsA("SurfaceGui")
	if not gui then
		gui = Instance.new("SurfaceGui")
		gui.Face = Enum.NormalId.Top
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 28
		gui.Parent = parent
	end

	local label = gui:FindFirstChildWhichIsA("TextLabel")
	if not label then
		label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Size = UDim2.fromScale(1, 1)
		label.Font = Enum.Font.GothamBold
		label.TextScaled = true
		label.Parent = gui
	end

	label.Text = text
	label.TextColor3 = Color3.fromRGB(22, 28, 38)
end

local function ensureLobbyBootstrap()
	local lobbyFolder = ensureFolder(Workspace, GameConfig.WORKSPACE_FOLDERS.Lobby)
	local centerX = 0
	local centerZ = 0
	local padSize = Vector3.new(
		math.max(84, GameConfig.MAP_CENTRAL_PLAZA_SIZE.X * 0.6),
		1,
		math.max(84, GameConfig.MAP_CENTRAL_PLAZA_SIZE.Z * 0.6)
	)

	local spawnPlatform = ensurePart(lobbyFolder, "SpawnPlatform", padSize, CFrame.new(centerX, 2, centerZ), {
		Color = Color3.fromRGB(238, 240, 246),
		Material = Enum.Material.Concrete,
	})
	ensureSurfaceLabel(spawnPlatform, "Main Lobby")

	local spawnLocation = lobbyFolder:FindFirstChild("SpawnLocation")
	if spawnLocation and not spawnLocation:IsA("SpawnLocation") then
		spawnLocation:Destroy()
		spawnLocation = nil
	end

	if not spawnLocation then
		spawnLocation = Instance.new("SpawnLocation")
		spawnLocation.Name = "SpawnLocation"
		spawnLocation.Parent = lobbyFolder
	end

	spawnLocation.Size = Vector3.new(16, 1, 16)
	spawnLocation.CFrame = CFrame.new(centerX, 3.25, centerZ)
	spawnLocation.Neutral = true
	spawnLocation.Anchored = true
	spawnLocation.Enabled = true

	return spawnLocation
end

local function movePlayerToLobby(player: Player)
	local character = player.Character
	if not character then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 10)
	if not root or not root:IsA("BasePart") then
		return
	end

	local lobbyFolder = Workspace:FindFirstChild(GameConfig.WORKSPACE_FOLDERS.Lobby)
	local spawnLocation = lobbyFolder and lobbyFolder:FindFirstChild("SpawnLocation")
	if not spawnLocation or not spawnLocation:IsA("SpawnLocation") then
		return
	end

	root.CFrame = spawnLocation.CFrame + Vector3.new(0, 4, 0)
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end

ensureLobbyBootstrap()

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.defer(function()
			movePlayerToLobby(player)
		end)
	end)
end)

for _, player in Players:GetPlayers() do
	if player.Character then
		task.defer(function()
			movePlayerToLobby(player)
		end)
	end
end
