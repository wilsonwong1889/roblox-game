local GameConfig = {}

GameConfig.GAME_NAME = "Break-In Tycoon"
GameConfig.GAME_STAGE = "Week 2 Economy"
GameConfig.WEEK_PHASE = "Week 2 Economy"
GameConfig.ACTIVE_TYCOON_COUNT = 2

GameConfig.STARTING_CASH = 100
GameConfig.STARTING_STASH_CASH = 0
GameConfig.STARTING_VAULT_CASH = 0

GameConfig.CLAIM_PROMPT_RANGE = 14
GameConfig.BUTTON_PROMPT_RANGE = 12
GameConfig.COLLECTOR_PROMPT_RANGE = 12
GameConfig.CLAIM_TELEPORT_ON_CLAIM = false

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
}

GameConfig.UPGRADE_ORDER = {
	"basic_dropper",
	"collector",
	"conveyor_speed",
	"second_dropper",
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
