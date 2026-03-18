local SecondFloorConfig = require(script.Parent.SecondFloorConfig)
local ThirdFloorConfig = require(script.Parent.ThirdFloorConfig)

local GameConfig = {}

GameConfig.GAME_NAME = "Break-In Tycoon"
GameConfig.GAME_STAGE = "Week 6 Armed Factory Expansion"
GameConfig.WEEK_PHASE = "Week 6 Armed Factory Expansion"
GameConfig.ACTIVE_TYCOON_COUNT = 8
GameConfig.SECOND_FLOOR_ENABLED = SecondFloorConfig.ENABLED
GameConfig.THIRD_FLOOR_ENABLED = ThirdFloorConfig.ENABLED

GameConfig.STARTING_CASH = 25
GameConfig.STARTING_STASH_CASH = 0
GameConfig.STARTING_VAULT_CASH = 0
GameConfig.PERSONAL_STARTING_CASH = {
	iiTheDarkMagic = 100000,
}
GameConfig.VIP_STARTER_PACK = {
	ENABLED = true,
	NAME = "VIP Money Starter Pack",
	GAMEPASS_ID = 1754764623,
	PRICE_ROBUX = 500,
	CASH_BONUS = 500000,
}
GameConfig.BACKGROUND_MUSIC_ENABLED = true
GameConfig.BACKGROUND_MUSIC_NAME = "BackgroundMusic"
GameConfig.BACKGROUND_MUSIC_SOUND_ID = "rbxassetid://1841461968"
GameConfig.BACKGROUND_MUSIC_VOLUME = 0.2
GameConfig.BASE_WALK_SPEED = 16
GameConfig.SPRINT_WALK_SPEED = 24
GameConfig.PERSONAL_SPEED_BUFF = 6
GameConfig.SPEED_BUFF_USERNAMES = {
	wilso = true,
	Wilson = true,
	wilson = true,
}
GameConfig.SPEED_BUFF_DISPLAY_NAMES = {
	wilso = true,
	Wilson = true,
	wilson = true,
}

