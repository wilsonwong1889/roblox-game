local SecondFloorConfig = require(script.Parent.SecondFloorConfig)

local ThirdFloorConfig = {}

ThirdFloorConfig.VERSION = "live-config"
ThirdFloorConfig.SOURCE_LAYOUT = "Week 6 Third Floor Expansion"

ThirdFloorConfig.ENABLED = true
ThirdFloorConfig.UPGRADE_ID = "third_floor"
ThirdFloorConfig.UPGRADE_NAME = "Third Floor"
ThirdFloorConfig.UPGRADE_COST = 14500

ThirdFloorConfig.BASE_Y_OFFSET = SecondFloorConfig.BASE_Y_OFFSET + 26
ThirdFloorConfig.FOUNDATION_SIZE = Vector3.new(132, 2, 104)
ThirdFloorConfig.FOUNDATION_OFFSET = Vector3.new(0, ThirdFloorConfig.BASE_Y_OFFSET, 32)
ThirdFloorConfig.STAIR_WELL_SIZE = Vector3.new(28, 2, 26)
ThirdFloorConfig.STAIR_WELL_OFFSET = Vector3.new(-36, 0, 12)
ThirdFloorConfig.LANDING_SIZE = Vector3.new(24, 2, 20)
ThirdFloorConfig.LANDING_OFFSET = Vector3.new(-36, ThirdFloorConfig.BASE_Y_OFFSET + 3, 58)
ThirdFloorConfig.STAIR_SIZE = Vector3.new(12, 22, 12)
ThirdFloorConfig.STAIR_OFFSET = Vector3.new(-42, ThirdFloorConfig.BASE_Y_OFFSET - 13, 46)

ThirdFloorConfig.WALL_HEIGHT = 14
ThirdFloorConfig.WALL_THICKNESS = 2
ThirdFloorConfig.WALL_DEPTH = 2
ThirdFloorConfig.WALL_FRONT_Z = 18
ThirdFloorConfig.WALL_BACK_Z = 82
ThirdFloorConfig.WALL_LEFT_X = -60
ThirdFloorConfig.WALL_RIGHT_X = 60
ThirdFloorConfig.WALL_FRONT_LEFT_X = -38
ThirdFloorConfig.WALL_FRONT_RIGHT_X = 38
ThirdFloorConfig.BACK_WALL_WIDTH = 120
ThirdFloorConfig.SIDE_WALL_LENGTH = 64
ThirdFloorConfig.FRONT_SEGMENT_WIDTH = 28

ThirdFloorConfig.CONVEYOR_X_OFFSET = 8
ThirdFloorConfig.CONVEYOR_Z_OFFSET = 54
ThirdFloorConfig.CONVEYOR_LENGTH = 58
ThirdFloorConfig.CONVEYOR_WIDTH = 6
ThirdFloorConfig.COLLECTOR_Z_OFFSET = 84
ThirdFloorConfig.COLLECTOR_PAD_Z_OFFSET = 90
ThirdFloorConfig.COLLECTOR_PROMPT_RANGE = 12

ThirdFloorConfig.DROP_OFFSETS = {
	Vector3.new(4, 5, 28),
	Vector3.new(28, 5, 28),
	Vector3.new(4, 5, 50),
	Vector3.new(28, 5, 50),
}

ThirdFloorConfig.DROPPER_ORDER = {
	"third_dropper_1",
	"third_dropper_2",
	"third_dropper_3",
	"third_dropper_4",
}

ThirdFloorConfig.UPGRADES = {
	"third_floor",
	"third_floor_walls",
	"third_conveyor",
	"third_dropper_1",
	"third_dropper_2",
	"third_dropper_3",
	"third_dropper_4",
	"third_collector",
}

ThirdFloorConfig.UPGRADE_REQUIREMENTS = {
	third_floor = { "upper_collector" },
	third_floor_walls = { "third_floor" },
	third_conveyor = { "third_floor" },
	third_dropper_1 = { "third_conveyor" },
	third_dropper_2 = { "third_dropper_1" },
	third_dropper_3 = { "third_dropper_2" },
	third_dropper_4 = { "third_dropper_3" },
	third_collector = { "third_dropper_4", "third_floor_walls" },
}

