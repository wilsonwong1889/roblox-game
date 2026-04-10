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

local function worldLooksReady(): boolean
	local lobbyFolder = Workspace:FindFirstChild(GameConfig.WORKSPACE_FOLDERS.Lobby)
	local sharedMapFolder = Workspace:FindFirstChild(GameConfig.WORKSPACE_FOLDERS.SharedMap)
	local tycoonPlotsFolder = Workspace:FindFirstChild(GameConfig.WORKSPACE_FOLDERS.TycoonPlots)
	if not lobbyFolder or not lobbyFolder:IsA("Folder") then
		return false
	end
	if not sharedMapFolder or not sharedMapFolder:IsA("Folder") then
		return false
	end
	if not tycoonPlotsFolder or not tycoonPlotsFolder:IsA("Folder") then
		return false
	end

	local spawnLocation = lobbyFolder:FindFirstChild("SpawnLocation")
	if not spawnLocation or not spawnLocation:IsA("SpawnLocation") then
		return false
	end

	if not sharedMapFolder:FindFirstChild("Ground") then
		return false
	end

	if not sharedMapFolder:FindFirstChild("CentralPlaza") then
		return false
	end

	local tycoonCount = 0
	for _, child in tycoonPlotsFolder:GetChildren() do
		if child:IsA("Model") then
			tycoonCount += 1
		end
	end

	return tycoonCount >= GameConfig.ACTIVE_TYCOON_COUNT
end

local function attemptWorldBootstrap(source: string)
	Workspace:SetAttribute("StartupGuardStatus", "recovering")
	Workspace:SetAttribute("StartupGuardSource", source)

	local servicesFolder = script.Parent:FindFirstChild("Services")
	local tycoonServiceModule = servicesFolder and servicesFolder:FindFirstChild("TycoonService")
	if not tycoonServiceModule then
		Workspace:SetAttribute("StartupGuardError", "TycoonService module missing")
		return false
	end

	local requireOk, TycoonService = pcall(require, tycoonServiceModule)
	if not requireOk then
		Workspace:SetAttribute("StartupGuardError", tostring(TycoonService))
		warn(string.format("[StartupGuard] Failed to require TycoonService: %s", tostring(TycoonService)))
		return false
	end

	local initOk, initErr = pcall(function()
		TycoonService.initialize()
	end)
	if not initOk then
		Workspace:SetAttribute("StartupGuardError", tostring(initErr))
		warn(string.format("[StartupGuard] Failed to recover world bootstrap: %s", tostring(initErr)))
		return false
	end

	Workspace:SetAttribute("StartupGuardError", "")
	return worldLooksReady()
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

Workspace:SetAttribute("StartupGuardStatus", "booting")
Workspace:SetAttribute("StartupGuardSource", "StartupGuard")
Workspace:SetAttribute("StartupGuardError", "")
ensureLobbyBootstrap()

task.spawn(function()
	for attempt = 1, 10 do
		if worldLooksReady() then
			Workspace:SetAttribute("StartupGuardStatus", "ready")
			return
		end

		attemptWorldBootstrap(string.format("attempt_%d", attempt))
		ensureLobbyBootstrap()
		if worldLooksReady() then
			Workspace:SetAttribute("StartupGuardStatus", "ready")
			return
		end

		task.wait(1)
	end

	Workspace:SetAttribute("StartupGuardStatus", "fallback_lobby_only")
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.spawn(function()
			for _ = 1, 10 do
				if worldLooksReady() then
					break
				end
				movePlayerToLobby(player)
				task.wait(0.35)
			end
		end)
	end)
end)

for _, player in Players:GetPlayers() do
	if player.Character then
		task.spawn(function()
			for _ = 1, 10 do
				if worldLooksReady() then
					break
				end
				movePlayerToLobby(player)
				task.wait(0.35)
			end
		end)
	end
end