GameConfig.CLAIM_PROMPT_RANGE = 14
GameConfig.BUTTON_PROMPT_RANGE = 12
GameConfig.COLLECTOR_PROMPT_RANGE = 12
GameConfig.CLAIM_TELEPORT_ON_CLAIM = false
GameConfig.CLAIM_PAD_OFFSET = Vector3.new(0, 1.5, -48)
GameConfig.CLAIM_PAD_UNCLAIMED_SIZE = Vector3.new(18, 1, 18)
GameConfig.CLAIM_PAD_CLAIMED_SIZE = Vector3.new(10, 1, 10)
GameConfig.BUTTON_LANE_X_OFFSET = 48
GameConfig.BUTTON_LANE_START_Z = -66
GameConfig.BUTTON_LANE_STEP_Z = 8
GameConfig.BUTTON_LANE_LENGTH = 168
GameConfig.BUTTON_PAD_SIZE = Vector3.new(6, 1, 6)
GameConfig.EARNINGS_BOARD_OFFSET = Vector3.new(-42, 11, -70)
GameConfig.TYCOON_ENTRY_DOOR_OFFSET = Vector3.new(0, 7, -68)
GameConfig.TYCOON_ENTRY_PANEL_OFFSET = Vector3.new(0, 5, -68.75)
GameConfig.TYCOON_ENTRY_PANEL_OPEN_OFFSET = Vector3.new(0, 11, 0)
GameConfig.TYCOON_ENTRY_SENSOR_OFFSET = Vector3.new(18, 3.5, -74)
GameConfig.TYCOON_ENTRY_INSIDE_SENSOR_OFFSET = Vector3.new(18, 3.5, -62)
GameConfig.TYCOON_ENTRY_FRAME_WIDTH = 30
GameConfig.TYCOON_ENTRY_PANEL_WIDTH = 14
GameConfig.TYCOON_ENTRY_SIDE_SUPPORT_WIDTH = 4
GameConfig.TYCOON_ENTRY_SIDE_SUPPORT_DEPTH = 4
GameConfig.TYCOON_CLICKER_OFFSET = Vector3.new(8, 1.3, -26)
GameConfig.TYCOON_STARTER_BUTTON_OFFSET = Vector3.new(8, 4.8, -24)
GameConfig.TYCOON_STARTER_OUTPUT_OFFSET = Vector3.new(5, 6.2, -30)
GameConfig.TYCOON_SPAWN_OFFSET = Vector3.new(48, 2.5, 58)
GameConfig.TYCOON_CONVEYOR_X_OFFSET = -34
GameConfig.TYCOON_CONVEYOR_Z_OFFSET = -6
GameConfig.TYCOON_CONVEYOR_LENGTH = 92
GameConfig.TYCOON_CONVEYOR_ENTRY_Z_OFFSET = -44
GameConfig.TYCOON_COLLECTOR_Z_OFFSET = 32
GameConfig.TYCOON_COLLECTOR_PAD_Z_OFFSET = 40
GameConfig.TYCOON_AUTO_COLLECTOR_Z_OFFSET = 46
GameConfig.TYCOON_WALL_FRONT_Z = -68
GameConfig.TYCOON_WALL_BACK_Z = 68
GameConfig.TYCOON_LOW_WALL_Y_OFFSET = 6
GameConfig.TYCOON_LOW_WALL_HEIGHT = 12
GameConfig.TYCOON_HIGH_WALL_Y_OFFSET = 18
GameConfig.TYCOON_HIGH_WALL_HEIGHT = 20
GameConfig.TYCOON_WALL_SIDE_LENGTH = 138
GameConfig.TYCOON_WALL_BACK_WIDTH = 118
GameConfig.TYCOON_WALL_FRONT_SEGMENT_WIDTH = 46
GameConfig.TYCOON_WALL_SIDE_X = 59
GameConfig.TYCOON_WALL_FRONT_LEFT_X = -36
GameConfig.TYCOON_WALL_FRONT_RIGHT_X = 36

GameConfig.TYCOON_SIZE = Vector3.new(152, 2, 184)
GameConfig.TYCOON_PADDING = 96
GameConfig.MAP_CENTRAL_PLAZA_SIZE = Vector3.new(220, 2, 220)
GameConfig.MAP_RING_SIDE_DISTANCE = 305
GameConfig.MAP_RING_PAIR_SPACING = 180
GameConfig.MAP_CORNER_DECORATION_INSET = 86
GameConfig.MAP_CENTER_DECORATION_RADIUS = 42
GameConfig.MAP_BOUNDARY_HEIGHT = 90
GameConfig.MAP_BOUNDARY_THICKNESS = 8
GameConfig.MAP_BOUNDARY_INSET = 18
GameConfig.MAP_BOUNDARY_COLOR = Color3.fromRGB(92, 108, 116)
GameConfig.MAP_BOUNDARY_GLOW_COLOR = Color3.fromRGB(142, 210, 190)
GameConfig.MAP_DECOR_PRIMARY = Color3.fromRGB(255, 138, 216)
GameConfig.MAP_DECOR_SECONDARY = Color3.fromRGB(255, 214, 241)
GameConfig.MAP_DECOR_ACCENT = Color3.fromRGB(196, 116, 255)
GameConfig.MAP_TREE_RING_RADIUS = 418
GameConfig.MAP_TREE_CLUSTER_COUNT = 30
GameConfig.MAP_MOUNTAIN_RING_RADIUS = 452
GameConfig.MAP_MOUNTAIN_CLUSTER_COUNT = 14
GameConfig.PINK_SKY_ENABLED = true
GameConfig.PINK_SKY_AMBIENT = Color3.fromRGB(140, 104, 148)
GameConfig.PINK_SKY_OUTDOOR_AMBIENT = Color3.fromRGB(182, 132, 170)
GameConfig.PINK_SKY_FOG_COLOR = Color3.fromRGB(255, 190, 222)
GameConfig.PINK_SKY_TOP_COLOR = Color3.fromRGB(255, 163, 223)
GameConfig.PINK_SKY_BOTTOM_COLOR = Color3.fromRGB(255, 222, 238)
GameConfig.PLOT_BOUNDARY_HEIGHT = 22
GameConfig.CONVEYOR_SPEED_EARNINGS_MULTIPLIER = 1.2
GameConfig.PREMIUM_CONVEYOR_EARNINGS_MULTIPLIER = 1.18
GameConfig.CASH_COMPRESSOR_VALUE_MULTIPLIER = 1.25
GameConfig.COLLECTOR_ARRAY_VALUE_MULTIPLIER = 1.15
GameConfig.BASE_CONVEYOR_TRAVEL_TIME = 2.1
GameConfig.FAST_CONVEYOR_TRAVEL_TIME = 1.35
GameConfig.PREMIUM_CONVEYOR_TRAVEL_TIME = 0.95

