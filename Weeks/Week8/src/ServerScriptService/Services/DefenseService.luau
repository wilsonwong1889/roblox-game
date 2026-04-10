local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)
local PlayerProfile = require(ReplicatedStorage.Modules.PlayerProfile)
local EventService = require(script.Parent.EventService)
local TycoonService = require(script.Parent.TycoonService)
local WeaponService = require(script.Parent.WeaponService)

local DefenseService = {}

local initialized = false
local turretCooldowns: { [string]: number } = {}

local function createTracer(origin: Vector3, target: Vector3, color: Color3)
	local distance = (target - origin).Magnitude
	if distance <= 0.05 then
		return
	end

	local tracer = Instance.new("Part")
	tracer.Name = "TurretTracer"
	tracer.Anchored = true
	tracer.CanCollide = false
	tracer.CanTouch = false
	tracer.CanQuery = false
	tracer.Material = Enum.Material.Neon
	tracer.Color = color
	tracer.Size = Vector3.new(0.22, 0.22, distance)
	tracer.CFrame = CFrame.lookAt(origin, target) * CFrame.new(0, 0, -(distance / 2))
	tracer.Parent = Workspace
	task.delay(0.08, function()
		if tracer.Parent then
			tracer:Destroy()
		end
	end)
end

local function createMuzzleFlash(position: Vector3)
	local flash = Instance.new("Part")
	flash.Name = "TurretMuzzleFlash"
	flash.Shape = Enum.PartType.Ball
	flash.Size = Vector3.new(1.2, 1.2, 1.2)
	flash.Anchored = true
	flash.CanCollide = false
	flash.CanTouch = false
	flash.CanQuery = false
	flash.Material = Enum.Material.Neon
	flash.Color = Color3.fromRGB(255, 228, 140)
	flash.CFrame = CFrame.new(position)
	flash.Parent = Workspace
	task.delay(0.08, function()
		if flash.Parent then
			flash:Destroy()
		end
	end)
end

function DefenseService.getTurretStats(hasGuardTower: boolean): { range: number, damage: number, cooldown: number }
	return GameConfig.getDefenseTurretStats(hasGuardTower)
end

local function getTurretParts(tycoon)
	local folder = tycoon.StructuresFolder:FindFirstChild("DefenseTurret")
	if not folder or not folder:IsA("Folder") then
		return nil
	end

	local head = folder:FindFirstChild("TurretHead")
	local barrel = folder:FindFirstChild("TurretBarrel")
	local muzzle = folder:FindFirstChild("TurretMuzzle")
	if not head or not barrel or not muzzle then
		return nil
	end
	if not head:IsA("BasePart") or not barrel:IsA("BasePart") or not muzzle:IsA("BasePart") then
		return nil
	end

	return {
		folder = folder,
		head = head,
		barrel = barrel,
		muzzle = muzzle,
	}
end

local function getAlarmBeaconParts(tycoon)
	local folder = tycoon.StructuresFolder:FindFirstChild("AlarmBeacon")
	if not folder or not folder:IsA("Folder") then
		return nil
	end

	local ring = folder:FindFirstChild("BeaconRing")
	local core = folder:FindFirstChild("BeaconCore")
	if not ring or not core then
		return nil
	end
	if not ring:IsA("BasePart") or not core:IsA("BasePart") then
		return nil
	end

	return {
		ring = ring,
		core = core,
	}
end

local function isPositionInDefenseZone(tycoon, worldPosition: Vector3): boolean
	local localPosition = tycoon.BaseCFrame:PointToObjectSpace(worldPosition)
	return math.abs(localPosition.X) <= ((GameConfig.TYCOON_SIZE.X / 2) + 26)
		and math.abs(localPosition.Z) <= ((GameConfig.TYCOON_SIZE.Z / 2) + 26)
end

local function gatherNpcTargets(): { { humanoid: Humanoid, root: BasePart, model: Model, priority: number } }
	local candidates = {}
	local sharedMapFolder = TycoonService.getSharedMapFolder()
	if not sharedMapFolder then
		return candidates
	end

	for _, descendant in sharedMapFolder:GetDescendants() do
		if descendant:IsA("Model") then
			local npcRole = descendant:GetAttribute("NpcRole")
			if npcRole == "Zombie" or npcRole == "Soldier" then
				local humanoid = descendant:FindFirstChildOfClass("Humanoid")
				local root = descendant.PrimaryPart or descendant:FindFirstChild("HumanoidRootPart") or descendant:FindFirstChild("Torso")
				if humanoid and humanoid.Health > 0 and root and root:IsA("BasePart") then
					table.insert(candidates, {
						humanoid = humanoid,
						root = root,
						model = descendant,
						priority = if npcRole == "Zombie" then 1 else 3,
					})
				end
			end
		end
	end

	return candidates
end

