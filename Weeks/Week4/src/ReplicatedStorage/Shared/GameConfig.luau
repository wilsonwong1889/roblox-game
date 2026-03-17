local GameConfig = {}

GameConfig.PLOTS = 4
GameConfig.PLOT_SPACING = 140
GameConfig.STARTING_CASH = 25
GameConfig.BASE_GENERATOR_COST = 25
GameConfig.COST_GROWTH = 1.35
GameConfig.BASE_INCOME_PER_SECOND = 4
GameConfig.REBIRTH_COST = 250
GameConfig.REBIRTH_GROWTH = 2
GameConfig.PLOT_SPAWN_HEIGHT = 1

function GameConfig.getGeneratorCost(generatorCount: number): number
	return math.floor(GameConfig.BASE_GENERATOR_COST * (GameConfig.COST_GROWTH ^ generatorCount) + 0.5)
end

function GameConfig.getIncomePerSecond(generatorCount: number, rebirths: number): number
	local multiplier = 1 + rebirths * 0.5
	return generatorCount * GameConfig.BASE_INCOME_PER_SECOND * multiplier
end

function GameConfig.getRebirthCost(rebirths: number): number
	return math.floor(GameConfig.REBIRTH_COST * (GameConfig.REBIRTH_GROWTH ^ rebirths))
end

return GameConfig