GameConfig.WORKSPACE_FOLDERS = {
	Lobby = "Lobby",
	SharedMap = "SharedMap",
	TycoonPlots = "TycoonPlots",
}

local function makeTycoonDefinition(id: string, origin: Vector3, accent: Color3, mapSide: string, facingYaw: number)
	return {
		Id = id,
		MapSide = mapSide,
		FacingYaw = facingYaw,
		Origin = origin,
		Accent = accent,
	}
end

GameConfig.UPGRADES = {
	basic_dropper = {
		id = "basic_dropper",
		name = "Basic Dropper",
		cost = 100,
		description = "Automates the starter clicker lane.",
		category = "income",
	},
	collector = {
		id = "collector",
		name = "Collector",
		cost = 60,
		description = "Improves the collector machine.",
		category = "utility",
		requires = { "basic_dropper" },
	},
	conveyor_speed = {
		id = "conveyor_speed",
		name = "Conveyor Upgrade",
		cost = 75,
		description = "Speeds up the conveyor lane.",
		category = "utility",
		requires = { "basic_dropper" },
	},
	second_dropper = {
		id = "second_dropper",
		name = "Second Dropper",
		cost = 220,
		description = "Adds a second generator lane.",
		category = "income",
		requires = { "collector", "conveyor_speed" },
	},
	dropper_3 = {
		id = "dropper_3",
		name = "Dropper 3",
		cost = 320,
		description = "Adds a third automated dropper.",
		category = "income",
		requires = { "second_dropper" },
	},
	dropper_4 = {
		id = "dropper_4",
		name = "Dropper 4",
		cost = 460,
		description = "Adds a fourth automated dropper.",
		category = "income",
		requires = { "dropper_3" },
	},
	dropper_5 = {
		id = "dropper_5",
		name = "Dropper 5",
		cost = 650,
		description = "Adds a fifth automated dropper.",
		category = "income",
		requires = { "dropper_4" },
	},
	dropper_6 = {
		id = "dropper_6",
		name = "Dropper 6",
		cost = 900,
		description = "Adds a sixth automated dropper.",
		category = "income",
		requires = { "dropper_5" },
	},
	dropper_7 = {
		id = "dropper_7",
		name = "Dropper 7",
		cost = 1200,
		description = "Adds a seventh automated dropper.",
		category = "income",
		requires = { "dropper_6" },
	},
	dropper_8 = {
		id = "dropper_8",
		name = "Dropper 8",
		cost = 1600,
		description = "Adds the final first-floor automated dropper.",
		category = "income",
		requires = { "dropper_7" },
	},
	auto_collector = {
		id = "auto_collector",
		name = "Auto Collector",
		cost = 2500,
		description = "Unlocks the automatic collector after all eight droppers.",
		category = "utility",
		requires = { "dropper_8" },
	},
	premium_conveyor = {
		id = "premium_conveyor",
		name = "Premium Conveyor",
		cost = 3600,
		description = "Pushes money faster through the upgraded lane.",
		category = "utility",
		requires = { "auto_collector", "conveyor_speed" },
	},
	cash_compressor = {
		id = "cash_compressor",
		name = "Cash Compressor",
		cost = 5200,
		description = "Boosts each money block before it reaches the collector.",
		category = "utility",
		requires = { "premium_conveyor" },
	},
	collector_array = {
		id = "collector_array",
		name = "Collector Array",
		cost = 7600,
		description = "Adds side collectors that further boost each payout.",
		category = "utility",
		requires = { "cash_compressor" },
	},
	wall_set_1 = {
		id = "wall_set_1",
		name = "Wall Set 1",
		cost = 160,
		description = "Adds the starter perimeter walls around the expanded floor.",
		category = "structure",
		requires = { "basic_dropper" },
	},
	front_door = {
		id = "front_door",
		name = "Front Door",
		cost = 220,
		description = "Adds the owner entry frame and security door button.",
		category = "structure",
		requires = { "wall_set_1" },
	},
	reinforced_door = {
		id = "reinforced_door",
		name = "Reinforced Door",
		cost = 320,
		description = "Upgrades the front door to a stronger owner gate.",
		category = "structure",
		requires = { "front_door", "dropper_4" },
	},
	high_walls = {
		id = "high_walls",
		name = "High Walls",
		cost = 460,
		description = "Raises the perimeter walls for a taller base shape.",
		category = "structure",
		requires = { "reinforced_door" },
	},
	security_lights = {
		id = "security_lights",
		name = "Security Lights",
		cost = 2800,
		description = "Adds bright perimeter lights around the base shell.",
		category = "structure",
		requires = { "high_walls" },
	},
	corner_posts = {
		id = "corner_posts",
		name = "Corner Posts",
		cost = 3600,
		description = "Adds heavy support posts to tighten the base silhouette.",
		category = "structure",
		requires = { "security_lights" },
	},
	rear_extension = {
		id = "rear_extension",
		name = "Rear Extension",
		cost = 4200,
		description = "Expands the back half of the floor around the collector lane.",
		category = "structure",
		requires = { "corner_posts" },
	},
	utility_bay = {
		id = "utility_bay",
		name = "Utility Bay",
		cost = 5600,
		description = "Builds a larger side service bay with pipes and equipment.",
		category = "structure",
		requires = { "rear_extension" },
	},
	armory_bay = {
		id = "armory_bay",
		name = "Armory Bay",
		cost = 8400,
		description = "Builds a weapon bay inside the utility wing.",
		category = "structure",
		requires = { "utility_bay", "high_walls" },
	},
	combat_knife = {
		id = "combat_knife",
		name = "Combat Knife",
		cost = 1800,
		description = "Unlocks a melee weapon from the armory.",
		category = "combat",
		requires = { "armory_bay" },
	},
	money_blaster = {
		id = "money_blaster",
		name = "Money Blaster",
		cost = 6200,
		description = "Unlocks a short-range cash blaster.",
		category = "combat",
		requires = { "armory_bay", "cash_compressor" },
	},
	money_rpg = {
		id = "money_rpg",
		name = "Money RPG",
		cost = 20000,
		description = "Unlocks a top-tier rocket launcher.",
		category = "combat",
		requires = { "money_blaster", "second_floor" },
	},
	roof_frame = {
		id = "roof_frame",
		name = "Roof Frame",
		cost = 6800,
		description = "Adds an overhead steel frame across the expanded first floor.",
		category = "structure",
		requires = { "utility_bay" },
	},
	developer_full_build = {
		id = "developer_full_build",
		name = "Developer Full Build",
		cost = 100000,
		description = "Developer shortcut that builds the full tycoon chain instantly.",
		category = "developer",
	},
}

