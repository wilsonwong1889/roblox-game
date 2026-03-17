local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)
local PlayerProfile = require(ReplicatedStorage.Modules.PlayerProfile)
local TycoonOwnershipRegistry = require(script.Parent.TycoonOwnershipRegistry)

local SelfTestService = {}

local function assertCondition(condition: boolean, message: string)
	if not condition then
		error("[SelfTest] " .. message, 2)
	end
end

local function testWeek4BaselineConfig()
	assertCondition(GameConfig.GAME_NAME == "Break-In Tycoon", "Game name should stay stable for the Week 4 baseline")
	assertCondition(type(GameConfig.WEEK_PHASE) == "string" and GameConfig.WEEK_PHASE ~= "", "Week 4 should advertise a non-empty phase tag")
	assertCondition(GameConfig.ACTIVE_TYCOON_COUNT == 2, "Week 4 should still run on exactly 2 tycoons")
	assertCondition(GameConfig.CLAIM_TELEPORT_ON_CLAIM == false, "Players should not be teleported on claim in the current baseline")
	assertCondition(typeof(GameConfig.CLAIM_PAD_OFFSET) == "Vector3", "Claim pad offset should be configured")
	assertCondition(GameConfig.CLAIM_PAD_CLAIMED_SIZE.X < GameConfig.CLAIM_PAD_UNCLAIMED_SIZE.X, "Claimed pads should be smaller than unclaimed pads")
	assertCondition(GameConfig.STARTING_CASH == 200000, "Current validation wallet should stay at the configured test value")
	assertCondition(GameConfig.STARTING_STASH_CASH == 0, "Baseline stash cash should start empty")
	assertCondition(GameConfig.STARTING_VAULT_CASH == 0, "Baseline vault cash should start empty")
	assertCondition(type(GameConfig.BACKGROUND_MUSIC_ENABLED) == "boolean", "Background music toggle should be configured")
	assertCondition(type(GameConfig.BACKGROUND_MUSIC_SOUND_ID) == "string" and string.find(GameConfig.BACKGROUND_MUSIC_SOUND_ID, "rbxassetid://", 1, true) == 1, "Background music should use a valid rbxassetid sound id")
	assertCondition(GameConfig.BACKGROUND_MUSIC_VOLUME > 0 and GameConfig.BACKGROUND_MUSIC_VOLUME <= 1, "Background music volume should stay in a safe range")
	assertCondition(GameConfig.BASE_WALK_SPEED == 16, "Baseline walk speed should stay at 16")
	assertCondition(GameConfig.SPRINT_WALK_SPEED > GameConfig.BASE_WALK_SPEED, "Sprint speed should exceed baseline walk speed")
	assertCondition(GameConfig.PERSONAL_SPEED_BUFF > 0, "Personal speed buff should be positive")
	assertCondition(GameConfig.BUTTON_LANE_X_OFFSET > 0, "Week 4 should keep the button lane separated from the factory lane")
	assertCondition(GameConfig.BUTTON_LANE_STEP_Z > 0, "Week 4 button spacing should move downward along the lane")
	assertCondition(GameConfig.BUTTON_LANE_LENGTH >= 160, "Week 4 should stretch the button lane for the larger upgrade list")
	assertCondition(typeof(GameConfig.EARNINGS_BOARD_OFFSET) == "Vector3", "Week 4 should define an earnings board offset")
	assertCondition(typeof(GameConfig.TYCOON_SPAWN_OFFSET) == "Vector3", "Week 4 should define a rear-corner spawn offset")
	assertCondition(typeof(GameConfig.TYCOON_CLICKER_OFFSET) == "Vector3", "Week 4 should define a starter clicker offset")
	assertCondition(typeof(GameConfig.TYCOON_ENTRY_SENSOR_OFFSET) == "Vector3", "Week 4 should define an outside door button offset")
	assertCondition(typeof(GameConfig.TYCOON_ENTRY_INSIDE_SENSOR_OFFSET) == "Vector3", "Week 4 should define an inside door button offset")
	assertCondition(GameConfig.TYCOON_ENTRY_FRAME_WIDTH > GameConfig.TYCOON_ENTRY_PANEL_WIDTH, "Door frame should be wider than the moving door panel")
	assertCondition(GameConfig.TYCOON_SIZE.X > 100 and GameConfig.TYCOON_SIZE.Z > 100, "Week 4 should enlarge the tycoon footprint")
	assertCondition(GameConfig.TYCOON_CONVEYOR_X_OFFSET < -30, "Week 4 should keep the conveyor pushed off-center")
	assertCondition(GameConfig.TYCOON_CONVEYOR_LENGTH > 72, "Week 4 should extend the conveyor beyond the earlier footprint")
	assertCondition(GameConfig.TYCOON_ENTRY_SENSOR_OFFSET.Z < GameConfig.TYCOON_WALL_FRONT_Z, "Door button should sit outside the front wall")
	assertCondition(GameConfig.TYCOON_ENTRY_INSIDE_SENSOR_OFFSET.Z > GameConfig.TYCOON_WALL_FRONT_Z, "Inside door button should sit inside the front wall")
	assertCondition(GameConfig.TYCOON_WALL_BACK_WIDTH > 102, "Week 4 should extend the wall width")
	assertCondition(GameConfig.TYCOON_WALL_SIDE_LENGTH > 122, "Week 4 should extend the wall length")
	assertCondition(#GameConfig.TYCOONS == GameConfig.ACTIVE_TYCOON_COUNT, "Tycoon count should match the active baseline count")
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
	assertCondition(GameConfig.UPGRADES.roof_frame ~= nil, "Baseline should include the roof frame")
	assertCondition(GameConfig.UPGRADES.developer_full_build ~= nil, "Baseline should include the developer full-build shortcut")
	assertCondition(GameConfig.DROPPERS.basic_dropper ~= nil, "Baseline should define the basic dropper timing")
	assertCondition(GameConfig.DROPPERS.second_dropper ~= nil, "Baseline should define the second dropper timing")
	assertCondition(GameConfig.DROPPERS.dropper_8 ~= nil, "Baseline should define the eighth dropper timing")
	assertCondition(#GameConfig.DROPPER_ORDER == 8, "Baseline should track eight automated droppers in order")
	assertCondition(GameConfig.getUpgrade("basic_dropper").cost == 100, "Basic dropper should cost the test value of 100")
	assertCondition(GameConfig.getUpgrade("second_dropper").cost == 220, "Second dropper should use the updated test cost")
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
	assertCondition(GameConfig.areRequirementsMet({ basic_dropper = true, wall_set_1 = true, front_door = true, second_dropper = true, reinforced_door = true, high_walls = true, security_lights = true, corner_posts = true, rear_extension = true, utility_bay = true }, "roof_frame"), "Roof frame should unlock after utility bay")

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
	assertCondition(indexById.utility_bay < indexById.roof_frame, "Roof frame should come after utility bay")
	assertCondition(indexById.developer_full_build ~= nil, "Developer full-build shortcut should appear in the upgrade order")
	assertCondition(GameConfig.getUpgrade("developer_full_build").cost == 100000, "Developer full-build shortcut should cost 100000")

	local seenTycoonIds = {}
	for _, definition in GameConfig.TYCOONS do
		assertCondition(type(definition.Id) == "string" and definition.Id ~= "", "Tycoon definitions require a string Id")
		assertCondition(typeof(definition.Origin) == "Vector3", string.format("Tycoon %s requires a Vector3 origin", definition.Id))
		assertCondition(not seenTycoonIds[definition.Id], string.format("Duplicate tycoon id found: %s", definition.Id))
		seenTycoonIds[definition.Id] = true
	end
end

local function testDefaultProfileState()
	local fakePlayer = {
		UserId = 101,
		Name = "WeekOneTester",
		DisplayName = "WeekOneTester",
	} :: any

	local profile = PlayerProfile.createProfile(fakePlayer)
	assertCondition(profile.TycoonId == nil, "New baseline profiles should not start with a claimed tycoon")
	assertCondition(profile.WalletCash == GameConfig.STARTING_CASH, "Wallet cash should start from config")
	assertCondition(profile.StashCash == 0, "Stash should start at zero")
	assertCondition(profile.VaultCash == 0, "Vault should start at zero")

	local statePayload = PlayerProfile.getStatePayload(fakePlayer)
	assertCondition(statePayload ~= nil, "Baseline state payload should exist for active players")
	assertCondition(statePayload.tycoonId == nil, "Baseline state payload should show no tycoon before claim")
	assertCondition(statePayload.clickerCashPerTap == GameConfig.DROPPERS.basic_dropper.value, "State payload should surface the starter clicker payout")

	PlayerProfile.setTycoonId(fakePlayer, "TycoonA")
	local claimedPayload = PlayerProfile.getStatePayload(fakePlayer)
	assertCondition(claimedPayload.tycoonId == "TycoonA", "Baseline state payload should reflect claimed tycoon")
	assertCondition(claimedPayload.purchasedUpgrades.clicker == true, "Starter clicker should be available after claiming")

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

	local buffPlayer = {
		Name = "wilso",
		DisplayName = "Wilson",
	}
	local normalPlayer = {
		Name = "SomeoneElse",
		DisplayName = "SomeoneElse",
	}

	assertCondition(GameConfig.hasPersonalSpeedBuff(buffPlayer), "Configured dev player should receive the personal speed buff")
	assertCondition(not GameConfig.hasPersonalSpeedBuff(normalPlayer), "Unlisted players should not receive the personal speed buff")
	assertCondition(GameConfig.getWalkSpeed(buffPlayer, false) > GameConfig.getWalkSpeed(normalPlayer, false), "Personal buff should raise walk speed")
	assertCondition(GameConfig.getWalkSpeed(buffPlayer, true) > GameConfig.getWalkSpeed(buffPlayer, false), "Sprint speed should exceed buffed walk speed")
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

function SelfTestService.run()
	testWeek4BaselineConfig()
	testConfigHelpers()
	testEarningsAssumptions()
	testEarningsPayload()
	testDefaultProfileState()
	testEconomyProfileHelpers()
	testOwnershipRegistry()
	print("[SelfTest] Week 4 baseline checks passed")
end

return SelfTestService
