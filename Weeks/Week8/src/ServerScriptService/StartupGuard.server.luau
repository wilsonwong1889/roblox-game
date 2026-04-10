local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local defaultFolderNames = {
	Lobby = "Lobby",
	SharedMap = "SharedMap",
	TycoonPlots = "TycoonPlots",
}
local recoveryAttempted = false

local function safeGetWorkspaceFolders()
	local modulesFolder = ReplicatedStorage:FindFirstChild("Modules")
	local configModule = modulesFolder and modulesFolder:FindFirstChild("GameConfig")
	if not configModule then
		return defaultFolderNames
	end

	local ok, config = pcall(require, configModule)
	if ok and type(config) == "table" and type(config.WORKSPACE_FOLDERS) == "table" then
		return config.WORKSPACE_FOLDERS
	end

	return defaultFolderNames
end

local function clearFolder(folder: Folder)
	for _, child in folder:GetChildren() do
		child:Destroy()
	end
end

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

local function createPart(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3): BasePart
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Color = color
	part.Parent = parent
	return part
end

local function addSurfaceLabel(part: BasePart, text: string)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 24
	gui.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.TextWrapped = true
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.fromRGB(255, 243, 194)
	label.Text = text
	label.Parent = gui
end

local function countTycoonModels(tycoonPlotsFolder: Folder): number
	local count = 0
	for _, child in tycoonPlotsFolder:GetChildren() do
		if child:IsA("Model") then
			count += 1
		end
	end
	return count
end

local function neutralSpawnLooksReady(): boolean
	local folderNames = safeGetWorkspaceFolders()
	local lobbyFolder = Workspace:FindFirstChild(folderNames.Lobby)

	if not lobbyFolder or not lobbyFolder:IsA("Folder") then
		return false
	end

	local spawnLocation = lobbyFolder:FindFirstChild("SpawnLocation")
	if not spawnLocation or not spawnLocation:IsA("SpawnLocation") then
		return false
	end

	return true
end

local function worldLooksReady(): boolean
	local folderNames = safeGetWorkspaceFolders()
	local sharedMapFolder = Workspace:FindFirstChild(folderNames.SharedMap)
	local tycoonPlotsFolder = Workspace:FindFirstChild(folderNames.TycoonPlots)

	if not neutralSpawnLooksReady() then
		return false
	end
	if not sharedMapFolder or not sharedMapFolder:IsA("Folder") then
		return false
	end
	if not tycoonPlotsFolder or not tycoonPlotsFolder:IsA("Folder") then
		return false
	end
	if countTycoonModels(tycoonPlotsFolder) <= 0 then
		return false
	end

	return true
end

local function ensureEmergencyBootstrap()
	local folderNames = safeGetWorkspaceFolders()
	local lobbyFolder = ensureFolder(Workspace, folderNames.Lobby)
	local sharedMapFolder = ensureFolder(Workspace, folderNames.SharedMap)

	local lobbyPlatform = lobbyFolder:FindFirstChild("SpawnPlatform")
	if not lobbyPlatform or not lobbyPlatform:IsA("BasePart") then
		lobbyPlatform = createPart(lobbyFolder, "SpawnPlatform", Vector3.new(96, 2, 96), CFrame.new(0, 4, 0), Color3.fromRGB(214, 208, 202))
		addSurfaceLabel(lobbyPlatform, "Fallback Courtyard")
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
	lobbySpawn.Size = Vector3.new(14, 1, 14)
	lobbySpawn.CFrame = CFrame.new(0, 6, 0)
	lobbySpawn.Anchored = true
	lobbySpawn.Enabled = true
	lobbySpawn.Neutral = true

	local sharedGround = sharedMapFolder:FindFirstChild("Ground")
	if not sharedGround or not sharedGround:IsA("BasePart") then
		sharedGround = createPart(sharedMapFolder, "Ground", Vector3.new(420, 2, 420), CFrame.new(0, -1, 0), Color3.fromRGB(108, 126, 118))
	end

	local folder = ensureFolder(Workspace, "EmergencyBootstrap")
	clearFolder(folder)

	local platform = createPart(folder, "EmergencyPlatform", Vector3.new(72, 2, 72), CFrame.new(0, 4, 0), Color3.fromRGB(82, 94, 120))
	addSurfaceLabel(platform, "Emergency Spawn")

	local spawnLocation = Instance.new("SpawnLocation")
	spawnLocation.Name = "EmergencySpawn"
	spawnLocation.Size = Vector3.new(12, 1, 12)
	spawnLocation.CFrame = CFrame.new(0, 6, 0)
	spawnLocation.Anchored = true
	spawnLocation.Enabled = true
	spawnLocation.Neutral = true
	spawnLocation.Parent = folder

	local sign = createPart(folder, "EmergencyStatus", Vector3.new(46, 14, 1), CFrame.new(0, 14, -30), Color3.fromRGB(30, 35, 48))
	local status = tostring(Workspace:GetAttribute("BootstrapStatus") or "unknown")
	local phase = tostring(Workspace:GetAttribute("BootstrapPhase") or "")
	local errorText = tostring(Workspace:GetAttribute("BootstrapError") or "")
	local displayText = "Emergency bootstrap active.\nMain map did not finish loading."
	if errorText ~= "" then
		displayText = string.format("Emergency bootstrap active.\nStatus: %s\nPhase: %s\n%s", status, phase, string.sub(errorText, 1, 120))
	elseif status ~= "" then
		displayText = string.format("Emergency bootstrap active.\nStatus: %s\nPhase: %s", status, phase)
	end
	addSurfaceLabel(sign, displayText)