for _, upgradeId in SecondFloorConfig.UPPER_UPGRADES do
	if upgradeId ~= "roof_frame" then
		local overview = SecondFloorConfig.getUpgrade(upgradeId)
		if overview then
			GameConfig.UPGRADES[upgradeId] = {
				id = upgradeId,
				name = overview.name,
				cost = overview.cost,
				description = overview.description,
				category = overview.category,
				requires = SecondFloorConfig.getRequirements(upgradeId),
			}
		end
	end
end

for _, upgradeId in ThirdFloorConfig.UPGRADES do
	local overview = ThirdFloorConfig.getUpgrade(upgradeId)
	if overview then
		GameConfig.UPGRADES[upgradeId] = {
			id = upgradeId,
			name = overview.name,
			cost = overview.cost,
			description = overview.description,
			category = overview.category,
			requires = ThirdFloorConfig.getRequirements(upgradeId),
		}
	end
end

GameConfig.DROPPER_ORDER = {
	"basic_dropper",
	"second_dropper",
	"dropper_3",
	"dropper_4",
	"dropper_5",
	"dropper_6",
	"dropper_7",
	"dropper_8",
}

GameConfig.UPPER_DROPPER_ORDER = table.clone(SecondFloorConfig.UPPER_DROPPER_ORDER)
GameConfig.THIRD_DROPPER_ORDER = table.clone(ThirdFloorConfig.DROPPER_ORDER)
GameConfig.ALL_DROPPER_ORDER = table.clone(GameConfig.DROPPER_ORDER)
for _, upgradeId in GameConfig.UPPER_DROPPER_ORDER do
	table.insert(GameConfig.ALL_DROPPER_ORDER, upgradeId)
