local SecondFloorConfig = {}

SecondFloorConfig.VERSION = "live-config"
SecondFloorConfig.SOURCE_LAYOUT = "Week 6 Larger Second Floor Expansion"

SecondFloorConfig.ENABLED = true
SecondFloorConfig.UPGRADE_ID = "second_floor"
SecondFloorConfig.UPGRADE_NAME = "Second Floor"
SecondFloorConfig.UPGRADE_COST = 8800

SecondFloorConfig.BASE_Y_OFFSET = 24
SecondFloorConfig.FOUNDATION_SIZE = Vector3.new(128, 2, 100)
SecondFloorConfig.FOUNDATION_OFFSET = Vector3.new(0, 24, 30)
SecondFloorConfig.STAIR_WELL_SIZE = Vector3.new(24, 2, 22)
SecondFloorConfig.STAIR_WELL_OFFSET = Vector3.new(34, 0, 10)
SecondFloorConfig.LANDING_SIZE = Vector3.new(20, 2, 18)
SecondFloorConfig.LANDING_OFFSET = Vector3.new(34, 27, 56)
SecondFloorConfig.STAIR_SIZE = Vector3.new(12, 22, 10)
SecondFloorConfig.STAIR_OFFSET = Vector3.new(40, 11, 42)
SecondFloorConfig.STAIR_ROTATION_DEGREES = 0

SecondFloorConfig.UPPER_WALL_HEIGHT = 16
SecondFloorConfig.UPPER_WALL_THICKNESS = 2
SecondFloorConfig.UPPER_WALL_DEPTH = 2
SecondFloorConfig.UPPER_WALL_FRONT_Z = 16
SecondFloorConfig.UPPER_WALL_BACK_Z = 80
SecondFloorConfig.UPPER_WALL_LEFT_X = -58
SecondFloorConfig.UPPER_WALL_RIGHT_X = 58
SecondFloorConfig.UPPER_WALL_FRONT_LEFT_X = -34
SecondFloorConfig.UPPER_WALL_FRONT_RIGHT_X = 34

SecondFloorConfig.UPPER_CONVEYOR_X_OFFSET = 4
SecondFloorConfig.UPPER_CONVEYOR_Z_OFFSET = 50
SecondFloorConfig.UPPER_CONVEYOR_LENGTH = 74
SecondFloorConfig.UPPER_CONVEYOR_WIDTH = 6
SecondFloorConfig.UPPER_COLLECTOR_Z_OFFSET = 80
SecondFloorConfig.UPPER_COLLECTOR_PAD_Z_OFFSET = 86
SecondFloorConfig.UPPER_COLLECTOR_PROMPT_RANGE = 12

SecondFloorConfig.UPPER_DROP_OFFSETS = {
	Vector3.new(-8, 5, 22),
	Vector3.new(18, 5, 22),
	Vector3.new(-8, 5, 44),
	Vector3.new(18, 5, 44),
}

SecondFloorConfig.UPPER_DROPPER_ORDER = {
	"upper_dropper_1",
	"upper_dropper_2",
	"upper_dropper_3",
	"upper_dropper_4",
}

SecondFloorConfig.UPPER_UPGRADES = {
	"second_floor",
	"upper_walls",
	"upper_conveyor",
	"upper_dropper_1",
	"upper_dropper_2",
	"upper_dropper_3",
	"upper_dropper_4",
	"upper_collector",
}

SecondFloorConfig.UPGRADE_REQUIREMENTS = {
	second_floor = { "collector_array", "roof_frame" },
	upper_walls = { "second_floor" },
	upper_conveyor = { "second_floor" },
	upper_dropper_1 = { "upper_conveyor" },
	upper_dropper_2 = { "upper_dropper_1" },
	upper_dropper_3 = { "upper_dropper_2" },
	upper_dropper_4 = { "upper_dropper_3" },
	upper_collector = { "upper_dropper_4", "upper_walls" },
}