ThirdFloorConfig.UPGRADE_OVERVIEW = {
	third_floor = {
		name = "Third Floor",
		cost = 14500,
		category = "structure",
		description = "Adds a larger top deck with a new stair flight above the upper floor.",
	},
	third_floor_walls = {
		name = "Third Floor Walls",
		cost = 3600,
		category = "structure",
		description = "Wraps the new top deck with perimeter walls and support framing.",
	},
	third_conveyor = {
		name = "Third Conveyor",
		cost = 4200,
		category = "income",
		description = "Runs a new top-floor conveyor lane across the third deck.",
	},
	third_dropper_1 = {
		name = "Third Dropper 1",
		cost = 2600,
		category = "income",
		description = "Starts the third-floor production chain.",
	},
	third_dropper_2 = {
		name = "Third Dropper 2",
		cost = 3200,
		category = "income",
		description = "Adds more top-floor output across the lane.",
	},
	third_dropper_3 = {
		name = "Third Dropper 3",
		cost = 3900,
		category = "income",
		description = "Pushes the third-floor line deeper into the rear deck.",
	},
	third_dropper_4 = {
		name = "Third Dropper 4",
		cost = 4700,
		category = "income",
		description = "Finishes the top-floor dropper row.",
	},
	third_collector = {
		name = "Third Collector",
		cost = 5600,
		category = "utility",
		description = "Completes the third-floor payout line and feeds the shared income loop.",
	},
}

ThirdFloorConfig.BUTTON_LAYOUTS = {
	third_floor = {
		offset = Vector3.new(44, SecondFloorConfig.BASE_Y_OFFSET + 1.3, 76),
	},
	third_floor_walls = {
		offset = Vector3.new(-34, ThirdFloorConfig.BASE_Y_OFFSET + 1.3, 28),
	},
	third_conveyor = {
		offset = Vector3.new(ThirdFloorConfig.CONVEYOR_X_OFFSET - 11, ThirdFloorConfig.BASE_Y_OFFSET + 1.3, ThirdFloorConfig.CONVEYOR_Z_OFFSET - 10),
	},
	third_dropper_1 = {
		offset = Vector3.new(-6, ThirdFloorConfig.BASE_Y_OFFSET + 1.3, 28),
	},
	third_dropper_2 = {
		offset = Vector3.new(34, ThirdFloorConfig.BASE_Y_OFFSET + 1.3, 28),
	},
	third_dropper_3 = {
		offset = Vector3.new(-6, ThirdFloorConfig.BASE_Y_OFFSET + 1.3, 50),
	},
	third_dropper_4 = {
		offset = Vector3.new(34, ThirdFloorConfig.BASE_Y_OFFSET + 1.3, 50),
	},
	third_collector = {
		offset = Vector3.new(ThirdFloorConfig.CONVEYOR_X_OFFSET - 11, ThirdFloorConfig.BASE_Y_OFFSET + 1.3, ThirdFloorConfig.COLLECTOR_PAD_Z_OFFSET),
	},
}

ThirdFloorConfig.DROPPERS = {
	third_dropper_1 = {
		interval = 0.58,
		value = 230,
		color = Color3.fromRGB(255, 168, 228),
		offset = ThirdFloorConfig.DROP_OFFSETS[1],
	},
	third_dropper_2 = {
		interval = 0.52,
		value = 270,
		color = Color3.fromRGB(170, 245, 255),
		offset = ThirdFloorConfig.DROP_OFFSETS[2],
	},
	third_dropper_3 = {
		interval = 0.46,
		value = 320,
		color = Color3.fromRGB(255, 220, 148),
		offset = ThirdFloorConfig.DROP_OFFSETS[3],
	},
	third_dropper_4 = {
		interval = 0.4,
		value = 380,
		color = Color3.fromRGB(208, 168, 255),
		offset = ThirdFloorConfig.DROP_OFFSETS[4],
	},
}

