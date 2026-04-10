local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)
local PlayerProfile = require(ReplicatedStorage.Modules.PlayerProfile)
local TycoonService = require(script.Parent.TycoonService)

local WeaponService = {}
WeaponService.KillAwarded = Instance.new("BindableEvent")

type WeaponConfig = {
	toolName: string,
	kind: "knife" | "blaster" | "rpg",
	handleSize: Vector3,
	handleColor: Color3,
	accentColor: Color3,
	damage: number,
	range: number,
	cooldown: number,
	radius: number?,
	projectileSpeed: number?,
}

local WEAPONS: { [string]: WeaponConfig } = {
	combat_knife = {
		toolName = "Combat Knife",
		kind = "knife",
		handleSize = Vector3.new(0.45, 1.5, 0.45),
		handleColor = Color3.fromRGB(48, 52, 58),
		accentColor = Color3.fromRGB(210, 220, 235),
		damage = 20,
		range = 6,
		cooldown = 0.7,
	},
	starter_pistol = {
		toolName = "Pistol",
		kind = "blaster",
		handleSize = Vector3.new(0.55, 1.55, 0.55),
		handleColor = Color3.fromRGB(165, 176, 192),
		accentColor = Color3.fromRGB(104, 196, 255),
		damage = 10,
		range = 150,
		cooldown = 0.3,
	},
	money_blaster = {
		toolName = "Money Blaster",
		kind = "blaster",
		handleSize = Vector3.new(0.55, 1.55, 0.55),
		handleColor = Color3.fromRGB(82, 255, 171),
		accentColor = Color3.fromRGB(37, 64, 52),
		damage = 10,
		range = 180,
		cooldown = 0.24,
	},
	money_rpg = {
		toolName = "Money RPG",
		kind = "rpg",
		handleSize = Vector3.new(0.6, 1.7, 0.6),
		handleColor = Color3.fromRGB(255, 164, 96),
		accentColor = Color3.fromRGB(70, 44, 28),
		damage = 60,
		range = 240,
		cooldown = 1.8,
		radius = 18,
		projectileSpeed = 120,
	},
}

local STARTER_WEAPON_IDS = { "combat_knife", "starter_pistol" }

local activationDebounces: { [number]: { [string]: number } } = {}
local humanoidDamageLedger = setmetatable({}, { __mode = "k" })

local function getWeaponConfig(upgradeId: string): WeaponConfig?
	return WEAPONS[upgradeId]
end

local function ensureBackpack(player: Player): Backpack?
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack then
		return backpack
	end

	local success, result = pcall(function()
		return player:WaitForChild("Backpack", 10)
	end)

	if success and result and result:IsA("Backpack") then
		return result
	end

	return nil
end

local function getCharacterRoot(player: Player): BasePart?
	local character = player.Character
	if not character then
		return nil
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root
	end

	return nil
end

local function getCharacterHumanoid(player: Player): Humanoid?
	local character = player.Character
	if not character then
		return nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		return humanoid
	end

	return nil
end

local function isOnCooldown(player: Player, upgradeId: string, cooldown: number): boolean
	local userDebounces = activationDebounces[player.UserId]
	if not userDebounces then
		userDebounces = {}
		activationDebounces[player.UserId] = userDebounces
	end

	local now = os.clock()
	local nextAllowed = userDebounces[upgradeId] or 0
	if now < nextAllowed then
		return true
	end

	userDebounces[upgradeId] = now + cooldown
	return false
end

local function getRaycastParams(player: Player): RaycastParams
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { player.Character }
	params.IgnoreWater = true
	return params
end

local function gatherHumanoidsInBox(player: Player, center: CFrame, size: Vector3): { Humanoid }
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { player.Character }

	local foundHumanoids: { [Humanoid]: boolean } = {}
	for _, part in Workspace:GetPartBoundsInBox(center, size, params) do
		local model = part:FindFirstAncestorOfClass("Model")
		local humanoid = model and model:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			foundHumanoids[humanoid] = true
		end
	end

	local humanoids = {}
	for humanoid in foundHumanoids do
		table.insert(humanoids, humanoid)
	end
	return humanoids
end

local function dealDamageToHumanoids(humanoids: { Humanoid }, damage: number)
	for _, humanoid in humanoids do
		humanoid:TakeDamage(damage)
	end
end