SecondFloorConfig.UPGRADE_OVERVIEW = {
	second_floor = {
		name = "Second Floor",
		cost = 8800,
		category = "structure",
		description = "Adds the upper floor shell and landing.",
	},
	upper_walls = {
		name = "Upper Walls",
		cost = 2400,
		category = "structure",
		description = "Adds the perimeter walls around the upper deck.",
	},
	upper_conveyor = {
		name = "Upper Conveyor",
		cost = 3200,
		category = "income",
		description = "Creates the upper production lane.",
	},
	upper_dropper_1 = {
		name = "Upper Dropper 1",
		cost = 1100,
		category = "income",
		description = "Starts the upper-floor dropper chain.",
	},
	upper_dropper_2 = {
		name = "Upper Dropper 2",
		cost = 1500,
		category = "income",
		description = "Extends the upper-floor line across the deck.",
	},
	upper_dropper_3 = {
		name = "Upper Dropper 3",
		cost = 2100,
		category = "income",
		description = "Pushes the upper line deeper into the back wing.",
	},
	upper_dropper_4 = {
		name = "Upper Dropper 4",
		cost = 2800,
		category = "income",
		description = "Finishes the upper lane footprint.",
	},
	upper_collector = {
		name = "Upper Collector",
		cost = 4200,
		category = "utility",
		description = "Finishes the upper payout lane and feeds the shared cash flow.",
	},
	roof_frame = {
		name = "Roof Frame",
		cost = 6800,
		category = "structure",
		description = "Spans the expanded tower space above the upper floor.",
	},
}

SecondFloorConfig.UPPER_DROPPERS = {
	upper_dropper_1 = {
		interval = 0.95,
		value = 112,
		color = Color3.fromRGB(255, 238, 145),
		offset = SecondFloorConfig.UPPER_DROP_OFFSETS[1],
	},
	upper_dropper_2 = {
		interval = 0.82,
		value = 136,
		color = Color3.fromRGB(145, 226, 255),
		offset = SecondFloorConfig.UPPER_DROP_OFFSETS[2],
	},
	upper_dropper_3 = {
		interval = 0.72,
		value = 164,
		color = Color3.fromRGB(255, 174, 145),
		offset = SecondFloorConfig.UPPER_DROP_OFFSETS[3],
	},
	upper_dropper_4 = {
		interval = 0.62,
		value = 196,
		color = Color3.fromRGB(211, 145, 255),
		offset = SecondFloorConfig.UPPER_DROP_OFFSETS[4],
	},
}

local function getUpperPadY(): number
	return SecondFloorConfig.BASE_Y_OFFSET + 1.3
end

local function offsetFromBase(baseOrigin: Vector3 | CFrame, offset: Vector3): Vector3
	if typeof(baseOrigin) == "CFrame" then
		return (baseOrigin :: CFrame):PointToWorldSpace(offset)
	end

	return (baseOrigin :: Vector3) + offset
end

SecondFloorConfig.BUTTON_LAYOUTS = {
	second_floor = {
		offset = Vector3.new(48, 1.3, 72),
	},
	upper_walls = {
		offset = Vector3.new(-42, getUpperPadY(), 24),
	},
	upper_conveyor = {
		offset = Vector3.new(SecondFloorConfig.UPPER_CONVEYOR_X_OFFSET - 11, getUpperPadY(), SecondFloorConfig.UPPER_CONVEYOR_Z_OFFSET - 10),
	},
	upper_dropper_1 = {
		offset = Vector3.new(-22, getUpperPadY(), 22),
	},
	upper_dropper_2 = {
		offset = Vector3.new(30, getUpperPadY(), 22),
	},
	upper_dropper_3 = {
		offset = Vector3.new(-22, getUpperPadY(), 44),
	},
	upper_dropper_4 = {
		offset = Vector3.new(30, getUpperPadY(), 44),
	},
	upper_collector = {
		offset = Vector3.new(SecondFloorConfig.UPPER_CONVEYOR_X_OFFSET - 11, getUpperPadY(), SecondFloorConfig.UPPER_COLLECTOR_PAD_Z_OFFSET),
	},
}