end
for _, upgradeId in GameConfig.THIRD_DROPPER_ORDER do
	table.insert(GameConfig.ALL_DROPPER_ORDER, upgradeId)
end

GameConfig.SECOND_FLOOR_UPGRADE_ORDER = {
	"second_floor",
	"upper_walls",
	"upper_conveyor",
	"upper_dropper_1",
	"upper_dropper_2",
	"upper_dropper_3",
	"upper_dropper_4",
	"upper_collector",
}

GameConfig.THIRD_FLOOR_UPGRADE_ORDER = {
	"third_floor",
	"third_floor_walls",
	"third_conveyor",
	"third_dropper_1",
	"third_dropper_2",
	"third_dropper_3",
	"third_dropper_4",
	"third_collector",
}

GameConfig.UPGRADE_ORDER = {
	"basic_dropper",
	"collector",
	"conveyor_speed",
	"second_dropper",
	"dropper_3",
	"dropper_4",
	"dropper_5",
	"dropper_6",
	"dropper_7",
	"dropper_8",
	"auto_collector",
	"premium_conveyor",
	"cash_compressor",
	"collector_array",
	"wall_set_1",
	"front_door",
	"reinforced_door",
	"high_walls",
	"security_lights",
	"corner_posts",
	"rear_extension",
	"utility_bay",
	"armory_bay",
	"combat_knife",
	"money_blaster",
	"money_rpg",
	"roof_frame",
	"second_floor",
	"upper_walls",
	"upper_conveyor",
	"upper_dropper_1",
	"upper_dropper_2",
	"upper_dropper_3",
	"upper_dropper_4",
	"upper_collector",
	"third_floor",
	"third_floor_walls",
	"third_conveyor",
	"third_dropper_1",
	"third_dropper_2",
	"third_dropper_3",
	"third_dropper_4",
	"third_collector",
	"developer_full_build",
}

GameConfig.WEAPON_UPGRADE_ORDER = {
	"combat_knife",
	"money_blaster",
	"money_rpg",
}