local function getBestTarget(owner: Player, tycoon, origin: Vector3, range: number, npcTargets): { humanoid: Humanoid, root: BasePart, model: Model, priority: number }?
	local bestTarget = nil
	local bestPriority = math.huge
	local bestDistance = range

	for _, candidate in npcTargets do
		local distance = (candidate.root.Position - origin).Magnitude
		if distance <= bestDistance and (candidate.priority < bestPriority or (candidate.priority == bestPriority and distance < bestDistance)) then
			bestTarget = candidate
			bestPriority = candidate.priority
			bestDistance = distance
		end
	end

	for _, player in Players:GetPlayers() do
		if player ~= owner then
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local root = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
			if humanoid and humanoid.Health > 0 and root and root:IsA("BasePart") and isPositionInDefenseZone(tycoon, root.Position) then
				local distance = (root.Position - origin).Magnitude
				if distance <= bestDistance and (2 < bestPriority or (2 == bestPriority and distance < bestDistance)) then
					bestTarget = {
						humanoid = humanoid,
						root = root,
						model = character,
						priority = 2,
					}
					bestPriority = 2
					bestDistance = distance
				end
			end
		end
	end

	return bestTarget
end

local function hasLineOfSight(origin: Vector3, targetPosition: Vector3, ignoredInstances: { Instance }, targetModel: Model): boolean
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = ignoredInstances
	params.IgnoreWater = true

	local result = Workspace:Raycast(origin, targetPosition - origin, params)
	if not result then
		return true
	end

	return result.Instance:IsDescendantOf(targetModel)
end

local function aimTurret(parts, targetPosition: Vector3)
	local headPosition = parts.head.Position
	local barrelPosition = parts.barrel.Position
	local muzzlePosition = parts.muzzle.Position

	parts.head.CFrame = CFrame.lookAt(headPosition, targetPosition)
	parts.barrel.CFrame = CFrame.lookAt(barrelPosition, targetPosition)
	parts.muzzle.CFrame = CFrame.lookAt(muzzlePosition, targetPosition)
end

local function updateAlarmBeacon(tycoon, accent: Color3, alertActive: boolean)
	local beaconParts = getAlarmBeaconParts(tycoon)
	if not beaconParts then
		return
	end

	local pulse = (math.sin(os.clock() * (if alertActive then 8 else 2.5)) + 1) * 0.5
	if alertActive then
		beaconParts.core.Color = Color3.fromRGB(255, 102, 102):Lerp(Color3.fromRGB(255, 214, 148), pulse * 0.45)
		beaconParts.core.Transparency = 0.02 + ((1 - pulse) * 0.18)
		beaconParts.ring.Color = Color3.fromRGB(255, 178, 112):Lerp(Color3.fromRGB(255, 88, 88), pulse * 0.7)
		beaconParts.ring.Transparency = 0.04 + ((1 - pulse) * 0.22)
	else
		beaconParts.core.Color = accent:Lerp(Color3.fromRGB(255, 213, 156), 0.35 + (pulse * 0.18))
		beaconParts.core.Transparency = 0.28 + ((1 - pulse) * 0.18)
		beaconParts.ring.Color = accent:Lerp(Color3.fromRGB(255, 216, 126), 0.55)
		beaconParts.ring.Transparency = 0.18 + ((1 - pulse) * 0.14)
	end
end

local function processTurret(tycoonId: string, tycoon, npcTargets, liveEventState)
	local owner = tycoon.Owner
	if not owner then
		return
	end

	local profile = PlayerProfile.getProfile(owner)
	if not profile then
		return
	end

	local purchased = profile.PurchasedUpgrades
	local zombieThreat = liveEventState and liveEventState.mode == "zombie"
	updateAlarmBeacon(tycoon, tycoon.Accent, zombieThreat)

	if not purchased.defense_turret then
		return
	end

	local parts = getTurretParts(tycoon)
	if not parts then
		return
	end

	local stats = DefenseService.getTurretStats(purchased.guard_tower == true)
	local target = getBestTarget(owner, tycoon, parts.muzzle.Position, stats.range, npcTargets)
	updateAlarmBeacon(tycoon, tycoon.Accent, zombieThreat or target ~= nil)
	if not target then
		return
	end

	local aimPosition = target.root.Position + Vector3.new(0, 1.4, 0)
	aimTurret(parts, aimPosition)

	local now = os.clock()
	local nextAllowed = turretCooldowns[tycoonId] or 0
	if now < nextAllowed then
		return
	end

	if not hasLineOfSight(parts.muzzle.Position, aimPosition, { parts.folder, owner.Character }, target.model) then
		return
	end

	turretCooldowns[tycoonId] = now + stats.cooldown
	createMuzzleFlash(parts.muzzle.Position)
	createTracer(parts.muzzle.Position, aimPosition, if purchased.guard_tower then Color3.fromRGB(255, 204, 122) else Color3.fromRGB(118, 214, 255))
	WeaponService.applyOwnedDamage(owner, target.humanoid, stats.damage)
end

function DefenseService.initialize()
	if initialized or not GameConfig.DEFENSE_ENABLED then
		return
	end

	initialized = true
	task.spawn(function()
		while true do
			task.wait(0.18)
			local npcTargets = gatherNpcTargets()
			local liveEventState = EventService.getPublicState()
			for tycoonId, tycoon in TycoonService.getTycoons() do
				processTurret(tycoonId, tycoon, npcTargets, liveEventState)
			end
		end
	end)
end

return DefenseService