function SecondFloorConfig.getUpgrade(upgradeId: string)
	return SecondFloorConfig.UPGRADE_OVERVIEW[upgradeId]
end

function SecondFloorConfig.getUpperDropCount(): number
	return #SecondFloorConfig.UPPER_DROP_OFFSETS
end

function SecondFloorConfig.getUpperFloorOrigin(baseOrigin: Vector3 | CFrame): Vector3
	return offsetFromBase(baseOrigin, SecondFloorConfig.FOUNDATION_OFFSET)
end

function SecondFloorConfig.getStairWellOrigin(baseOrigin: Vector3 | CFrame): Vector3
	local upperOrigin = SecondFloorConfig.getUpperFloorOrigin(baseOrigin)
	return offsetFromBase(upperOrigin, SecondFloorConfig.STAIR_WELL_OFFSET)
end

function SecondFloorConfig.getLandingOrigin(baseOrigin: Vector3 | CFrame): Vector3
	return offsetFromBase(baseOrigin, SecondFloorConfig.LANDING_OFFSET)
end

function SecondFloorConfig.getStairOrigin(baseOrigin: Vector3 | CFrame): Vector3
	return offsetFromBase(baseOrigin, SecondFloorConfig.STAIR_OFFSET)
end

function SecondFloorConfig.getUpperConveyorOrigin(baseOrigin: Vector3 | CFrame): Vector3
	return offsetFromBase(baseOrigin, Vector3.new(SecondFloorConfig.UPPER_CONVEYOR_X_OFFSET, SecondFloorConfig.BASE_Y_OFFSET + 2, SecondFloorConfig.UPPER_CONVEYOR_Z_OFFSET))
end

function SecondFloorConfig.getUpperCollectorOrigin(baseOrigin: Vector3 | CFrame): Vector3
	return offsetFromBase(baseOrigin, Vector3.new(SecondFloorConfig.UPPER_CONVEYOR_X_OFFSET, SecondFloorConfig.BASE_Y_OFFSET + 2, SecondFloorConfig.UPPER_COLLECTOR_Z_OFFSET))
end

function SecondFloorConfig.getUpperConveyorEntryOrigin(baseOrigin: Vector3 | CFrame): Vector3
	return offsetFromBase(baseOrigin, Vector3.new(
		SecondFloorConfig.UPPER_CONVEYOR_X_OFFSET,
		SecondFloorConfig.BASE_Y_OFFSET + 2.65,
		SecondFloorConfig.UPPER_CONVEYOR_Z_OFFSET - (SecondFloorConfig.UPPER_CONVEYOR_LENGTH / 2) + 6
	))
end

function SecondFloorConfig.getUpperCollectorPointOrigin(baseOrigin: Vector3 | CFrame): Vector3
	return offsetFromBase(baseOrigin, Vector3.new(
		SecondFloorConfig.UPPER_CONVEYOR_X_OFFSET,
		SecondFloorConfig.BASE_Y_OFFSET + 3.2,
		SecondFloorConfig.UPPER_COLLECTOR_Z_OFFSET
	))
end

function SecondFloorConfig.getRequirements(upgradeId: string): { string }?
	return SecondFloorConfig.UPGRADE_REQUIREMENTS[upgradeId]
end

function SecondFloorConfig.getUpperDropper(upgradeId: string)
	return SecondFloorConfig.UPPER_DROPPERS[upgradeId]
end

function SecondFloorConfig.getUpperButtonLayout(upgradeId: string)
	return SecondFloorConfig.BUTTON_LAYOUTS[upgradeId]
end

function SecondFloorConfig.getButtonLayouts()
	return SecondFloorConfig.BUTTON_LAYOUTS
end

return SecondFloorConfig