local function getDamageState(humanoid: Humanoid)
	local state = humanoidDamageLedger[humanoid]
	if state then
		return state
	end

	state = {
		attacker = nil,
		lastHitAt = 0,
		diedConnection = nil,
		ancestryConnection = nil,
	}

	state.diedConnection = humanoid.Died:Connect(function()
		local attacker = state.attacker
		if attacker and (os.clock() - state.lastHitAt) <= 8 then
			PlayerProfile.addKill(attacker, 1)
			WeaponService.KillAwarded:Fire(attacker, humanoid.Parent)
		end

		if state.diedConnection then
			state.diedConnection:Disconnect()
		end
		if state.ancestryConnection then
			state.ancestryConnection:Disconnect()
		end
		humanoidDamageLedger[humanoid] = nil
	end)

	state.ancestryConnection = humanoid.AncestryChanged:Connect(function(_, parent)
		if parent ~= nil then
			return
		end

		if state.diedConnection then
			state.diedConnection:Disconnect()
		end
		if state.ancestryConnection then
			state.ancestryConnection:Disconnect()
		end
		humanoidDamageLedger[humanoid] = nil
	end)

	humanoidDamageLedger[humanoid] = state
	return state
end

local function applyTrackedDamage(player: Player, humanoid: Humanoid, damage: number)
	if humanoid.Health <= 0 then
		return
	end

	local state = getDamageState(humanoid)
	state.attacker = player
	state.lastHitAt = os.clock()
	humanoid:TakeDamage(damage)
end

local function damageWallPart(part: BasePart?, damage: number)
	if not part or damage <= 0 then
		return
	end

	TycoonService.damageWallPart(part, damage)
end

local function damageWallsInBox(player: Player, center: CFrame, size: Vector3, damage: number)
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { player.Character }

	local damagedParts: { [BasePart]: boolean } = {}
	for _, part in Workspace:GetPartBoundsInBox(center, size, params) do
		if not damagedParts[part] then
			damageWallPart(part, damage)
			damagedParts[part] = true
		end
	end
end

local function damageWallsInRadius(player: Player, position: Vector3, radius: number, damage: number)
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { player.Character }

	local damagedParts: { [BasePart]: boolean } = {}
	for _, part in Workspace:GetPartBoundsInRadius(position, radius, params) do
		if not damagedParts[part] then
			damageWallPart(part, damage)
			damagedParts[part] = true
		end
	end
end

local function spawnTracer(origin: Vector3, target: Vector3, color: Color3)
	local distance = (target - origin).Magnitude
	if distance <= 0.05 then
		return
	end

	local tracer = Instance.new("Part")
	tracer.Name = "WeaponTracer"
	tracer.Anchored = true
	tracer.CanCollide = false
	tracer.CanTouch = false
	tracer.CanQuery = false
	tracer.Material = Enum.Material.Neon
	tracer.Color = color
	tracer.Size = Vector3.new(0.24, 0.24, distance)
	tracer.CFrame = CFrame.lookAt(origin, target) * CFrame.new(0, 0, -(distance / 2))
	tracer.Parent = Workspace
	Debris:AddItem(tracer, 0.12)
end

local function createWeldedWeaponPart(tool: Tool, handle: BasePart, name: string, size: Vector3, offset: CFrame, color: Color3, material: Enum.Material, transparency: number?)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = material
	part.Transparency = transparency or 0
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Anchored = false
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
	part.CFrame = handle.CFrame * offset
	part.Parent = tool

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = handle
	weld.Part1 = part
	weld.Parent = handle

	return part
end

local function playKnife(player: Player, config: WeaponConfig)
	local root = getCharacterRoot(player)
	local humanoid = getCharacterHumanoid(player)
	if not root or not humanoid or humanoid.Health <= 0 then
		return
	end

	local swingCenter = root.CFrame * CFrame.new(0, 0, -(config.range * 0.6))
	local hitHumanoids = gatherHumanoidsInBox(player, swingCenter, Vector3.new(6, 6, config.range))
	for _, targetHumanoid in hitHumanoids do
		applyTrackedDamage(player, targetHumanoid, config.damage)
	end
	damageWallsInBox(player, swingCenter, Vector3.new(6, 6, config.range), config.damage)

	local slash = Instance.new("Part")
	slash.Name = "KnifeSlash"
	slash.Anchored = true
	slash.CanCollide = false
	slash.CanTouch = false
	slash.CanQuery = false
	slash.Material = Enum.Material.Neon
	slash.Color = config.accentColor
	slash.Transparency = 0.18
	slash.Size = Vector3.new(0.6, 5.5, config.range)
	slash.CFrame = swingCenter
	slash.Parent = Workspace
	Debris:AddItem(slash, 0.08)
end

