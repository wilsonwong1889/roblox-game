local GameConfig = {}

GameConfig.GAME_NAME = "Break-In Tycoon"
GameConfig.GAME_STAGE = "Week 1 Foundation"
GameConfig.ACTIVE_TYCOON_COUNT = 2

GameConfig.STARTING_CASH = 0
GameConfig.STARTING_STASH_CASH = 0
GameConfig.STARTING_VAULT_CASH = 0

GameConfig.CLAIM_PROMPT_RANGE = 14
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

return GameConfig
