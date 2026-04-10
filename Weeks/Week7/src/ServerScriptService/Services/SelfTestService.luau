local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)
local PlayerProfile = require(ReplicatedStorage.Modules.PlayerProfile)
local SecondFloorConfig = require(ReplicatedStorage.Modules.SecondFloorConfig)
local ThirdFloorConfig = require(ReplicatedStorage.Modules.ThirdFloorConfig)
local RaidService = require(script.Parent.RaidService)
local RebirthService = require(script.Parent.RebirthService)
local SaveService = require(script.Parent.SaveService)
local TycoonOwnershipRegistry = require(script.Parent.TycoonOwnershipRegistry)

local SelfTestService = {}

local function assertCondition(condition: boolean, message: string)
	if not condition then
		error("[SelfTest] " .. message, 2)
	end
end

local function testEightTycoonBaselineConfig()
	assertCondition(GameConfig.GAME_NAME == "Break-In Tycoon", "Game name should stay stable for the ring-layout baseline")
	assertCondition(type(GameConfig.WEEK_PHASE) == "string" and GameConfig.WEEK_PHASE ~= "", "Ring-layout mode should advertise a non-empty phase tag")
	assertCondition(GameConfig.ACTIVE_TYCOON_COUNT == 8, "Ring-layout mode should run on exactly 8 tycoons")
	assertCondition(GameConfig.CLAIM_TELEPORT_ON_CLAIM == false, "Players should not be teleported on claim in the current baseline")
	assertCondition(GameConfig.THIRD_FLOOR_ENABLED == true, "Third-floor expansion should be enabled in the vertical slice")
	assertCondition(typeof(GameConfig.CLAIM_PAD_OFFSET) == "Vector3", "Claim pad offset should be configured")
	assertCondition(GameConfig.CLAIM_PAD_CLAIMED_SIZE.X < GameConfig.CLAIM_PAD_UNCLAIMED_SIZE.X, "Claimed pads should be smaller than unclaimed pads")
	assertCondition(GameConfig.STARTING_CASH == 25, "Current default wallet should stay at the configured baseline value")
	assertCondition(GameConfig.PERSONAL_STARTING_CASH.iiTheDarkMagic == 100000, "Username-specific starting cash should stay configured for iiTheDarkMagic")
	assertCondition(GameConfig.VIP_STARTER_PACK.ENABLED == true, "VIP starter pack should be enabled in the current build")
	assertCondition(GameConfig.VIP_STARTER_PACK.GAMEPASS_ID == 1754764623, "VIP starter pack should use the configured pass id")
	assertCondition(GameConfig.VIP_STARTER_PACK.PRICE_ROBUX == 500, "VIP starter pack should advertise the configured Robux price")
	assertCondition(GameConfig.VIP_STARTER_PACK.CASH_BONUS > 0, "VIP starter pack should grant positive bonus cash")
	assertCondition(GameConfig.DAILY_SPIN_ENABLED == true, "Daily spin should be enabled in the current build")
	assertCondition(GameConfig.STARTING_GEMS == 0, "Gem currency should start from zero")
	assertCondition(#GameConfig.DAILY_SPIN_REWARDS == 4, "Daily spin should expose four weighted rewards")
	assertCondition(GameConfig.DAILY_SPIN_REWARDS[1].rewardType == "cash" and GameConfig.DAILY_SPIN_REWARDS[1].amount == 100 and GameConfig.DAILY_SPIN_REWARDS[1].chancePercent == 50 and GameConfig.DAILY_SPIN_REWARDS[1].displayCount == 4, "Daily spin should keep the $100 reward at 50% across four tiles")
	assertCondition(GameConfig.DAILY_SPIN_REWARDS[2].rewardType == "gems" and GameConfig.DAILY_SPIN_REWARDS[2].amount == 10 and GameConfig.DAILY_SPIN_REWARDS[2].chancePercent == 30 and GameConfig.DAILY_SPIN_REWARDS[2].displayCount == 3, "Daily spin should keep the 10 gem reward at 30% across three tiles")
	assertCondition(GameConfig.DAILY_SPIN_REWARDS[3].rewardType == "cash" and GameConfig.DAILY_SPIN_REWARDS[3].amount == 10000 and GameConfig.DAILY_SPIN_REWARDS[3].chancePercent == 10 and GameConfig.DAILY_SPIN_REWARDS[3].displayCount == 1, "Daily spin should keep the $10,000 reward at 10% across one tile")
	assertCondition(GameConfig.DAILY_SPIN_REWARDS[4].rewardType == "gems" and GameConfig.DAILY_SPIN_REWARDS[4].amount == 100 and GameConfig.DAILY_SPIN_REWARDS[4].chancePercent == 10 and GameConfig.DAILY_SPIN_REWARDS[4].displayCount == 1, "Daily spin should keep the 100 gem reward at 10% across one tile")
	assertCondition(#GameConfig.getDailySpinSlots() == 9, "Daily spin should render nine total prize tiles")
	assertCondition(GameConfig.getRedeemCode("money").reward == 500, "Redeem code money should grant 500 cash")
	assertCondition(GameConfig.getRedeemCode("  AMANDA ").reward == 5000, "Redeem code amanda should be case-insensitive and grant 5,000 cash")
	assertCondition(GameConfig.getRedeemCode("admin").reward == 100000, "Redeem code admin should grant 100,000 cash")
	assertCondition(GameConfig.getRedeemCode("rematch").reward == 10000 and GameConfig.getRedeemCode("rematch").grantsVip == true, "Redeem code rematch should grant 10,000 cash and VIP status")
	assertCondition(GameConfig.getRedeemCode("invalid") == nil, "Unknown redeem codes should resolve to nil")
	assertCondition(GameConfig.STARTING_STASH_CASH == 0, "Baseline stash cash should start empty")
	assertCondition(GameConfig.STARTING_VAULT_CASH == 0, "Baseline vault cash should start empty")
	assertCondition(GameConfig.SAVE_ENABLED == true, "Current Week 7 snapshot should keep save/load enabled")
	assertCondition(GameConfig.REBIRTH_ENABLED == true, "Current Week 7 snapshot should keep rebirth enabled")
	assertCondition(GameConfig.RAID_ENABLED == true, "Current Week 7 snapshot should keep raids enabled")
	assertCondition(GameConfig.AUTOSAVE_INTERVAL_SECONDS >= 60, "Autosave interval should stay at a practical cadence")
	assertCondition(#GameConfig.getShopOffers() >= 3, "Shop offers should stay available in the current Week 7 snapshot")
	assertCondition(type(GameConfig.BACKGROUND_MUSIC_ENABLED) == "boolean", "Background music toggle should be configured")
	assertCondition(type(GameConfig.BACKGROUND_MUSIC_SOUND_ID) == "string" and string.find(GameConfig.BACKGROUND_MUSIC_SOUND_ID, "rbxassetid://", 1, true) == 1, "Background music should use a valid rbxassetid sound id")
	assertCondition(GameConfig.BACKGROUND_MUSIC_VOLUME > 0 and GameConfig.BACKGROUND_MUSIC_VOLUME <= 1, "Background music volume should stay in a safe range")
	assertCondition(GameConfig.BASE_WALK_SPEED == 16, "Baseline walk speed should stay at 16")
	assertCondition(GameConfig.SPRINT_WALK_SPEED > GameConfig.BASE_WALK_SPEED, "Sprint speed should exceed baseline walk speed")
	assertCondition(GameConfig.DEFAULT_PLAYER_HEALTH == 100, "Default players should spawn with 100 health")
	assertCondition(GameConfig.VIP_PLAYER_HEALTH == 200, "VIP players should spawn with 200 health")
	assertCondition(GameConfig.ADMIN_PLAYER_HEALTH == 1000, "Admins should spawn with 1000 health")
	assertCondition(GameConfig.VIP_SPEED_MULTIPLIER == 1.5, "VIP players should move at 1.5x speed")
	assertCondition(GameConfig.ADMIN_SPEED_MULTIPLIER == 3, "Admins should move at 3x speed")
	assertCondition(GameConfig.getSpeedMultiplier(nil, true, false) == 1.5, "VIP speed multiplier helper should return 1.5x when VIP is forced")
	assertCondition(GameConfig.getSpeedMultiplier(nil, false, true) == 3, "Admin speed multiplier helper should return 3x when admin is forced")
	assertCondition(GameConfig.PLAYER_KILL_COIN_REWARD == 5, "Player kills should grant 5 coins")
	assertCondition(GameConfig.NPC_KILL_COIN_REWARD == 1, "NPC kills should grant 1 coin")
	assertCondition(GameConfig.COINS_PER_FREE_SPIN == 5, "Five coins should grant one free spin")
	assertCondition(GameConfig.ADMIN_USERNAMES.iiTheDarkMagic == true, "iiTheDarkMagic should stay in the admin list")
	assertCondition(GameConfig.PERSONAL_SPEED_BUFF > 0, "Personal speed buff should be positive")
	assertCondition(GameConfig.BUTTON_LANE_X_OFFSET > 0, "Eight-tycoon mode should keep the button lane separated from the factory lane")
	assertCondition(GameConfig.BUTTON_LANE_STEP_Z > 0, "Eight-tycoon mode button spacing should move downward along the lane")
	assertCondition(GameConfig.BUTTON_LANE_LENGTH >= 160, "Eight-tycoon mode should stretch the button lane for the larger upgrade list")
	assertCondition(GameConfig.WEAPON_PICKUP_PROMPT_RANGE > 0, "Armory weapon pickup prompts should have a usable range")
	assertCondition(GameConfig.BUTTON_LAYOUTS.combat_knife.offset.Z == GameConfig.BUTTON_LAYOUTS.money_blaster.offset.Z, "Armory weapon pads should share a single row")
	assertCondition(GameConfig.BUTTON_LAYOUTS.money_blaster.offset.Z == GameConfig.BUTTON_LAYOUTS.money_rpg.offset.Z, "Armory RPG pad should stay aligned with the weapon row")
	assertCondition(GameConfig.BUTTON_LAYOUTS.money_shotgun.offset.Z == GameConfig.BUTTON_LAYOUTS.money_sniper.offset.Z, "New armory weapon pads should stay aligned with the main armory row")
	assertCondition(
		GameConfig.BUTTON_LAYOUTS.combat_knife.offset.X < GameConfig.BUTTON_LAYOUTS.money_blaster.offset.X
			and GameConfig.BUTTON_LAYOUTS.money_blaster.offset.X < GameConfig.BUTTON_LAYOUTS.money_shotgun.offset.X
			and GameConfig.BUTTON_LAYOUTS.money_shotgun.offset.X < GameConfig.BUTTON_LAYOUTS.money_sniper.offset.X
			and GameConfig.BUTTON_LAYOUTS.money_sniper.offset.X < GameConfig.BUTTON_LAYOUTS.money_rpg.offset.X,
		"Armory weapon pads should be ordered left-to-right"
	)
	assertCondition(typeof(GameConfig.EARNINGS_BOARD_OFFSET) == "Vector3", "Eight-tycoon mode should define an earnings board offset")
	assertCondition(typeof(GameConfig.TYCOON_SPAWN_OFFSET) == "Vector3", "Eight-tycoon mode should define a rear-corner spawn offset")
	assertCondition(typeof(GameConfig.TYCOON_CLICKER_OFFSET) == "Vector3", "Eight-tycoon mode should define a starter clicker offset")
	assertCondition(GameConfig.TYCOON_CLICKER_OFFSET.Z < 0, "Starter dropper should sit toward the front of the tycoon")
	assertCondition(GameConfig.TYCOON_STARTER_BUTTON_OFFSET.Z < 0, "Starter dropper button should stay at the front of the tycoon")
	assertCondition(GameConfig.TYCOON_STARTER_OUTPUT_OFFSET.Z < GameConfig.TYCOON_CLICKER_OFFSET.Z, "Starter dropper output should sit in front of the starter machine")
	assertCondition(typeof(GameConfig.TYCOON_ENTRY_SENSOR_OFFSET) == "Vector3", "Eight-tycoon mode should define an outside door button offset")
	assertCondition(typeof(GameConfig.TYCOON_ENTRY_INSIDE_SENSOR_OFFSET) == "Vector3", "Eight-tycoon mode should define an inside door button offset")
	assertCondition(typeof(GameConfig.TYCOON_ENTRY_PANEL_OPEN_OFFSET) == "Vector3", "Eight-tycoon mode should define an open-door panel offset")
	assertCondition(GameConfig.TYCOON_ENTRY_PANEL_OPEN_OFFSET.Y > 0, "Door panel should move up when the door opens")
	assertCondition(GameConfig.TYCOON_ENTRY_FRAME_WIDTH > GameConfig.TYCOON_ENTRY_PANEL_WIDTH, "Door frame should be wider than the moving door panel")
	assertCondition(GameConfig.TYCOON_ENTRY_PANEL_DEPTH >= 2, "Door panel depth should match the wall thickness closely")
	local wallOpeningWidth = (GameConfig.TYCOON_WALL_FRONT_RIGHT_X - (GameConfig.TYCOON_WALL_FRONT_SEGMENT_WIDTH / 2)) - (GameConfig.TYCOON_WALL_FRONT_LEFT_X + (GameConfig.TYCOON_WALL_FRONT_SEGMENT_WIDTH / 2))
	assertCondition(GameConfig.TYCOON_ENTRY_PANEL_WIDTH >= wallOpeningWidth, "Closed door panel should span the full front-wall opening")
	assertCondition(GameConfig.TYCOON_SIZE.X > 140 and GameConfig.TYCOON_SIZE.Z > 180, "Eight-tycoon mode should enlarge the tycoon footprint")
	assertCondition(GameConfig.MAP_CENTRAL_PLAZA_SIZE.X >= 200 and GameConfig.MAP_CENTRAL_PLAZA_SIZE.Z >= 200, "Eight-tycoon mode should define a larger central plaza")
	assertCondition(GameConfig.MAP_RING_SIDE_DISTANCE > GameConfig.MAP_CENTRAL_PLAZA_SIZE.X / 2, "Tycoons should sit beyond the central plaza radius")
	assertCondition(GameConfig.MAP_RING_PAIR_SPACING > 120, "Paired tycoons on each side should keep enough separation")
	assertCondition(GameConfig.MAP_CORNER_DECORATION_INSET > 0, "Corner decoration inset should be positive")
	assertCondition(GameConfig.MAP_CENTER_DECORATION_RADIUS > 0, "Center decoration radius should be positive")
	assertCondition(GameConfig.MAP_BOUNDARY_HEIGHT >= 80, "Map boundary height should be tall enough to frame the arena")
	assertCondition(GameConfig.MAP_BOUNDARY_THICKNESS >= 6, "Map boundary thickness should stay visually substantial")
	assertCondition(GameConfig.MAP_TREE_RING_RADIUS > GameConfig.MAP_RING_SIDE_DISTANCE, "Tree ring should sit outside the tycoon ring")
	assertCondition(GameConfig.MAP_TREE_CLUSTER_COUNT >= 12, "Map should build a substantial tree belt")
	assertCondition(GameConfig.MAP_MOUNTAIN_RING_RADIUS > GameConfig.MAP_TREE_RING_RADIUS, "Mountain ring should sit outside the forest ring")
	assertCondition(GameConfig.MAP_MOUNTAIN_CLUSTER_COUNT >= 8, "Map should build multiple mountain clusters")
	assertCondition(GameConfig.PINK_SKY_ENABLED == true, "Pink sky ambience should be enabled for the current map theme")
	assertCondition(typeof(GameConfig.MAP_BOUNDARY_COLOR) == "Color3", "Boundary color should be configured")
	assertCondition(typeof(GameConfig.PINK_SKY_FOG_COLOR) == "Color3", "Pink sky fog color should be configured")
	assertCondition(GameConfig.TYCOON_CONVEYOR_X_OFFSET < -30, "Eight-tycoon mode should keep the conveyor pushed off-center")
	assertCondition(GameConfig.TYCOON_CONVEYOR_LENGTH > 72, "Eight-tycoon mode should extend the conveyor beyond the earlier footprint")
	assertCondition(GameConfig.TYCOON_ENTRY_SENSOR_OFFSET.Z < GameConfig.TYCOON_WALL_FRONT_Z, "Door button should sit outside the front wall")
	assertCondition(GameConfig.TYCOON_ENTRY_INSIDE_SENSOR_OFFSET.Z > GameConfig.TYCOON_WALL_FRONT_Z, "Inside door button should sit inside the front wall")
	assertCondition(GameConfig.TYCOON_WALL_BACK_WIDTH > 102, "Eight-tycoon mode should extend the wall width")
	assertCondition(GameConfig.TYCOON_WALL_SIDE_LENGTH > 122, "Eight-tycoon mode should extend the wall length")
	assertCondition(GameConfig.TYCOON_WALL_MAX_HEALTH == 1000, "Walls should use the configured 1000 health baseline")
	assertCondition(GameConfig.TYCOON_WALL_REPAIR_PROMPT_RANGE > 0, "Wall repair console should have a usable prompt range")
	local lowWallTop = GameConfig.TYCOON_LOW_WALL_Y_OFFSET + (GameConfig.TYCOON_LOW_WALL_HEIGHT / 2)
	local highWallBottom = GameConfig.TYCOON_HIGH_WALL_Y_OFFSET - (GameConfig.TYCOON_HIGH_WALL_HEIGHT / 2)
	assertCondition(math.abs(lowWallTop - highWallBottom) < 0.001, "High walls should sit directly on top of the low-wall shell")
	assertCondition(GameConfig.MAP_NPC_INITIAL_COUNT == 20, "Perimeter defense pass should start with twenty roaming soldiers")
	assertCondition(GameConfig.MAP_NPC_MAX_COUNT == 100, "Perimeter defense pass should cap the live soldier count at one hundred")
	assertCondition(GameConfig.MAP_NPC_SPAWN_POINT_COUNT == 20, "Perimeter defense pass should expose twenty spawn points")
	assertCondition(GameConfig.MAP_NPC_RESPAWN_INTERVAL_SECONDS == 60, "NPC soldiers should respawn every minute from the perimeter pads")
	assertCondition(GameConfig.MAP_NPC_PATROL_RADIUS > GameConfig.MAP_RING_SIDE_DISTANCE, "NPC patrol ring should sit outside the tycoon walls")
	assertCondition(GameConfig.MAP_NPC_ROAM_POINT_COUNT >= 12, "NPC roaming should expose enough patrol points for the perimeter loop")
	assertCondition(GameConfig.MAP_NPC_SPEED > 0, "NPC soldiers should have a positive roaming speed")
	assertCondition(GameConfig.MAP_NPC_KNIFE_DAMAGE == 20, "NPC knives should deal 20 damage")
	assertCondition(GameConfig.MAP_NPC_PISTOL_DAMAGE == 10, "NPC pistols should deal 10 damage")
	assertCondition(GameConfig.MAP_NPC_KNIFE_RANGE > 0 and GameConfig.MAP_NPC_PISTOL_RANGE > GameConfig.MAP_NPC_KNIFE_RANGE, "NPC weapon ranges should be configured and pistol range should exceed knife range")
	assertCondition(#GameConfig.TYCOONS == GameConfig.ACTIVE_TYCOON_COUNT, "Tycoon count should match the active eight-tycoon count")
	assertCondition(GameConfig.UPGRADES.basic_dropper ~= nil, "Baseline should include a basic dropper upgrade")
	assertCondition(GameConfig.UPGRADES.collector ~= nil, "Baseline should include a collector upgrade")
	assertCondition(GameConfig.UPGRADES.conveyor_speed ~= nil, "Baseline should include a conveyor upgrade")
	assertCondition(GameConfig.UPGRADES.second_dropper ~= nil, "Baseline should include a second dropper upgrade")
	assertCondition(GameConfig.UPGRADES.dropper_3 ~= nil, "Baseline should include dropper 3")
	assertCondition(GameConfig.UPGRADES.dropper_4 ~= nil, "Baseline should include dropper 4")
	assertCondition(GameConfig.UPGRADES.dropper_5 ~= nil, "Baseline should include dropper 5")
	assertCondition(GameConfig.UPGRADES.dropper_6 ~= nil, "Baseline should include dropper 6")
	assertCondition(GameConfig.UPGRADES.dropper_7 ~= nil, "Baseline should include dropper 7")
	assertCondition(GameConfig.UPGRADES.dropper_8 ~= nil, "Baseline should include dropper 8")
	assertCondition(GameConfig.UPGRADES.auto_collector ~= nil, "Baseline should include the auto collector")
	assertCondition(GameConfig.UPGRADES.premium_conveyor ~= nil, "Baseline should include the premium conveyor")
	assertCondition(GameConfig.UPGRADES.cash_compressor ~= nil, "Baseline should include the cash compressor")
	assertCondition(GameConfig.UPGRADES.collector_array ~= nil, "Baseline should include the collector array")
	assertCondition(GameConfig.UPGRADES.wall_set_1 ~= nil, "Baseline should include wall set 1")
	assertCondition(GameConfig.UPGRADES.front_door ~= nil, "Baseline should include the owner front door")
	assertCondition(GameConfig.UPGRADES.reinforced_door ~= nil, "Baseline should include the reinforced door")
	assertCondition(GameConfig.UPGRADES.high_walls ~= nil, "Baseline should include high walls")
	assertCondition(GameConfig.UPGRADES.security_lights ~= nil, "Baseline should include security lights")
	assertCondition(GameConfig.UPGRADES.corner_posts ~= nil, "Baseline should include corner posts")
	assertCondition(GameConfig.UPGRADES.rear_extension ~= nil, "Baseline should include the rear extension")
	assertCondition(GameConfig.UPGRADES.utility_bay ~= nil, "Baseline should include the utility bay")
	assertCondition(GameConfig.UPGRADES.armory_bay ~= nil, "Baseline should include the armory bay")
	assertCondition(GameConfig.UPGRADES.combat_knife ~= nil, "Baseline should include the combat knife")
	assertCondition(GameConfig.UPGRADES.money_blaster ~= nil, "Baseline should include the money blaster")
	assertCondition(GameConfig.UPGRADES.money_shotgun ~= nil, "Baseline should include the money shotgun")
	assertCondition(GameConfig.UPGRADES.money_sniper ~= nil, "Baseline should include the money sniper")
	assertCondition(GameConfig.UPGRADES.money_rpg ~= nil, "Baseline should include the money RPG")
	assertCondition(GameConfig.UPGRADES.roof_frame ~= nil, "Baseline should include the roof frame")
	assertCondition(GameConfig.UPGRADES.second_floor ~= nil, "Baseline should include the second floor unlock")
	assertCondition(GameConfig.UPGRADES.upper_walls ~= nil, "Baseline should include upper walls")
	assertCondition(GameConfig.UPGRADES.upper_conveyor ~= nil, "Baseline should include the upper conveyor")
	assertCondition(GameConfig.UPGRADES.upper_dropper_1 ~= nil, "Baseline should include the first upper dropper")
	assertCondition(GameConfig.UPGRADES.upper_dropper_4 ~= nil, "Baseline should include the fourth upper dropper")
	assertCondition(GameConfig.UPGRADES.upper_collector ~= nil, "Baseline should include the upper collector")
	assertCondition(GameConfig.UPGRADES.third_floor ~= nil, "Baseline should include the third floor unlock")
	assertCondition(GameConfig.UPGRADES.third_floor_walls ~= nil, "Baseline should include the third-floor wall shell")
	assertCondition(GameConfig.UPGRADES.third_conveyor ~= nil, "Baseline should include the third-floor conveyor")
	assertCondition(GameConfig.UPGRADES.third_dropper_1 ~= nil, "Baseline should include the first third-floor dropper")
	assertCondition(GameConfig.UPGRADES.third_dropper_4 ~= nil, "Baseline should include the fourth third-floor dropper")
	assertCondition(GameConfig.UPGRADES.third_collector ~= nil, "Baseline should include the third-floor collector")
	assertCondition(GameConfig.UPGRADES.developer_full_build ~= nil, "Baseline should include the developer full-build shortcut")
	assertCondition(GameConfig.DROPPERS.basic_dropper ~= nil, "Baseline should define the basic dropper timing")
	assertCondition(GameConfig.DROPPERS.second_dropper ~= nil, "Baseline should define the second dropper timing")
	assertCondition(GameConfig.DROPPERS.dropper_8 ~= nil, "Baseline should define the eighth dropper timing")
	assertCondition(#GameConfig.DROPPER_ORDER == 8, "Baseline should track eight automated droppers in order")
	assertCondition(#GameConfig.UPPER_DROPPER_ORDER == 4, "Baseline should track four upper-floor droppers separately")
	assertCondition(#GameConfig.THIRD_DROPPER_ORDER == 4, "Baseline should track four third-floor droppers separately")
	assertCondition(#GameConfig.ALL_DROPPER_ORDER == 16, "Baseline should expose all configured droppers without changing first-floor semantics")
	assertCondition(GameConfig.UPPER_DROPPERS.upper_dropper_1 ~= nil, "Baseline should expose upper dropper definitions for the next slice")
	assertCondition(GameConfig.UPPER_DROPPERS.upper_dropper_4 ~= nil, "Baseline should expose the full upper dropper chain")
	assertCondition(GameConfig.THIRD_DROPPERS.third_dropper_1 ~= nil, "Baseline should expose third-floor dropper definitions")
	assertCondition(GameConfig.THIRD_DROPPERS.third_dropper_4 ~= nil, "Baseline should expose the full third-floor dropper chain")
	assertCondition(GameConfig.getUpgrade("basic_dropper").cost == 100, "Basic dropper should cost the test value of 100")
	assertCondition(GameConfig.getUpgrade("second_dropper").cost == 220, "Second dropper should use the updated test cost")
	assertCondition(GameConfig.getUpgrade("second_floor").cost == SecondFloorConfig.UPGRADE_COST, "Second floor cost should stay sourced from the upper-floor config")
	assertCondition(GameConfig.areRequirementsMet({ basic_dropper = true }, "wall_set_1"), "Wall set 1 should unlock after the basic dropper")
	assertCondition(GameConfig.areRequirementsMet({ basic_dropper = true, wall_set_1 = true }, "front_door"), "Front door should unlock after wall set 1")
	assertCondition(GameConfig.areRequirementsMet({ basic_dropper = true, wall_set_1 = true, front_door = true, second_dropper = true }, "reinforced_door"), "Reinforced door should unlock after the front door and second dropper")
	assertCondition(GameConfig.areRequirementsMet({ basic_dropper = true, wall_set_1 = true, front_door = true, second_dropper = true, reinforced_door = true }, "high_walls"), "High walls should unlock after the reinforced door")
	assertCondition(GameConfig.areRequirementsMet({ basic_dropper = true, collector = true, conveyor_speed = true, second_dropper = true, dropper_3 = true, dropper_4 = true, dropper_5 = true, dropper_6 = true, dropper_7 = true }, "dropper_8"), "Eighth dropper should unlock after the prior droppers")
	assertCondition(GameConfig.areRequirementsMet({ basic_dropper = true, collector = true, conveyor_speed = true, second_dropper = true, dropper_3 = true, dropper_4 = true, dropper_5 = true, dropper_6 = true, dropper_7 = true, dropper_8 = true }, "auto_collector"), "Auto collector should unlock after all eight droppers")
	assertCondition(GameConfig.areRequirementsMet({ basic_dropper = true, collector = true, conveyor_speed = true, second_dropper = true, dropper_3 = true, dropper_4 = true, dropper_5 = true, dropper_6 = true, dropper_7 = true, dropper_8 = true, auto_collector = true }, "premium_conveyor"), "Premium conveyor should unlock after auto collector")
	assertCondition(GameConfig.areRequirementsMet({ basic_dropper = true, collector = true, conveyor_speed = true, second_dropper = true, dropper_3 = true, dropper_4 = true, dropper_5 = true, dropper_6 = true, dropper_7 = true, dropper_8 = true, auto_collector = true, premium_conveyor = true }, "cash_compressor"), "Cash compressor should unlock after the premium conveyor")
	assertCondition(GameConfig.areRequirementsMet({ basic_dropper = true, collector = true, conveyor_speed = true, second_dropper = true, dropper_3 = true, dropper_4 = true, dropper_5 = true, dropper_6 = true, dropper_7 = true, dropper_8 = true, auto_collector = true, premium_conveyor = true, cash_compressor = true }, "collector_array"), "Collector array should unlock after cash compressor")
	assertCondition(GameConfig.areRequirementsMet({ basic_dropper = true, wall_set_1 = true, front_door = true, second_dropper = true, reinforced_door = true, high_walls = true }, "security_lights"), "Security lights should unlock after high walls")
	assertCondition(GameConfig.areRequirementsMet({ basic_dropper = true, wall_set_1 = true, front_door = true, second_dropper = true, reinforced_door = true, high_walls = true, security_lights = true }, "corner_posts"), "Corner posts should unlock after security lights")
	assertCondition(GameConfig.areRequirementsMet({ basic_dropper = true, wall_set_1 = true, front_door = true, second_dropper = true, reinforced_door = true, high_walls = true, security_lights = true, corner_posts = true }, "rear_extension"), "Rear extension should unlock after corner posts")
	assertCondition(GameConfig.areRequirementsMet({ basic_dropper = true, wall_set_1 = true, front_door = true, second_dropper = true, reinforced_door = true, high_walls = true, security_lights = true, corner_posts = true, rear_extension = true }, "utility_bay"), "Utility bay should unlock after rear extension")
	assertCondition(GameConfig.areRequirementsMet({ basic_dropper = true, wall_set_1 = true, front_door = true, second_dropper = true, reinforced_door = true, high_walls = true, security_lights = true, corner_posts = true, rear_extension = true, utility_bay = true }, "armory_bay"), "Armory bay should unlock after the utility bay")
	assertCondition(GameConfig.areRequirementsMet({ armory_bay = true }, "combat_knife"), "Combat knife should unlock after the armory bay")
	assertCondition(GameConfig.areRequirementsMet({ armory_bay = true, cash_compressor = true }, "money_blaster"), "Money blaster should unlock after the armory bay and cash compressor")
	assertCondition(GameConfig.areRequirementsMet({ money_blaster = true }, "money_shotgun"), "Money shotgun should unlock after the money blaster")
	assertCondition(GameConfig.areRequirementsMet({ money_shotgun = true, second_floor = true }, "money_sniper"), "Money sniper should unlock after the money shotgun and second floor")
	assertCondition(GameConfig.areRequirementsMet({ money_sniper = true, second_floor = true }, "money_rpg"), "Money RPG should unlock after the money sniper and second floor")
	assertCondition(GameConfig.areRequirementsMet({ basic_dropper = true, wall_set_1 = true, front_door = true, second_dropper = true, reinforced_door = true, high_walls = true, security_lights = true, corner_posts = true, rear_extension = true, utility_bay = true }, "roof_frame"), "Roof frame should unlock after utility bay")
	assertCondition(GameConfig.areRequirementsMet({ basic_dropper = true, collector = true, conveyor_speed = true, second_dropper = true, dropper_3 = true, dropper_4 = true, dropper_5 = true, dropper_6 = true, dropper_7 = true, dropper_8 = true, auto_collector = true, premium_conveyor = true, cash_compressor = true, collector_array = true, wall_set_1 = true, front_door = true, reinforced_door = true, high_walls = true, security_lights = true, corner_posts = true, rear_extension = true, utility_bay = true, roof_frame = true }, "second_floor"), "Second floor should unlock after the full first-floor chain")
	assertCondition(GameConfig.areRequirementsMet({ second_floor = true }, "upper_walls"), "Upper walls should unlock from the second floor")
	assertCondition(GameConfig.areRequirementsMet({ second_floor = true }, "upper_conveyor"), "Upper conveyor should unlock from the second floor")
	assertCondition(GameConfig.areRequirementsMet({ upper_conveyor = true }, "upper_dropper_1"), "Upper dropper 1 should unlock from the upper conveyor")
	assertCondition(GameConfig.areRequirementsMet({ upper_dropper_1 = true }, "upper_dropper_2"), "Upper dropper 2 should unlock after upper dropper 1")
	assertCondition(GameConfig.areRequirementsMet({ upper_dropper_2 = true }, "upper_dropper_3"), "Upper dropper 3 should unlock after upper dropper 2")
	assertCondition(GameConfig.areRequirementsMet({ upper_dropper_3 = true }, "upper_dropper_4"), "Upper dropper 4 should unlock after upper dropper 3")
	assertCondition(GameConfig.areRequirementsMet({ upper_walls = true, upper_dropper_4 = true }, "upper_collector"), "Upper collector should unlock after the upper walls and final upper dropper")
	assertCondition(GameConfig.areRequirementsMet({ upper_collector = true }, "third_floor"), "Third floor should unlock after the upper collector")
	assertCondition(GameConfig.areRequirementsMet({ third_floor = true }, "third_floor_walls"), "Third-floor walls should unlock after the third floor")
	assertCondition(GameConfig.areRequirementsMet({ third_floor = true }, "third_conveyor"), "Third conveyor should unlock from the third floor")
	assertCondition(GameConfig.areRequirementsMet({ third_conveyor = true }, "third_dropper_1"), "Third dropper 1 should unlock from the third conveyor")
	assertCondition(GameConfig.areRequirementsMet({ third_dropper_1 = true }, "third_dropper_2"), "Third dropper 2 should unlock after third dropper 1")
	assertCondition(GameConfig.areRequirementsMet({ third_dropper_2 = true }, "third_dropper_3"), "Third dropper 3 should unlock after third dropper 2")
	assertCondition(GameConfig.areRequirementsMet({ third_dropper_3 = true }, "third_dropper_4"), "Third dropper 4 should unlock after third dropper 3")
	assertCondition(GameConfig.areRequirementsMet({ third_floor_walls = true, third_dropper_4 = true }, "third_collector"), "Third collector should unlock after the top-floor shell and final top-floor dropper")

	local upgradeOrder = GameConfig.UPGRADE_ORDER
	local indexById = {}
	for index, upgradeId in upgradeOrder do
		indexById[upgradeId] = index
	end

	assertCondition(indexById.wall_set_1 < indexById.front_door, "Wall set 1 should come before the front door in the upgrade lane")
	assertCondition(indexById.front_door < indexById.reinforced_door, "Front door should come before reinforced door")
	assertCondition(indexById.reinforced_door < indexById.high_walls, "Reinforced door should come before high walls")
	assertCondition(indexById.second_dropper < indexById.dropper_3, "Second dropper should come before the expanded dropper line")
	assertCondition(indexById.dropper_8 < indexById.auto_collector, "Auto collector should come after the eighth dropper")
	assertCondition(indexById.auto_collector < indexById.premium_conveyor, "Premium conveyor should come after auto collector")
	assertCondition(indexById.premium_conveyor < indexById.cash_compressor, "Cash compressor should come after premium conveyor")
	assertCondition(indexById.cash_compressor < indexById.collector_array, "Collector array should come after cash compressor")
	assertCondition(indexById.high_walls < indexById.security_lights, "Security lights should come after high walls")
	assertCondition(indexById.security_lights < indexById.corner_posts, "Corner posts should come after security lights")
	assertCondition(indexById.corner_posts < indexById.rear_extension, "Rear extension should come after corner posts")
	assertCondition(indexById.rear_extension < indexById.utility_bay, "Utility bay should come after rear extension")
	assertCondition(indexById.money_blaster < indexById.money_shotgun, "Money shotgun should come after the money blaster")
	assertCondition(indexById.money_shotgun < indexById.money_sniper, "Money sniper should come after the money shotgun")
	assertCondition(indexById.money_sniper < indexById.money_rpg, "Money RPG should come after the money sniper")
	assertCondition(indexById.utility_bay < indexById.roof_frame, "Roof frame should come after utility bay")
	assertCondition(indexById.roof_frame < indexById.second_floor, "Second floor should come after the first-floor roof frame")
	assertCondition(indexById.second_floor < indexById.upper_walls, "Upper walls should come after second floor")
	assertCondition(indexById.upper_walls < indexById.upper_conveyor, "Upper conveyor should come after upper walls")
	assertCondition(indexById.upper_conveyor < indexById.upper_dropper_1, "Upper dropper 1 should come after upper conveyor")
	assertCondition(indexById.upper_dropper_1 < indexById.upper_dropper_2, "Upper dropper 2 should come after upper dropper 1")
	assertCondition(indexById.upper_dropper_2 < indexById.upper_dropper_3, "Upper dropper 3 should come after upper dropper 2")
	assertCondition(indexById.upper_dropper_3 < indexById.upper_dropper_4, "Upper dropper 4 should come after upper dropper 3")
	assertCondition(indexById.upper_dropper_4 < indexById.upper_collector, "Upper collector should come after the upper dropper line")
	assertCondition(indexById.upper_collector < indexById.third_floor, "Third floor should come after the upper collector")
	assertCondition(indexById.third_floor < indexById.third_floor_walls, "Third-floor walls should come after the third-floor unlock")
	assertCondition(indexById.third_floor_walls < indexById.third_conveyor, "Third conveyor should come after the third-floor shell")
	assertCondition(indexById.third_conveyor < indexById.third_dropper_1, "Third dropper 1 should come after the third conveyor")
	assertCondition(indexById.third_dropper_1 < indexById.third_dropper_2, "Third dropper 2 should come after third dropper 1")
	assertCondition(indexById.third_dropper_2 < indexById.third_dropper_3, "Third dropper 3 should come after third dropper 2")
	assertCondition(indexById.third_dropper_3 < indexById.third_dropper_4, "Third dropper 4 should come after third dropper 3")
	assertCondition(indexById.third_dropper_4 < indexById.third_collector, "Third collector should come after the top-floor dropper line")
	assertCondition(indexById.third_floor_walls < indexById.developer_full_build, "Developer full-build should stay at the end of the order")
	assertCondition(indexById.developer_full_build ~= nil, "Developer full-build shortcut should appear in the upgrade order")
	assertCondition(GameConfig.getUpgrade("developer_full_build").cost == 100000, "Developer full-build shortcut should cost 100000")

	local seenTycoonIds = {}
	local sideCounts = {
		left = 0,
		right = 0,
		front = 0,
		back = 0,
	}

	for _, definition in GameConfig.TYCOONS do
		assertCondition(type(definition.Id) == "string" and definition.Id ~= "", "Tycoon definitions require a string Id")
		assertCondition(typeof(definition.Origin) == "Vector3", string.format("Tycoon %s requires a Vector3 origin", definition.Id))
		assertCondition(not seenTycoonIds[definition.Id], string.format("Duplicate tycoon id found: %s", definition.Id))
		seenTycoonIds[definition.Id] = true
		assertCondition(type(definition.MapSide) == "string", string.format("Tycoon %s should expose a ring map side", definition.Id))
		assertCondition(type(definition.FacingYaw) == "number", string.format("Tycoon %s should expose a facing yaw", definition.Id))
		assertCondition(sideCounts[definition.MapSide] ~= nil, string.format("Tycoon %s should use a valid ring side", definition.Id))
		sideCounts[definition.MapSide] += 1

		if definition.MapSide == "left" then
			assertCondition(definition.Origin.X < 0, string.format("Tycoon %s should live on the left side of the map", definition.Id))
			assertCondition(math.abs(definition.Origin.X + GameConfig.MAP_RING_SIDE_DISTANCE) < 0.001, string.format("Tycoon %s should use the configured left-side distance", definition.Id))
			assertCondition(math.abs(math.abs(definition.Origin.Z) - (GameConfig.MAP_RING_PAIR_SPACING / 2)) < 0.001, string.format("Tycoon %s should use the left-side pair spacing", definition.Id))
			assertCondition(definition.FacingYaw == -90, string.format("Tycoon %s should face inward from the left side", definition.Id))
		elseif definition.MapSide == "right" then
			assertCondition(definition.Origin.X > 0, string.format("Tycoon %s should live on the right side of the map", definition.Id))
			assertCondition(math.abs(definition.Origin.X - GameConfig.MAP_RING_SIDE_DISTANCE) < 0.001, string.format("Tycoon %s should use the configured right-side distance", definition.Id))
			assertCondition(math.abs(math.abs(definition.Origin.Z) - (GameConfig.MAP_RING_PAIR_SPACING / 2)) < 0.001, string.format("Tycoon %s should use the right-side pair spacing", definition.Id))
			assertCondition(definition.FacingYaw == 90, string.format("Tycoon %s should face inward from the right side", definition.Id))
		elseif definition.MapSide == "front" then
			assertCondition(definition.Origin.Z < 0, string.format("Tycoon %s should live on the front side of the map", definition.Id))
			assertCondition(math.abs(definition.Origin.Z + GameConfig.MAP_RING_SIDE_DISTANCE) < 0.001, string.format("Tycoon %s should use the configured front-side distance", definition.Id))
			assertCondition(math.abs(math.abs(definition.Origin.X) - (GameConfig.MAP_RING_PAIR_SPACING / 2)) < 0.001, string.format("Tycoon %s should use the front-side pair spacing", definition.Id))
			assertCondition(math.abs(definition.FacingYaw) == 180, string.format("Tycoon %s should face inward from the front side", definition.Id))
		elseif definition.MapSide == "back" then
			assertCondition(definition.Origin.Z > 0, string.format("Tycoon %s should live on the back side of the map", definition.Id))
			assertCondition(math.abs(definition.Origin.Z - GameConfig.MAP_RING_SIDE_DISTANCE) < 0.001, string.format("Tycoon %s should use the configured back-side distance", definition.Id))
			assertCondition(math.abs(math.abs(definition.Origin.X) - (GameConfig.MAP_RING_PAIR_SPACING / 2)) < 0.001, string.format("Tycoon %s should use the back-side pair spacing", definition.Id))
			assertCondition(definition.FacingYaw == 0, string.format("Tycoon %s should face inward from the back side", definition.Id))
		end
	end

	assertCondition(sideCounts.left == 2, "Ring layout should place two tycoons on the left side")
	assertCondition(sideCounts.right == 2, "Ring layout should place two tycoons on the right side")
	assertCondition(sideCounts.front == 2, "Ring layout should place two tycoons on the front side")
	assertCondition(sideCounts.back == 2, "Ring layout should place two tycoons on the back side")
end

local function testLoadedProfileState()
	local fakePlayer = {
		UserId = 808,
		Name = "LoadedTester",
		DisplayName = "LoadedTester",
	} :: any

	PlayerProfile.createProfile(fakePlayer, {
		WalletCash = 1234,
		StashCash = 10,
		VaultCash = 20,
		Gems = 45,
		CollectorStoredCash = 30,
		TotalEarned = 99999,
		Kills = 4,
		Coins = 2,
		FreeSpins = 3,
		PurchasedUpgrades = {
			basic_dropper = true,
			second_floor = true,
		},
		RedeemedCodes = {
			money = true,
		},
		VipStatus = true,
		RebirthCount = 2,
		DailySpinClaimKey = "2026-077",
		DailySpinLastReward = 10,
		DailySpinLastRewardName = "10 Gems",
		DailySpinLastRewardType = "gems",
	})

	local payload = PlayerProfile.getStatePayload(fakePlayer)
	assertCondition(payload.walletCash == 1234, "Loaded profiles should restore wallet cash")
	assertCondition(payload.gems == 45, "Loaded profiles should restore gems")
	assertCondition(payload.kills == 4, "Loaded profiles should restore kills")
	assertCondition(payload.freeSpins == 3, "Loaded profiles should restore free spins")
	assertCondition(payload.rebirthCount == 2, "Loaded profiles should restore rebirth count")
	assertCondition(payload.isVip == true, "Loaded profiles should restore VIP status")
	assertCondition(PlayerProfile.hasRedeemedCode(fakePlayer, "money"), "Loaded profiles should restore redeemed codes")
	PlayerProfile.removeProfile(fakePlayer)
end

local function testSaveServiceSchema()
	local identity = {
		UserId = 909,
		Name = "SaveTester",
		DisplayName = "SaveTester",
	}

	local defaultRecord = SaveService.buildDefaultRecord(identity)
	assertCondition(defaultRecord.Kills == 0 and defaultRecord.Coins == 0 and defaultRecord.FreeSpins == 0 and defaultRecord.Gems == 0, "Default save records should include modern combat/spin/gem fields")
	assertCondition(defaultRecord.RebirthCount == 0, "Default save records should include rebirth count")

	local serialized = SaveService.serializeProfile({
		UserId = 909,
		Name = "SaveTester",
		DisplayName = "SaveTester",
		TycoonId = "TycoonA",
		WalletCash = 222,
		StashCash = 11,
		VaultCash = 13,
		Gems = 77,
		CollectorStoredCash = 17,
		TotalEarned = 2000,
		Kills = 3,
		Coins = 4,
		FreeSpins = 5,
		PurchasedUpgrades = {
			basic_dropper = true,
			third_floor = true,
		},
		RedeemedCodes = {
			money = true,
		},
		VipStatus = true,
		RebirthCount = 2,
		DailySpinClaimKey = "2026-077",
		DailySpinLastReward = 100,
		DailySpinLastRewardName = "100 Gems",
		DailySpinLastRewardType = "gems",
	})
	assertCondition(serialized.RedeemedCodes.money == true, "Serialized save records should include redeemed codes")
	assertCondition(serialized.RebirthCount == 2, "Serialized save records should include rebirth count")

	local restored = SaveService.deserializeProfile(serialized, identity)
	assertCondition(restored.WalletCash == 222 and restored.Kills == 3 and restored.Gems == 77, "Deserialized records should round-trip numeric fields")
	assertCondition(restored.VipStatus == true and restored.RebirthCount == 2, "Deserialized records should round-trip VIP and rebirth fields")
end

local function testRebirthServiceHelpers()
	local plan = RebirthService.getResetPlan({
		tycoonId = "TycoonA",
		totalEarned = 1_250_000,
		rebirthCount = 1,
		purchasedUpgrades = {
			roof_frame = true,
		},
	})

	assertCondition(plan.canRebirth == true, "Rebirth plan should allow rebirth once requirements are met")
	assertCondition(plan.unlocks.newStarterCash > 0, "Rebirth plan should grant positive starter cash")
	assertCondition(plan.payoutMultiplier > 1, "Rebirth plan should raise the payout multiplier after prestige")
end

local function testRaidServiceHelpers()
	local session = RaidService.createSession("TycoonA", 1, 0, 1000)
	session.window, _ = RaidService.openWindow(session.window, 100, GameConfig.RAID_WINDOW_SECONDS)
	local validation = RaidService.validateAntiGriefAction(session, 2, "breach_door", 101)
	assertCondition(validation.allowed == true, "Raid validation should allow breach attempts during an open window")

	session.door, validation = RaidService.recordBreachAttempt(session.door, 2, 101)
	assertCondition(validation.allowed == true and session.door.breached == true, "Raid breach state should record successful breaches")

	local theftValidation = RaidService.validateAntiGriefAction(session, 2, "steal_cash", 102)
	assertCondition(theftValidation.allowed == true, "Raid validation should allow theft after a successful breach")

	local nextLedger, stolen = RaidService.recordTheft(session.theft, 600)
	assertCondition(stolen > 0 and nextLedger.stolen == stolen, "Raid theft should spend from the theft ledger")
end

local function testSecondFloorConfig()
	assertCondition(SecondFloorConfig.ENABLED == true, "Second-floor config should now be live-enabled")
	assertCondition(SecondFloorConfig.VERSION == "live-config", "Second-floor config should advertise the live config version")
	assertCondition(SecondFloorConfig.FOUNDATION_SIZE.X >= 120 and SecondFloorConfig.FOUNDATION_SIZE.Z >= 96, "Second-floor deck should be larger in the vertical slice")
	assertCondition(SecondFloorConfig.getUpgrade("second_floor") ~= nil, "Second-floor config should expose the floor upgrade definition")
	assertCondition(SecondFloorConfig.getUpgrade("upper_collector") ~= nil, "Second-floor config should expose the upper collector definition")
	assertCondition(SecondFloorConfig.getRequirements("second_floor") ~= nil, "Second-floor config should expose second-floor requirements")
	assertCondition(SecondFloorConfig.getRequirements("upper_dropper_4") ~= nil, "Second-floor config should expose upper dropper requirements")
	assertCondition(SecondFloorConfig.getUpperDropCount() == 4, "Second-floor config should still define four upper droppers")
	assertCondition(SecondFloorConfig.UPPER_CONVEYOR_X_OFFSET < SecondFloorConfig.STAIR_OFFSET.X - 18, "Upper conveyor should stay clear of the stair lane")
	assertCondition(SecondFloorConfig.getUpperDropper("upper_dropper_1") ~= nil, "Second-floor config should expose upper dropper runtime definitions")
	assertCondition(SecondFloorConfig.getUpperButtonLayout("upper_dropper_4") ~= nil, "Second-floor config should expose upper button layouts")
	assertCondition(typeof(SecondFloorConfig.getUpperConveyorOrigin(Vector3.zero)) == "Vector3", "Second-floor config should calculate upper conveyor origins")
	assertCondition(typeof(SecondFloorConfig.getUpperCollectorOrigin(Vector3.zero)) == "Vector3", "Second-floor config should calculate upper collector origins")
end

local function testThirdFloorConfig()
	assertCondition(ThirdFloorConfig.ENABLED == true, "Third-floor config should be enabled for the current slice")
	assertCondition(ThirdFloorConfig.VERSION == "live-config", "Third-floor config should advertise the live config version")
	assertCondition(ThirdFloorConfig.FOUNDATION_SIZE.X > 100 and ThirdFloorConfig.FOUNDATION_SIZE.Z > 70, "Third-floor config should define a real top deck footprint")
	assertCondition(ThirdFloorConfig.getUpgrade("third_floor") ~= nil, "Third-floor config should expose the floor unlock")
	assertCondition(ThirdFloorConfig.getUpgrade("third_floor_walls") ~= nil, "Third-floor config should expose the wall upgrade")
	assertCondition(ThirdFloorConfig.getUpgrade("third_conveyor") ~= nil, "Third-floor config should expose the conveyor upgrade")
	assertCondition(ThirdFloorConfig.getUpgrade("third_collector") ~= nil, "Third-floor config should expose the collector upgrade")
	assertCondition(ThirdFloorConfig.getRequirements("third_floor") ~= nil, "Third-floor config should expose unlock requirements")
	assertCondition(ThirdFloorConfig.getRequirements("third_floor_walls") ~= nil, "Third-floor config should expose wall requirements")
	assertCondition(ThirdFloorConfig.getRequirements("third_dropper_4") ~= nil, "Third-floor config should expose top-floor dropper requirements")
	assertCondition(ThirdFloorConfig.getButtonLayout("third_floor") ~= nil, "Third-floor config should expose button layouts")
	assertCondition(ThirdFloorConfig.getButtonLayout("third_dropper_4") ~= nil, "Third-floor config should expose top-floor button layouts")
	assertCondition(ThirdFloorConfig.getDropCount() == 4, "Third-floor config should define four top-floor droppers")
	assertCondition(ThirdFloorConfig.CONVEYOR_X_OFFSET > ThirdFloorConfig.STAIR_OFFSET.X + 20, "Third-floor conveyor should stay clear of the stair lane")
	assertCondition(ThirdFloorConfig.getDropper("third_dropper_1") ~= nil, "Third-floor config should expose top-floor dropper definitions")
	assertCondition(typeof(ThirdFloorConfig.getThirdFloorOrigin(Vector3.zero)) == "Vector3", "Third-floor config should calculate deck origins")
	assertCondition(typeof(ThirdFloorConfig.getLandingOrigin(Vector3.zero)) == "Vector3", "Third-floor config should calculate landing origins")
	assertCondition(typeof(ThirdFloorConfig.getConveyorOrigin(Vector3.zero)) == "Vector3", "Third-floor config should calculate conveyor origins")
	assertCondition(typeof(ThirdFloorConfig.getCollectorOrigin(Vector3.zero)) == "Vector3", "Third-floor config should calculate collector origins")
end

local function testDefaultProfileState()
	local fakePlayer = {
		UserId = 101,
		Name = "WeekOneTester",
		DisplayName = "WeekOneTester",
	} :: any

	local profile = PlayerProfile.createProfile(fakePlayer)
	assertCondition(profile.TycoonId == nil, "New baseline profiles should not start with a claimed tycoon")
	assertCondition(profile.WalletCash == GameConfig.getStartingCash(fakePlayer), "Wallet cash should start from config")
	assertCondition(profile.StashCash == 0, "Stash should start at zero")
	assertCondition(profile.VaultCash == 0, "Vault should start at zero")
	assertCondition(profile.Gems == GameConfig.STARTING_GEMS, "Gems should start from config")

	local statePayload = PlayerProfile.getStatePayload(fakePlayer)
	assertCondition(statePayload ~= nil, "Baseline state payload should exist for active players")
	assertCondition(statePayload.tycoonId == nil, "Baseline state payload should show no tycoon before claim")
	assertCondition(statePayload.clickerCashPerTap == GameConfig.DROPPERS.basic_dropper.value, "State payload should surface the starter clicker payout")

	PlayerProfile.setTycoonId(fakePlayer, "TycoonA")
	local claimedPayload = PlayerProfile.getStatePayload(fakePlayer)
	assertCondition(claimedPayload.tycoonId == "TycoonA", "Baseline state payload should reflect claimed tycoon")
	assertCondition(claimedPayload.purchasedUpgrades.clicker == true, "Starter clicker should be available after claiming")
	assertCondition(claimedPayload.kills == 0, "New state payloads should start with zero kills")

	PlayerProfile.clearTycoonId(fakePlayer)
	local clearedPayload = PlayerProfile.getStatePayload(fakePlayer)
	assertCondition(clearedPayload.tycoonId == nil, "Baseline state payload should clear tycoon ownership")

	PlayerProfile.removeProfile(fakePlayer)
end

local function testConfigHelpers()
	local purchased = {
		basic_dropper = true,
	}

	assertCondition(GameConfig.getUpgrade("basic_dropper").name == "Basic Dropper", "Upgrade lookup should return the basic dropper definition")
	assertCondition(GameConfig.getUpgrade("second_dropper").cost == 220, "Upgrade lookup should return the second dropper definition")
	assertCondition(GameConfig.getUpgrade("upper_dropper_4").cost == SecondFloorConfig.getUpgrade("upper_dropper_4").cost, "Upgrade lookup should return upper-floor definitions")
	assertCondition(GameConfig.areRequirementsMet(purchased, "collector"), "Collector should be available after the basic dropper")
	assertCondition(GameConfig.areRequirementsMet(purchased, "conveyor_speed"), "Conveyor speed should be available after the basic dropper")
	assertCondition(not GameConfig.areRequirementsMet(purchased, "second_dropper"), "Second dropper should still require more prerequisites")

	purchased.collector = true
	purchased.conveyor_speed = true
	assertCondition(GameConfig.areRequirementsMet(purchased, "second_dropper"), "Second dropper should unlock after all requirements are met")
	purchased.second_dropper = true
	purchased.dropper_3 = true
	purchased.dropper_4 = true
	purchased.dropper_5 = true
	purchased.dropper_6 = true
	purchased.dropper_7 = true
	purchased.dropper_8 = true
	purchased.auto_collector = true
	assertCondition(GameConfig.areRequirementsMet(purchased, "premium_conveyor"), "Premium conveyor should unlock from the utility chain")
	purchased.premium_conveyor = true
	assertCondition(GameConfig.areRequirementsMet(purchased, "cash_compressor"), "Cash compressor should unlock after the premium conveyor")
	purchased.cash_compressor = true
	assertCondition(GameConfig.areRequirementsMet(purchased, "collector_array"), "Collector array should unlock after the cash compressor")
	assertCondition(not GameConfig.areRequirementsMet(purchased, "second_floor"), "Second floor should stay locked until the structure chain is complete")
	purchased.wall_set_1 = true
	purchased.front_door = true
	purchased.reinforced_door = true
	purchased.high_walls = true
	purchased.security_lights = true
	purchased.corner_posts = true
	purchased.rear_extension = true
	purchased.utility_bay = true
	purchased.roof_frame = true
	assertCondition(GameConfig.areRequirementsMet(purchased, "second_floor"), "Second floor should unlock after the late first-floor chain")
	assertCondition(GameConfig.isUpperFloorUpgrade("upper_dropper_1"), "Upper-floor helper should identify upper-floor upgrades")
	assertCondition(not GameConfig.isUpperFloorUpgrade("dropper_8"), "Upper-floor helper should not misclassify first-floor droppers")
	assertCondition(GameConfig.isThirdFloorUpgrade("third_dropper_1"), "Third-floor helper should identify top-floor upgrades")
	assertCondition(not GameConfig.isThirdFloorUpgrade("upper_dropper_4"), "Third-floor helper should not misclassify upper-floor upgrades")
	assertCondition(#GameConfig.getUpperDropperIds() == 4, "Upper-floor helper should return four upper droppers")
	assertCondition(#GameConfig.getThirdDropperIds() == 4, "Third-floor helper should return four top-floor droppers")
	assertCondition(#GameConfig.getAllDropperIds() == 16, "Configured dropper helper should return first-floor, upper-floor, and top-floor droppers")
	assertCondition(GameConfig.getConfiguredDropper("upper_dropper_2") ~= nil, "Configured dropper helper should surface upper-floor droppers")
	assertCondition(GameConfig.getConfiguredDropper("third_dropper_2") ~= nil, "Configured dropper helper should surface third-floor droppers")
	assertCondition(#GameConfig.getWeaponUpgradeIds() == 5, "Weapon helper should return the full armory chain")
	assertCondition(GameConfig.getStartingCash({ Name = "iiTheDarkMagic" }) == 100000, "Configured username should receive the personal starting cash override")
	assertCondition(GameConfig.getStartingCash({ Name = "SomeoneElse" }) == GameConfig.STARTING_CASH, "Unlisted players should receive the baseline starting cash")

	local buffPlayer = {
		Name = "wilso",
		DisplayName = "Wilson",
	}
	local adminPlayer = {
		Name = "iiTheDarkMagic",
		DisplayName = "iiTheDarkMagic",
	}
	local normalPlayer = {
		Name = "SomeoneElse",
		DisplayName = "SomeoneElse",
	}

	assertCondition(GameConfig.hasPersonalSpeedBuff(buffPlayer), "Configured dev player should receive the personal speed buff")
	assertCondition(not GameConfig.hasPersonalSpeedBuff(normalPlayer), "Unlisted players should not receive the personal speed buff")
	assertCondition(GameConfig.getWalkSpeed(buffPlayer, false) > GameConfig.getWalkSpeed(normalPlayer, false), "Personal buff should raise walk speed")
	assertCondition(GameConfig.getWalkSpeed(buffPlayer, true) > GameConfig.getWalkSpeed(buffPlayer, false), "Sprint speed should exceed buffed walk speed")
	assertCondition(GameConfig.hasAdminStatus(adminPlayer), "Configured admin should resolve through the admin helper")
	assertCondition(not GameConfig.hasAdminStatus(normalPlayer), "Unlisted players should not resolve as admins")
	assertCondition(GameConfig.getMaxHealth(adminPlayer) == 1000, "Admins should receive the configured admin health")
	assertCondition(GameConfig.getMaxHealth(normalPlayer) == 100, "Regular players should receive the default health")
end

local function testEarningsAssumptions()
	local basicDropper = GameConfig.DROPPERS.basic_dropper
	local secondDropper = GameConfig.DROPPERS.second_dropper
	local basicEps = basicDropper.value / basicDropper.interval
	local secondEps = secondDropper.value / secondDropper.interval

	assertCondition(basicEps > 0, "Basic dropper should have positive earnings per second")
	assertCondition(secondEps > basicEps, "Second dropper should outperform the basic dropper")
	assertCondition((basicEps + secondEps) > secondEps, "Combined earnings should exceed a single dropper")
end

local function testEarningsPayload()
	local fakePlayer = {
		UserId = 303,
		Name = "EarningsTester",
		DisplayName = "EarningsTester",
	} :: any
	local basicDropper = GameConfig.DROPPERS.basic_dropper
	local secondDropper = GameConfig.DROPPERS.second_dropper

	PlayerProfile.createProfile(fakePlayer)
	PlayerProfile.markUpgradePurchased(fakePlayer, "basic_dropper")
	PlayerProfile.markUpgradePurchased(fakePlayer, "second_dropper")
	PlayerProfile.markUpgradePurchased(fakePlayer, "conveyor_speed")
	PlayerProfile.markUpgradePurchased(fakePlayer, "premium_conveyor")
	PlayerProfile.markUpgradePurchased(fakePlayer, "cash_compressor")
	PlayerProfile.markUpgradePurchased(fakePlayer, "collector_array")

	local expectedEps = GameConfig.getEarningsPerSecondForUpgrades(PlayerProfile.getProfile(fakePlayer).PurchasedUpgrades)
	assertCondition(math.abs(PlayerProfile.getEarningsPerSecond(fakePlayer) - expectedEps) < 0.001, "Earnings per second should reflect dropper values and conveyor speed")

	local payload = PlayerProfile.getStatePayload(fakePlayer)
	assertCondition(payload.earningsPerSecond ~= nil, "State payload should surface earnings per second")
	assertCondition(math.abs(payload.earningsPerSecond - expectedEps) < 0.001, "State payload EPS should match the profile helper")
	assertCondition(payload.earningsPerSecondText == string.format("$%.1f/sec", expectedEps), "State payload should expose a formatted EPS label")
	assertCondition(payload.purchasedUpgrades.front_door ~= true, "Earnings payload should not invent later upgrades")
	assertCondition(GameConfig.getDropperPayoutValue("basic_dropper", PlayerProfile.getProfile(fakePlayer).PurchasedUpgrades) > basicDropper.value, "Utility upgrades should raise crate payout values")

	PlayerProfile.removeProfile(fakePlayer)
end

local function testEconomyProfileHelpers()
	local fakePlayer = {
		UserId = 202,
		Name = "EconomyTester",
		DisplayName = "EconomyTester",
	} :: any

	PlayerProfile.createProfile(fakePlayer)

	assertCondition(PlayerProfile.trySpendCash(fakePlayer, 150) == false, "Players should not overspend their wallet")
	assertCondition(PlayerProfile.trySpendCash(fakePlayer, 50) == true, "Players should be able to spend from their starting cash")
	PlayerProfile.addWalletCash(fakePlayer, 25)
	PlayerProfile.setWalletCash(fakePlayer, 125)
	PlayerProfile.setStashCash(fakePlayer, 15)
	PlayerProfile.addStashCash(fakePlayer, 10)
	PlayerProfile.setVaultCash(fakePlayer, 30)
	PlayerProfile.addVaultCash(fakePlayer, 5)
	PlayerProfile.setCollectorStored(fakePlayer, 20)
	PlayerProfile.addCollectorStored(fakePlayer, 15)
	PlayerProfile.markUpgradePurchased(fakePlayer, "basic_dropper")
	PlayerProfile.markUpgradePurchased(fakePlayer, "collector")

	assertCondition(PlayerProfile.hasUpgrade(fakePlayer, "basic_dropper"), "Upgrade tracking should mark basic dropper as purchased")
	assertCondition(PlayerProfile.getUpgradeCount(fakePlayer) == 2, "Upgrade count should reflect purchased upgrades")
	assertCondition(PlayerProfile.collectStoredCash(fakePlayer) == 35, "Collecting stored cash should return the stored amount")

	local profile = PlayerProfile.getProfile(fakePlayer)
	assertCondition(profile ~= nil, "Economy profile should still exist after collection")
	assertCondition(profile.WalletCash == 160, "Wallet should increase when stored cash is collected")
	assertCondition(profile.CollectorStoredCash == 0, "Collector storage should reset after collection")
	assertCondition(profile.TotalEarned == 60, "Total earned should only reflect earned cash, not starting cash")

	local payload = PlayerProfile.getStatePayload(fakePlayer)
	assertCondition(payload.totalEarned == 60, "State payload should surface total earned for the HUD")
	assertCondition(payload.kills == 0, "Economy helpers should not alter kills")

	PlayerProfile.removeProfile(fakePlayer)
end

local function testVipStarterPackProfileHelpers()
	local fakePlayer = {
		UserId = 404,
		Name = "VipTester",
		DisplayName = "VipTester",
	} :: any

	PlayerProfile.createProfile(fakePlayer)
	assertCondition(not PlayerProfile.hasVipStarterPack(fakePlayer), "Profiles should not start with VIP ownership marked")
	assertCondition(not PlayerProfile.hasReceivedVipStarterPack(fakePlayer), "Profiles should not start with VIP grants marked")

	PlayerProfile.setVipStarterPackOwned(fakePlayer, true)
	PlayerProfile.markVipStarterPackGranted(fakePlayer)

	local payload = PlayerProfile.getStatePayload(fakePlayer)
	assertCondition(PlayerProfile.hasVipStarterPack(fakePlayer), "VIP ownership helper should reflect stored ownership")
	assertCondition(PlayerProfile.hasReceivedVipStarterPack(fakePlayer), "VIP grant helper should reflect the session grant")
	assertCondition(payload.vipStarterPackOwned == true, "State payload should surface VIP ownership")
	assertCondition(payload.vipStarterPackGranted == true, "State payload should surface VIP grant state")

	PlayerProfile.removeProfile(fakePlayer)
end

local function testDailySpinProfileHelpers()
	local fakePlayer = {
		UserId = 505,
		Name = "DailySpinTester",
		DisplayName = "DailySpinTester",
	} :: any

	PlayerProfile.createProfile(fakePlayer)
	local initialPayload = PlayerProfile.getStatePayload(fakePlayer)
	assertCondition(initialPayload.dailySpinEnabled == true, "Daily spin should surface as enabled in the HUD payload")
	assertCondition(initialPayload.dailySpinClaimedToday == false, "Fresh profiles should not start with the daily spin claimed")
	assertCondition(#initialPayload.dailySpinSlots == 9, "HUD payload should include the nine visible daily spin slots")
	assertCondition(initialPayload.coins == 0 and initialPayload.freeSpins == 0 and initialPayload.gems == 0, "Fresh profiles should not start with combat coins, free spins, or gems")
	assertCondition(PlayerProfile.canUseDailySpin(fakePlayer, "2026-077") == true, "Fresh profiles should be eligible for the daily spin")

	PlayerProfile.markDailySpinClaimed(fakePlayer, "2026-077", 10, "gems", "10 Gems")
	assertCondition(PlayerProfile.canUseDailySpin(fakePlayer, "2026-077") == false, "Claimed profiles should not be eligible for the same day key")
	assertCondition(PlayerProfile.getDailySpinLastReward(fakePlayer) == 10, "Daily spin should remember the last reward amount")
	assertCondition(PlayerProfile.getStatePayload(fakePlayer).dailySpinLastRewardName == "10 Gems", "Daily spin should remember the last reward display name")

	PlayerProfile.removeProfile(fakePlayer)
end

local function testRedeemCodeProfileHelpers()
	local fakePlayer = {
		UserId = 606,
		Name = "RedeemTester",
		DisplayName = "RedeemTester",
	} :: any

	PlayerProfile.createProfile(fakePlayer)
	assertCondition(not PlayerProfile.hasRedeemedCode(fakePlayer, "money"), "Fresh profiles should not start with redeemed codes")
	assertCondition(PlayerProfile.hasVipStatus(fakePlayer) == false, "Fresh profiles should not start with VIP status")
	PlayerProfile.markCodeRedeemed(fakePlayer, "money")
	PlayerProfile.setVipStatus(fakePlayer, true)
	assertCondition(PlayerProfile.hasRedeemedCode(fakePlayer, "money"), "Redeemed codes should be tracked on the profile")
	assertCondition(PlayerProfile.hasVipStatus(fakePlayer) == true, "VIP status helper should track redeemed VIP state")
	assertCondition(not PlayerProfile.hasRedeemedCode(fakePlayer, "amanda"), "Code tracking should remain per code")
	PlayerProfile.removeProfile(fakePlayer)
	PlayerProfile.createProfile(fakePlayer)
	assertCondition(PlayerProfile.hasRedeemedCode(fakePlayer, "money"), "Redeemed codes should remain blocked for the rest of the server session")
	assertCondition(PlayerProfile.hasVipStatus(fakePlayer) == true, "VIP status should remain active for the rest of the server session")
	PlayerProfile.removeProfile(fakePlayer)
end

local function testKillProfileHelpers()
	local fakePlayer = {
		UserId = 707,
		Name = "KillTester",
		DisplayName = "KillTester",
	} :: any

	PlayerProfile.createProfile(fakePlayer)
	assertCondition(PlayerProfile.getKills(fakePlayer) == 0, "Fresh profiles should start with zero kills")
	assertCondition(PlayerProfile.addKill(fakePlayer, 1) == 1, "Kill helper should increment by one")
	assertCondition(PlayerProfile.addKill(fakePlayer, 2) == 3, "Kill helper should support larger increments")
	assertCondition(PlayerProfile.getStatePayload(fakePlayer).kills == 3, "State payload should surface the tracked kill count")
	local coins, freeSpins, grantedSpins = PlayerProfile.addCoins(fakePlayer, 4)
	assertCondition(coins == 4 and freeSpins == 0 and grantedSpins == 0, "Coin helper should track coin fragments before the free spin threshold")
	coins, freeSpins, grantedSpins = PlayerProfile.addCoins(fakePlayer, 1)
	assertCondition(coins == 0 and freeSpins == 1 and grantedSpins == 1, "Five total coins should grant one free spin")
	assertCondition(PlayerProfile.tryUseFreeSpin(fakePlayer) == true, "Available free spins should be consumable")
	assertCondition(PlayerProfile.getFreeSpins(fakePlayer) == 0, "Free spin usage should decrement the tracked balance")
	PlayerProfile.addGems(fakePlayer, 25)
	assertCondition(PlayerProfile.getGems(fakePlayer) == 25, "Gem helper should track gem rewards")
	PlayerProfile.removeProfile(fakePlayer)
end

local function testOwnershipRegistry()
	local registry = TycoonOwnershipRegistry.new()
	local playerA = { UserId = 111, Name = "PlayerA" } :: any
	local playerB = { UserId = 222, Name = "PlayerB" } :: any

	assertCondition(TycoonOwnershipRegistry.claim(registry, playerA, "TycoonA"), "Player A should claim TycoonA")
	assertCondition(not TycoonOwnershipRegistry.claim(registry, playerA, "TycoonB"), "One player should not own two tycoons")
	assertCondition(not TycoonOwnershipRegistry.claim(registry, playerB, "TycoonA"), "A claimed tycoon should not be stealable")
	assertCondition(TycoonOwnershipRegistry.releasePlayer(registry, playerA) == "TycoonA", "Releasing Player A should free TycoonA")
	assertCondition(TycoonOwnershipRegistry.claim(registry, playerB, "TycoonA"), "Freed tycoons should become claimable")
end

local function testRemoteContracts()
	local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
	assertCondition(remotesFolder ~= nil and remotesFolder:IsA("Folder"), "Remotes folder should exist before UI boot")

	local expected = {
		StateUpdate = "RemoteEvent",
		UiMessage = "RemoteEvent",
		RequestState = "RemoteFunction",
		RequestDailySpin = "RemoteFunction",
		RequestCodeRedeem = "RemoteFunction",
		RequestRebirth = "RemoteFunction",
		PromptVipStarterPackPurchase = "RemoteEvent",
		SprintStateChanged = "RemoteEvent",
		WeaponFire = "RemoteEvent",
	}

	for name, className in expected do
		local instance = remotesFolder and remotesFolder:FindFirstChild(name)
		assertCondition(instance ~= nil and instance.ClassName == className, string.format("Remote contract %s should exist as %s", name, className))
	end
end

function SelfTestService.run()
	testEightTycoonBaselineConfig()
	testSecondFloorConfig()
	testThirdFloorConfig()
	testConfigHelpers()
	testEarningsAssumptions()
	testEarningsPayload()
	testDefaultProfileState()
	testLoadedProfileState()
	testEconomyProfileHelpers()
	testVipStarterPackProfileHelpers()
	testDailySpinProfileHelpers()
	testRedeemCodeProfileHelpers()
	testKillProfileHelpers()
	testSaveServiceSchema()
	testRebirthServiceHelpers()
	testRaidServiceHelpers()
	testOwnershipRegistry()
	testRemoteContracts()
	print("[SelfTest] Week 7 checks passed")
end

return SelfTestService