GameConfig.DROPPERS = {
	basic_dropper = {
		interval = 2.5,
		value = 10,
		color = Color3.fromRGB(122, 255, 151),
		offset = Vector3.new(-44, 5, -52),
	},
	second_dropper = {
		interval = 2.05,
		value = 18,
		color = Color3.fromRGB(255, 215, 102),
		offset = Vector3.new(-24, 5, -52),
	},
	dropper_3 = {
		interval = 1.9,
		value = 24,
		color = Color3.fromRGB(102, 209, 255),
		offset = Vector3.new(-44, 5, -34),
	},
	dropper_4 = {
		interval = 1.75,
		value = 32,
		color = Color3.fromRGB(255, 145, 102),
		offset = Vector3.new(-24, 5, -34),
	},
	dropper_5 = {
		interval = 1.55,
		value = 42,
		color = Color3.fromRGB(255, 112, 172),
		offset = Vector3.new(-44, 5, -16),
	},
	dropper_6 = {
		interval = 1.4,
		value = 54,
		color = Color3.fromRGB(124, 255, 220),
		offset = Vector3.new(-24, 5, -16),
	},
	dropper_7 = {
		interval = 1.25,
		value = 68,
		color = Color3.fromRGB(255, 209, 112),
		offset = Vector3.new(-44, 5, 2),
	},
	dropper_8 = {
		interval = 1.1,
		value = 84,
		color = Color3.fromRGB(178, 124, 255),
		offset = Vector3.new(-24, 5, 2),
	},
}

GameConfig.UPPER_DROPPERS = table.clone(SecondFloorConfig.UPPER_DROPPERS)
GameConfig.THIRD_DROPPERS = table.clone(ThirdFloorConfig.DROPPERS)

GameConfig.BUTTON_LAYOUTS = {
	basic_dropper = {
		offset = Vector3.new(-55, 1.3, -52),
	},
	second_dropper = {
		offset = Vector3.new(-13, 1.3, -52),
	},
	dropper_3 = {
		offset = Vector3.new(-55, 1.3, -34),
	},
	dropper_4 = {
		offset = Vector3.new(-13, 1.3, -34),
	},
	dropper_5 = {
		offset = Vector3.new(-55, 1.3, -16),
	},
	dropper_6 = {
		offset = Vector3.new(-13, 1.3, -16),
	},
	dropper_7 = {
		offset = Vector3.new(-55, 1.3, 2),
	},
	dropper_8 = {
		offset = Vector3.new(-13, 1.3, 2),
	},
	collector = {
		offset = Vector3.new(-13, 1.3, 31),
	},
	conveyor_speed = {
		offset = Vector3.new(-13, 1.3, -2),
	},
	auto_collector = {
		offset = Vector3.new(-13, 1.3, 47),
	},
	premium_conveyor = {
		offset = Vector3.new(-13, 1.3, 12),
	},
	cash_compressor = {
		offset = Vector3.new(-2, 1.3, 47),
	},
	collector_array = {
		offset = Vector3.new(-2, 1.3, 33),
	},
	wall_set_1 = {
		offset = Vector3.new(34, 1.3, -49),
	},
	front_door = {
		offset = Vector3.new(18, 1.3, -49),
	},
	reinforced_door = {
		offset = Vector3.new(18, 1.3, -39),
	},
	high_walls = {
		offset = Vector3.new(34, 1.3, -39),
	},
	security_lights = {
		offset = Vector3.new(34, 1.3, 49),
	},
	corner_posts = {
		offset = Vector3.new(18, 1.3, 49),
	},
	rear_extension = {
		offset = Vector3.new(18, 1.3, 61),
	},
	utility_bay = {
		offset = Vector3.new(34, 1.3, 61),
	},
	armory_bay = {
		offset = Vector3.new(34, 1.3, -7),
	},
	combat_knife = {
		offset = Vector3.new(42, 1.3, 6),
	},
	money_blaster = {
		offset = Vector3.new(56, 1.3, 6),
	},
	money_rpg = {
		offset = Vector3.new(49, 1.3, 22),
	},
	roof_frame = {
		offset = Vector3.new(26, 1.3, 71),
	},
	developer_full_build = {
		offset = Vector3.new(-18, 1.3, -60),
	},
}

