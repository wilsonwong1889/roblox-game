local SecondFloorConfig = require(script.Parent.SecondFloorConfig)

local GameConfig = {}

GameConfig.GAME_NAME = "Break-In Tycoon"
GameConfig.GAME_STAGE = "Week 6 Eight Tycoon Expansion"
GameConfig.WEEK_PHASE = "Week 6 Eight Tycoon Expansion"
GameConfig.ACTIVE_TYCOON_COUNT = 8
GameConfig.SECOND_FLOOR_ENABLED = SecondFloorConfig.ENABLED

GameConfig.STARTING_CASH = 200000
GameConfig.STARTING_STASH_CASH = 0
GameConfig.STARTING_VAULT_CASH = 0
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
GameConfig.TYCOON_ENTRY_SENSOR_OFFSET = Vector3.new(18, 3.5, -74)
GameConfig.TYCOON_ENTRY_INSIDE_SENSOR_OFFSET = Vector3.new(18, 3.5, -62)
GameConfig.TYCOON_ENTRY_FRAME_WIDTH = 30
GameConfig.TYCOON_ENTRY_PANEL_WIDTH = 14
GameConfig.TYCOON_ENTRY_SIDE_SUPPORT_WIDTH = 4
GameConfig.TYCOON_ENTRY_SIDE_SUPPORT_DEPTH = 4
GameConfig.TYCOON_CLICKER_OFFSET = Vector3.new(-45, 1.3, 18)
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

GameConfig.TYCOON_GRID_COLUMNS = 4
GameConfig.TYCOON_GRID_ROWS = 2
GameConfig.TYCOON_GRID_COLUMN_SPACING = 260
GameConfig.TYCOON_GRID_ROW_SPACING = 300
GameConfig.TYCOON_SPACING = GameConfig.TYCOON_GRID_COLUMN_SPACING
GameConfig.TYCOON_SIZE = Vector3.new(152, 2, 184)
GameConfig.TYCOON_PADDING = 96
GameConfig.MAP_CENTRAL_PLAZA_SIZE = Vector3.new(180, 2, 180)
GameConfig.MAP_CENTRAL_PLAZA_PADDING = Vector3.new(64, 0, 64)
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

local function getGridOffset(index: number, total: number, spacing: number): number
	return (index - ((total + 1) / 2)) * spacing
end

local function makeTycoonDefinition(id: string, column: number, row: number, accent: Color3)
	return {
		Id = id,
		GridColumn = column,
		GridRow = row,
		Origin = Vector3.new(
			getGridOffset(column, GameConfig.TYCOON_GRID_COLUMNS, GameConfig.TYCOON_GRID_COLUMN_SPACING),
			0,
			getGridOffset(row, GameConfig.TYCOON_GRID_ROWS, GameConfig.TYCOON_GRID_ROW_SPACING)
		),
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
GameConfig.ALL_DROPPER_ORDER = table.clone(GameConfig.DROPPER_ORDER)
for _, upgradeId in GameConfig.UPPER_DROPPER_ORDER do
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
	"roof_frame",
	"second_floor",
	"upper_walls",
	"upper_conveyor",
	"upper_dropper_1",
	"upper_dropper_2",
	"upper_dropper_3",
	"upper_dropper_4",
	"upper_collector",
	"developer_full_build",
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

GameConfig.TYCOONS = {
	makeTycoonDefinition("TycoonA", 1, 1, Color3.fromRGB(73, 170, 255)),
	makeTycoonDefinition("TycoonB", 2, 1, Color3.fromRGB(255, 125, 96)),
	makeTycoonDefinition("TycoonC", 3, 1, Color3.fromRGB(145, 255, 158)),
	makeTycoonDefinition("TycoonD", 4, 1, Color3.fromRGB(255, 211, 103)),
	makeTycoonDefinition("TycoonE", 1, 2, Color3.fromRGB(196, 144, 255)),
	makeTycoonDefinition("TycoonF", 2, 2, Color3.fromRGB(125, 225, 255)),
	makeTycoonDefinition("TycoonG", 3, 2, Color3.fromRGB(255, 146, 196)),
	makeTycoonDefinition("TycoonH", 4, 2, Color3.fromRGB(159, 255, 211)),
}

function GameConfig.getUpgrade(upgradeId: string)
	return GameConfig.UPGRADES[upgradeId]
end

function GameConfig.getConfiguredDropper(upgradeId: string)
	return GameConfig.DROPPERS[upgradeId] or GameConfig.UPPER_DROPPERS[upgradeId]
end

function GameConfig.getUpperDropperIds(): { string }
	return table.clone(GameConfig.UPPER_DROPPER_ORDER)
end

function GameConfig.getAllDropperIds(): { string }
	return table.clone(GameConfig.ALL_DROPPER_ORDER)
end

function GameConfig.isUpperFloorUpgrade(upgradeId: string): boolean
	for _, configuredUpgradeId in GameConfig.SECOND_FLOOR_UPGRADE_ORDER do
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

function GameConfig.getWalkSpeed(player, sprinting: boolean?): number
	local speed = if sprinting then GameConfig.SPRINT_WALK_SPEED else GameConfig.BASE_WALK_SPEED
	if GameConfig.hasPersonalSpeedBuff(player) then
		speed += GameConfig.PERSONAL_SPEED_BUFF
	end

	return speed
end

return GameConfig