local function offsetFromBase(baseOrigin: Vector3 | CFrame, offset: Vector3): Vector3
	if typeof(baseOrigin) == "CFrame" then
		return (baseOrigin :: CFrame):PointToWorldSpace(offset)
	end

	return (baseOrigin :: Vector3) + offset
end

function ThirdFloorConfig.getUpgrade(upgradeId: string)
	return ThirdFloorConfig.UPGRADE_OVERVIEW[upgradeId]
end

function ThirdFloorConfig.getDropCount(): number
	return #ThirdFloorConfig.DROP_OFFSETS
end

function ThirdFloorConfig.getRequirements(upgradeId: string): { string }?
	return ThirdFloorConfig.UPGRADE_REQUIREMENTS[upgradeId]
end

function ThirdFloorConfig.getButtonLayout(upgradeId: string)
	return ThirdFloorConfig.BUTTON_LAYOUTS[upgradeId]
end

function ThirdFloorConfig.getButtonLayouts()
	return ThirdFloorConfig.BUTTON_LAYOUTS
end

function ThirdFloorConfig.getThirdFloorOrigin(baseOrigin: Vector3 | CFrame): Vector3
	return offsetFromBase(baseOrigin, ThirdFloorConfig.FOUNDATION_OFFSET)
end

function ThirdFloorConfig.getStairWellOrigin(baseOrigin: Vector3 | CFrame): Vector3
	return offsetFromBase(ThirdFloorConfig.getThirdFloorOrigin(baseOrigin), ThirdFloorConfig.STAIR_WELL_OFFSET)
end

function ThirdFloorConfig.getLandingOrigin(baseOrigin: Vector3 | CFrame): Vector3
	return offsetFromBase(baseOrigin, ThirdFloorConfig.LANDING_OFFSET)
end

function ThirdFloorConfig.getStairOrigin(baseOrigin: Vector3 | CFrame): Vector3
	return offsetFromBase(baseOrigin, ThirdFloorConfig.STAIR_OFFSET)
end

function ThirdFloorConfig.getConveyorOrigin(baseOrigin: Vector3 | CFrame): Vector3
	return offsetFromBase(baseOrigin, Vector3.new(ThirdFloorConfig.CONVEYOR_X_OFFSET, ThirdFloorConfig.BASE_Y_OFFSET + 2, ThirdFloorConfig.CONVEYOR_Z_OFFSET))
end

function ThirdFloorConfig.getCollectorOrigin(baseOrigin: Vector3 | CFrame): Vector3
	return offsetFromBase(baseOrigin, Vector3.new(ThirdFloorConfig.CONVEYOR_X_OFFSET, ThirdFloorConfig.BASE_Y_OFFSET + 2, ThirdFloorConfig.COLLECTOR_Z_OFFSET))
end

function ThirdFloorConfig.getConveyorEntryOrigin(baseOrigin: Vector3 | CFrame): Vector3
	return offsetFromBase(baseOrigin, Vector3.new(
		ThirdFloorConfig.CONVEYOR_X_OFFSET,
		ThirdFloorConfig.BASE_Y_OFFSET + 2.65,
		ThirdFloorConfig.CONVEYOR_Z_OFFSET - (ThirdFloorConfig.CONVEYOR_LENGTH / 2) + 6
	))
end

function ThirdFloorConfig.getCollectorPointOrigin(baseOrigin: Vector3 | CFrame): Vector3
	return offsetFromBase(baseOrigin, Vector3.new(
		ThirdFloorConfig.CONVEYOR_X_OFFSET,
		ThirdFloorConfig.BASE_Y_OFFSET + 3.2,
		ThirdFloorConfig.COLLECTOR_Z_OFFSET
	))
end

function ThirdFloorConfig.getDropper(upgradeId: string)
	return ThirdFloorConfig.DROPPERS[upgradeId]
end

return ThirdFloorConfig