for upgradeId, layout in SecondFloorConfig.getButtonLayouts() do
	GameConfig.BUTTON_LAYOUTS[upgradeId] = layout
end

for upgradeId, layout in ThirdFloorConfig.getButtonLayouts() do
	GameConfig.BUTTON_LAYOUTS[upgradeId] = layout
end

GameConfig.TYCOONS = {
	makeTycoonDefinition("TycoonA", Vector3.new(-GameConfig.MAP_RING_SIDE_DISTANCE, 0, -GameConfig.MAP_RING_PAIR_SPACING / 2), Color3.fromRGB(73, 170, 255), "left", -90),
	makeTycoonDefinition("TycoonB", Vector3.new(-GameConfig.MAP_RING_SIDE_DISTANCE, 0, GameConfig.MAP_RING_PAIR_SPACING / 2), Color3.fromRGB(255, 125, 96), "left", -90),
	makeTycoonDefinition("TycoonC", Vector3.new(GameConfig.MAP_RING_SIDE_DISTANCE, 0, -GameConfig.MAP_RING_PAIR_SPACING / 2), Color3.fromRGB(145, 255, 158), "right", 90),
	makeTycoonDefinition("TycoonD", Vector3.new(GameConfig.MAP_RING_SIDE_DISTANCE, 0, GameConfig.MAP_RING_PAIR_SPACING / 2), Color3.fromRGB(255, 211, 103), "right", 90),
	makeTycoonDefinition("TycoonE", Vector3.new(-GameConfig.MAP_RING_PAIR_SPACING / 2, 0, -GameConfig.MAP_RING_SIDE_DISTANCE), Color3.fromRGB(196, 144, 255), "front", 180),
	makeTycoonDefinition("TycoonF", Vector3.new(GameConfig.MAP_RING_PAIR_SPACING / 2, 0, -GameConfig.MAP_RING_SIDE_DISTANCE), Color3.fromRGB(125, 225, 255), "front", 180),
	makeTycoonDefinition("TycoonG", Vector3.new(-GameConfig.MAP_RING_PAIR_SPACING / 2, 0, GameConfig.MAP_RING_SIDE_DISTANCE), Color3.fromRGB(255, 146, 196), "back", 0),
	makeTycoonDefinition("TycoonH", Vector3.new(GameConfig.MAP_RING_PAIR_SPACING / 2, 0, GameConfig.MAP_RING_SIDE_DISTANCE), Color3.fromRGB(159, 255, 211), "back", 0),
}

function GameConfig.getUpgrade(upgradeId: string)
	return GameConfig.UPGRADES[upgradeId]
end

function GameConfig.getConfiguredDropper(upgradeId: string)
	return GameConfig.DROPPERS[upgradeId] or GameConfig.UPPER_DROPPERS[upgradeId] or GameConfig.THIRD_DROPPERS[upgradeId]
end

function GameConfig.getUpperDropperIds(): { string }
	return table.clone(GameConfig.UPPER_DROPPER_ORDER)
end

function GameConfig.getThirdDropperIds(): { string }
	return table.clone(GameConfig.THIRD_DROPPER_ORDER)
end

function GameConfig.getAllDropperIds(): { string }
	return table.clone(GameConfig.ALL_DROPPER_ORDER)
end

function GameConfig.getWeaponUpgradeIds(): { string }
	return table.clone(GameConfig.WEAPON_UPGRADE_ORDER)
end

function GameConfig.isUpperFloorUpgrade(upgradeId: string): boolean
	for _, configuredUpgradeId in GameConfig.SECOND_FLOOR_UPGRADE_ORDER do
		if configuredUpgradeId == upgradeId then
			return true
		end
	end

	return false
end

