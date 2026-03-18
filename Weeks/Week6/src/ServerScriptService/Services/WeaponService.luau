local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

local WeaponService = {}

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
		handleSize = Vector3.new(1, 3.2, 0.6),
		handleColor = Color3.fromRGB(48, 52, 58),
		accentColor = Color3.fromRGB(210, 220, 235),
		damage = 35,
		range = 6,
		cooldown = 0.7,
	},
	money_blaster = {
		toolName = "Money Blaster",
		kind = "blaster",
		handleSize = Vector3.new(1.2, 2.2, 4.6),
		handleColor = Color3.fromRGB(82, 255, 171),
		accentColor = Color3.fromRGB(37, 64, 52),
		damage = 22,
		range = 180,
		cooldown = 0.24,
	},
	money_rpg = {
		toolName = "Money RPG",
		kind = "rpg",
		handleSize = Vector3.new(1.4, 1.4, 6.4),
		handleColor = Color3.fromRGB(255, 164, 96),
		accentColor = Color3.fromRGB(70, 44, 28),
		damage = 95,
		range = 240,
		cooldown = 1.8,
		radius = 18,
		projectileSpeed = 120,
	},
}

local activationDebounces: { [number]: { [string]: number } } = {}

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

local function playKnife(player: Player, config: WeaponConfig)
	local root = getCharacterRoot(player)
	local humanoid = getCharacterHumanoid(player)
	if not root or not humanoid or humanoid.Health <= 0 then
		return
	end

	local swingCenter = root.CFrame * CFrame.new(0, 0, -(config.range * 0.6))
	local hitHumanoids = gatherHumanoidsInBox(player, swingCenter, Vector3.new(6, 6, config.range))
	dealDamageToHumanoids(hitHumanoids, config.damage)

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
			hitHumanoid:TakeDamage(config.damage)
		end
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
		humanoid:TakeDamage(config.damage)
	end

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
	handle.TopSurface = Enum.SurfaceType.Smooth
	handle.BottomSurface = Enum.SurfaceType.Smooth
	handle.Parent = tool

	local accent = Instance.new("Part")
	accent.Name = "Accent"
	accent.Size = Vector3.new(math.max(0.5, config.handleSize.X * 0.7), math.max(0.4, config.handleSize.Y * 0.18), math.max(0.6, config.handleSize.Z * 0.5))
	accent.Color = config.accentColor
	accent.Material = Enum.Material.Neon
	accent.Anchored = false
	accent.CanCollide = false
	accent.CanTouch = false
	accent.CanQuery = false
	accent.Massless = true
	accent.Parent = tool

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = handle
	weld.Part1 = accent
	weld.Parent = handle

	accent.CFrame = handle.CFrame * CFrame.new(0, 0, -(config.handleSize.Z * 0.15))

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