local function playMoneyBlaster(player: Player, config: WeaponConfig)
	local root = getCharacterRoot(player)
	local humanoid = getCharacterHumanoid(player)
	if not root or not humanoid or humanoid.Health <= 0 then
		return
	end

	local origin = root.Position + Vector3.new(0, 2.2, 0) + (root.CFrame.LookVector * 3.2)
	local direction = root.CFrame.LookVector * config.range
	local result = Workspace:Raycast(origin, direction, getRaycastParams(player))
	local hitPosition = if result then result.Position else (origin + direction)

	spawnTracer(origin, hitPosition, config.handleColor)

	if result then
		local model = result.Instance:FindFirstAncestorOfClass("Model")
		local hitHumanoid = model and model:FindFirstChildOfClass("Humanoid")
		if hitHumanoid and hitHumanoid.Health > 0 then
			applyTrackedDamage(player, hitHumanoid, config.damage)
		end
		damageWallPart(result.Instance, config.damage)
	end
end

local function explodeRocket(player: Player, position: Vector3, config: WeaponConfig)
	local radius = config.radius or 16
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { player.Character }

	local damagedHumanoids: { [Humanoid]: boolean } = {}
	for _, part in Workspace:GetPartBoundsInRadius(position, radius, params) do
		local model = part:FindFirstAncestorOfClass("Model")
		local humanoid = model and model:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			damagedHumanoids[humanoid] = true
		end
	end

	for humanoid in damagedHumanoids do
		applyTrackedDamage(player, humanoid, config.damage)
	end
	damageWallsInRadius(player, position, radius, config.damage)

	local blast = Instance.new("Part")
	blast.Name = "RpgBlast"
	blast.Shape = Enum.PartType.Ball
	blast.Anchored = true
	blast.CanCollide = false
	blast.CanTouch = false
	blast.CanQuery = false
	blast.Material = Enum.Material.Neon
	blast.Color = Color3.fromRGB(255, 174, 117)
	blast.Transparency = 0.1
	blast.Size = Vector3.new(radius * 0.9, radius * 0.9, radius * 0.9)
	blast.CFrame = CFrame.new(position)
	blast.Parent = Workspace
	Debris:AddItem(blast, 0.18)
end

local function playMoneyRpg(player: Player, config: WeaponConfig)
	local root = getCharacterRoot(player)
	local humanoid = getCharacterHumanoid(player)
	if not root or not humanoid or humanoid.Health <= 0 then
		return
	end

	local origin = root.Position + Vector3.new(0, 2.2, 0) + (root.CFrame.LookVector * 4)
	local direction = root.CFrame.LookVector.Unit
	local speed = config.projectileSpeed or 110
	local maxDuration = math.max(1, config.range / speed)

	local rocket = Instance.new("Part")
	rocket.Name = "MoneyRocket"
	rocket.Anchored = true
	rocket.CanCollide = false
	rocket.CanTouch = false
	rocket.CanQuery = false
	rocket.Material = Enum.Material.Neon
	rocket.Color = config.handleColor
	rocket.Size = Vector3.new(1.2, 1.2, 3.4)
	rocket.CFrame = CFrame.lookAt(origin, origin + direction)
	rocket.Parent = Workspace

	local position = origin
	local startedAt = os.clock()
	while rocket.Parent and (os.clock() - startedAt) <= maxDuration do
		local stepDistance = speed * 0.05
		local nextPosition = position + (direction * stepDistance)
		local result = Workspace:Raycast(position, direction * stepDistance, getRaycastParams(player))
		if result then
			explodeRocket(player, result.Position, config)
			rocket:Destroy()
			return
		end

		position = nextPosition
		rocket.CFrame = CFrame.lookAt(position, position + direction)
		task.wait(0.05)
	end

	if rocket.Parent then
		explodeRocket(player, position, config)
		rocket:Destroy()
	end
end

local function activateWeapon(player: Player, upgradeId: string)
	local config = getWeaponConfig(upgradeId)
	if not config then
		return
	end

	if isOnCooldown(player, upgradeId, config.cooldown) then
		return
	end

	if config.kind == "knife" then
		playKnife(player, config)
	elseif config.kind == "blaster" then
		playMoneyBlaster(player, config)
	elseif config.kind == "rpg" then
		playMoneyRpg(player, config)
	end
end

local function attachWeaponBehavior(tool: Tool, player: Player, upgradeId: string)
	tool.Activated:Connect(function()
		activateWeapon(player, upgradeId)
	end)
end