end

local function clearEmergencyBootstrap()
	local folder = Workspace:FindFirstChild("EmergencyBootstrap")
	if folder then
		folder:Destroy()
	end
end

local function getLobbySpawnCFrame(): CFrame?
	local folderNames = safeGetWorkspaceFolders()
	local lobbyFolder = Workspace:FindFirstChild(folderNames.Lobby)
	if not lobbyFolder or not lobbyFolder:IsA("Folder") then
		return nil
	end

	local spawnLocation = lobbyFolder:FindFirstChild("SpawnLocation")
	if spawnLocation and spawnLocation:IsA("SpawnLocation") then
		return spawnLocation.CFrame + Vector3.new(0, 3, 0)
	end

	return nil
end

local function movePlayersToLobby()
	local targetCFrame = getLobbySpawnCFrame()
	if not targetCFrame then
		return
	end

	for _, player in Players:GetPlayers() do
		local character = player.Character
		if character then
			local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
			if root and root:IsA("BasePart") then
				character:PivotTo(targetCFrame)
			end
		end
	end
end

local function attemptRecoveryWorldBuild()
	if recoveryAttempted then
		return
	end
	recoveryAttempted = true

	local servicesFolder = script.Parent:FindFirstChild("Services")
	local tycoonServiceModule = servicesFolder and servicesFolder:FindFirstChild("TycoonService")
	if not tycoonServiceModule then
		Workspace:SetAttribute("BootstrapStatus", "recovery_missing_tycoon_service")
		return
	end

	local okRequire, tycoonService = pcall(require, tycoonServiceModule)
	if not okRequire then
		Workspace:SetAttribute("BootstrapStatus", "recovery_require_failed")
		Workspace:SetAttribute("BootstrapError", tostring(tycoonService))
		return
	end

	local okInit, initErr = pcall(function()
		tycoonService.initialize()
	end)
	if not okInit then
		Workspace:SetAttribute("BootstrapStatus", "recovery_init_failed")
		Workspace:SetAttribute("BootstrapError", tostring(initErr))
		return
	end

	local okValidate, valid, issues = pcall(function()
		return tycoonService.validateWorldState()
	end)
	if not okValidate then
		Workspace:SetAttribute("BootstrapStatus", "recovery_validate_failed")
		Workspace:SetAttribute("BootstrapError", tostring(valid))
		return
	end

	if not valid then
		Workspace:SetAttribute("BootstrapStatus", "recovery_world_invalid")
		Workspace:SetAttribute("BootstrapError", table.concat(issues, " | "))
		return
	end

	Workspace:SetAttribute("BootstrapStatus", "recovered")
	Workspace:SetAttribute("BootstrapError", "")
end

task.spawn(function()
	ensureEmergencyBootstrap()
	local readyChecks = 0
	local failedChecks = 0

	while true do
		task.wait(1)

		local hasSafeSpawn = neutralSpawnLooksReady()
		local fullWorldReady = worldLooksReady()

		if hasSafeSpawn then
			readyChecks += 1
			if readyChecks >= 2 then
				movePlayersToLobby()
				if fullWorldReady then
					clearEmergencyBootstrap()
					break
				end
			end
		else
			readyChecks = 0
			failedChecks += 1
			if failedChecks >= 3 then
				attemptRecoveryWorldBuild()
			end
			ensureEmergencyBootstrap()
		end
	end
end)