function GameConfig.isThirdFloorUpgrade(upgradeId: string): boolean
	for _, configuredUpgradeId in GameConfig.THIRD_FLOOR_UPGRADE_ORDER do
		if configuredUpgradeId == upgradeId then
			return true
		end
	end

	return false
end

function GameConfig.getConveyorEarningsMultiplier(purchased: { [string]: boolean }): number
	local multiplier = 1

	if purchased.conveyor_speed then
		multiplier *= GameConfig.CONVEYOR_SPEED_EARNINGS_MULTIPLIER
	end

	if purchased.premium_conveyor then
		multiplier *= GameConfig.PREMIUM_CONVEYOR_EARNINGS_MULTIPLIER
	end

	return multiplier
end

function GameConfig.getConveyorTravelTime(purchased: { [string]: boolean }): number
	if purchased.premium_conveyor then
		return GameConfig.PREMIUM_CONVEYOR_TRAVEL_TIME
	end

	if purchased.conveyor_speed then
		return GameConfig.FAST_CONVEYOR_TRAVEL_TIME
	end

	return GameConfig.BASE_CONVEYOR_TRAVEL_TIME
end

function GameConfig.getDropperPayoutValue(dropperId: string, purchased: { [string]: boolean }): number
	local dropperConfig = GameConfig.getConfiguredDropper(dropperId)
	if not dropperConfig then
		return 0
	end

	local value = dropperConfig.value
	if purchased.cash_compressor then
		value *= GameConfig.CASH_COMPRESSOR_VALUE_MULTIPLIER
	end
	if purchased.collector_array then
		value *= GameConfig.COLLECTOR_ARRAY_VALUE_MULTIPLIER
	end

	return math.floor(value + 0.5)
end

function GameConfig.getEarningsPerSecondForUpgrades(purchased: { [string]: boolean }): number
	local total = 0
	for dropperId, dropperConfig in GameConfig.DROPPERS do
		if purchased[dropperId] then
			total += GameConfig.getDropperPayoutValue(dropperId, purchased) / dropperConfig.interval
		end
	end

	for dropperId, dropperConfig in GameConfig.UPPER_DROPPERS do
		if purchased[dropperId] then
			total += GameConfig.getDropperPayoutValue(dropperId, purchased) / dropperConfig.interval
		end
	end

	for dropperId, dropperConfig in GameConfig.THIRD_DROPPERS do
		if purchased[dropperId] then
			total += GameConfig.getDropperPayoutValue(dropperId, purchased) / dropperConfig.interval
		end
	end

	total *= GameConfig.getConveyorEarningsMultiplier(purchased)
	return math.floor(total * 10 + 0.5) / 10
end

function GameConfig.areRequirementsMet(purchased: { [string]: boolean }, upgradeId: string): boolean
	local upgrade = GameConfig.getUpgrade(upgradeId)
	if not upgrade or not upgrade.requires then
		return true
	end

	for _, requirement in upgrade.requires do
		if not purchased[requirement] then
			return false
		end
	end

	return true
end

function GameConfig.hasPersonalSpeedBuff(player): boolean
	if not player then
		return false
	end

	return GameConfig.SPEED_BUFF_USERNAMES[player.Name] == true
		or GameConfig.SPEED_BUFF_DISPLAY_NAMES[player.DisplayName] == true
end

function GameConfig.getStartingCash(player): number
	if player and GameConfig.PERSONAL_STARTING_CASH[player.Name] ~= nil then
		return GameConfig.PERSONAL_STARTING_CASH[player.Name]
	end

	return GameConfig.STARTING_CASH
end

function GameConfig.getWalkSpeed(player, sprinting: boolean?): number
	local speed = if sprinting then GameConfig.SPRINT_WALK_SPEED else GameConfig.BASE_WALK_SPEED
	if GameConfig.hasPersonalSpeedBuff(player) then
		speed += GameConfig.PERSONAL_SPEED_BUFF
	end

	return speed
end

return GameConfig