local function createWeaponTool(player: Player, upgradeId: string): Tool?
	local config = getWeaponConfig(upgradeId)
	if not config then
		return nil
	end

	local tool = Instance.new("Tool")
	tool.Name = config.toolName
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	tool:SetAttribute("TycoonWeapon", true)
	tool:SetAttribute("WeaponUpgradeId", upgradeId)

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = config.handleSize
	handle.Color = config.handleColor
	handle.Material = Enum.Material.Metal
	handle.Massless = true
	handle.CanCollide = false
	handle.CanTouch = false
	handle.CanQuery = false
	handle.TopSurface = Enum.SurfaceType.Smooth
	handle.BottomSurface = Enum.SurfaceType.Smooth
	handle.Parent = tool

	if config.kind == "knife" then
		tool.Grip = CFrame.new(0, -0.75, 0.1)
		createWeldedWeaponPart(tool, handle, "Guard", Vector3.new(1.1, 0.15, 0.3), CFrame.new(0, 0.55, 0), config.handleColor, Enum.Material.Metal)
		createWeldedWeaponPart(tool, handle, "Blade", Vector3.new(0.2, 2.4, 0.5), CFrame.new(0, 1.95, 0), Color3.fromRGB(220, 228, 240), Enum.Material.Metal)
		createWeldedWeaponPart(tool, handle, "BladeEdge", Vector3.new(0.08, 2.3, 0.55), CFrame.new(0, 1.95, -0.02), config.accentColor, Enum.Material.Neon, 0.1)
	elseif config.kind == "blaster" then
		tool.Grip = CFrame.new(0, -0.28, -1.05)
		createWeldedWeaponPart(tool, handle, "Body", Vector3.new(1.1, 1.0, 3.4), CFrame.new(0, 0.55, -1.7), Color3.fromRGB(55, 63, 77), Enum.Material.Metal)
		createWeldedWeaponPart(tool, handle, "Barrel", Vector3.new(0.42, 0.42, 2.2), CFrame.new(0, 0.58, -4.45), config.handleColor, Enum.Material.Neon, 0.05)
		createWeldedWeaponPart(tool, handle, "Stock", Vector3.new(0.85, 0.85, 1.1), CFrame.new(0, 0.52, -0.45), Color3.fromRGB(37, 44, 54), Enum.Material.Metal)
		createWeldedWeaponPart(tool, handle, "TopRail", Vector3.new(0.34, 0.26, 1.4), CFrame.new(0, 1.1, -2.0), config.accentColor, Enum.Material.Neon, 0.08)
	elseif config.kind == "rpg" then
		tool.Grip = CFrame.new(0, -0.2, -1.2)
		createWeldedWeaponPart(tool, handle, "Tube", Vector3.new(1.15, 1.15, 5.6), CFrame.new(0, 0.45, -2.45), Color3.fromRGB(74, 54, 42), Enum.Material.Metal)
		createWeldedWeaponPart(tool, handle, "RearRing", Vector3.new(1.5, 1.5, 0.8), CFrame.new(0, 0.45, 0.15), Color3.fromRGB(50, 38, 30), Enum.Material.Metal)
		createWeldedWeaponPart(tool, handle, "Nose", Vector3.new(0.8, 0.8, 1.0), CFrame.new(0, 0.45, -5.35), config.handleColor, Enum.Material.Neon, 0.04)
		createWeldedWeaponPart(tool, handle, "Sight", Vector3.new(0.22, 0.6, 0.22), CFrame.new(0, 1.1, -1.1), config.accentColor, Enum.Material.Neon, 0.08)
	else
		createWeldedWeaponPart(tool, handle, "Accent", Vector3.new(0.4, 0.25, 0.7), CFrame.new(0, 0.15, -0.2), config.accentColor, Enum.Material.Neon, 0.08)
	end

	attachWeaponBehavior(tool, player, upgradeId)
	return tool
end

function WeaponService.isWeaponUpgrade(upgradeId: string): boolean
	return getWeaponConfig(upgradeId) ~= nil
end

function WeaponService.getWeaponUpgradeIds(): { string }
	return GameConfig.getWeaponUpgradeIds()
end

function WeaponService.grantUpgradeTool(player: Player, upgradeId: string)
	local backpack = ensureBackpack(player)
	local config = getWeaponConfig(upgradeId)
	if not backpack or not config then
		return
	end

	if backpack:FindFirstChild(config.toolName) then
		return
	end

	local tool = createWeaponTool(player, upgradeId)
	if tool then
		tool.Parent = backpack
	end
end

function WeaponService.grantStarterWeapons(player: Player)
	for _, weaponId in STARTER_WEAPON_IDS do
		WeaponService.grantUpgradeTool(player, weaponId)
	end
end

function WeaponService.grantOwnedWeapons(player: Player, purchasedUpgrades: { [string]: boolean }?)
	if not purchasedUpgrades then
		return
	end

	for _, upgradeId in WeaponService.getWeaponUpgradeIds() do
		if purchasedUpgrades[upgradeId] then
			WeaponService.grantUpgradeTool(player, upgradeId)
		end
	end
end

function WeaponService.clearPlayerState(player: Player)
	activationDebounces[player.UserId] = nil
end

return WeaponService
