local GameConfig = {}

GameConfig.GAME_NAME = "Break-In Tycoon"
GameConfig.GAME_STAGE = "Week 3 Walls and Doors"
GameConfig.WEEK_PHASE = "Week 3 Walls and Doors"
GameConfig.ACTIVE_TYCOON_COUNT = 2

GameConfig.STARTING_CASH = 100
GameConfig.STARTING_STASH_CASH = 0
GameConfig.STARTING_VAULT_CASH = 0

GameConfig.CLAIM_PROMPT_RANGE = 14
GameConfig.BUTTON_PROMPT_RANGE = 12
GameConfig.COLLECTOR_PROMPT_RANGE = 12
GameConfig.CLAIM_TELEPORT_ON_CLAIM = false
GameConfig.BUTTON_LANE_X_OFFSET = 38
GameConfig.BUTTON_LANE_START_Z = -34
GameConfig.BUTTON_LANE_STEP_Z = 10
GameConfig.EARNINGS_BOARD_OFFSET = Vector3.new(-28, 10, -46)
GameConfig.TYCOON_ENTRY_DOOR_OFFSET = Vector3.new(0, 7, -40)
GameConfig.TYCOON_ENTRY_PANEL_OFFSET = Vector3.new(0, 5, -40.75)
GameConfig.TYCOON_ENTRY_SENSOR_OFFSET = Vector3.new(0, 6, -34)
GameConfig.TYCOON_WALL_FRONT_Z = -42
GameConfig.TYCOON_WALL_BACK_Z = 42
GameConfig.TYCOON_LOW_WALL_Y_OFFSET = 6
GameConfig.TYCOON_LOW_WALL_HEIGHT = 12
GameConfig.TYCOON_HIGH_WALL_Y_OFFSET = 18
GameConfig.TYCOON_HIGH_WALL_HEIGHT = 18

GameConfig.TYCOON_SPACING = 170
GameConfig.TYCOON_SIZE = Vector3.new(88, 2, 96)
GameConfig.TYCOON_PADDING = 60
GameConfig.PLOT_BOUNDARY_HEIGHT = 18

GameConfig.WORKSPACE_FOLDERS = {
	Lobby = "Lobby",
	SharedMap = "SharedMap",
	TycoonPlots = "TycoonPlots",
}

GameConfig.UPGRADES = {
	basic_dropper = {
		id = "basic_dropper",
		name = "Basic Dropper",
		cost = 50,
		description = "Starts the money loop.",
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
		cost = 140,
		description = "Adds a second generator lane.",
		category = "income",
		requires = { "collector", "conveyor_speed" },
	},
	wall_set_1 = {
		id = "wall_set_1",
		name = "Wall Set 1",
		cost = 120,
		description = "Adds the starter perimeter walls.",
		category = "structure",
		requires = { "basic_dropper" },
	},
	front_door = {
		id = "front_door",
		name = "Front Door",
		cost = 160,
		description = "Adds the owner entry frame and security door.",
		category = "structure",
		requires = { "wall_set_1" },
	},
	reinforced_door = {
		id = "reinforced_door",
		name = "Reinforced Door",
		cost = 260,
		description = "Upgrades the front door to a stronger owner gate.",
		category = "structure",
		requires = { "front_door", "second_dropper" },
	},
	high_walls = {
		id = "high_walls",
		name = "High Walls",
		cost = 340,
		description = "Raises the perimeter walls for a taller base shape.",
		category = "structure",
		requires = { "reinforced_door" },
	},
}

GameConfig.UPGRADE_ORDER = {
	"basic_dropper",
	"collector",
	"conveyor_speed",
	"second_dropper",
	"wall_set_1",
	"front_door",
	"reinforced_door",
	"high_walls",
}

GameConfig.DROPPERS = {
	basic_dropper = {
		interval = 2.5,
		value = 10,
		color = Color3.fromRGB(122, 255, 151),
	},
	second_dropper = {
		interval = 1.65,
		value = 18,
		color = Color3.fromRGB(255, 215, 102),
	},
}

GameConfig.TYCOONS = {
	{
		Id = "TycoonA",
		Origin = Vector3.new(-GameConfig.TYCOON_SPACING / 2, 0, 0),
		Accent = Color3.fromRGB(73, 170, 255),
	},
	{
		Id = "TycoonB",
		Origin = Vector3.new(GameConfig.TYCOON_SPACING / 2, 0, 0),
		Accent = Color3.fromRGB(255, 125, 96),
	},
}

function GameConfig.getUpgrade(upgradeId: string)
	return GameConfig.UPGRADES[upgradeId]
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

return GameConfig
