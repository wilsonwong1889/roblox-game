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

local function testWeek2Config()
	assertCondition(GameConfig.GAME_NAME == "Break-In Tycoon", "Game name should stay stable for Week 2")
	assertCondition(GameConfig.WEEK_PHASE == "Week 2 Economy", "Week 2 should advertise the active economy phase")
	assertCondition(GameConfig.ACTIVE_TYCOON_COUNT == 2, "Week 2 should still run on exactly 2 tycoons")
	assertCondition(GameConfig.CLAIM_TELEPORT_ON_CLAIM == false, "Players should not be teleported on claim in the Week 2 baseline")
	assertCondition(GameConfig.STARTING_CASH == 100, "Week 2 baseline should start with the intended validation cash")
	assertCondition(GameConfig.STARTING_STASH_CASH == 0, "Week 2 baseline should start stash cash empty")
	assertCondition(GameConfig.STARTING_VAULT_CASH == 0, "Week 2 baseline should start vault cash empty")
	assertCondition(#GameConfig.TYCOONS == GameConfig.ACTIVE_TYCOON_COUNT, "Tycoon count should match the active Week 2 count")
	assertCondition(GameConfig.UPGRADES.basic_dropper ~= nil, "Week 2 should include a basic dropper upgrade")
	assertCondition(GameConfig.UPGRADES.collector ~= nil, "Week 2 should include a collector upgrade")
	assertCondition(GameConfig.UPGRADES.conveyor_speed ~= nil, "Week 2 should include a conveyor upgrade")
	assertCondition(GameConfig.UPGRADES.second_dropper ~= nil, "Week 2 should include a second dropper upgrade")
	assertCondition(GameConfig.DROPPERS.basic_dropper ~= nil, "Week 2 should define the basic dropper timing")
	assertCondition(GameConfig.DROPPERS.second_dropper ~= nil, "Week 2 should define the second dropper timing")

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
	assertCondition(profile.TycoonId == nil, "New Week 2 profiles should not start with a claimed tycoon")
	assertCondition(profile.WalletCash == GameConfig.STARTING_CASH, "Week 2 wallet cash should start from config")
	assertCondition(profile.StashCash == 0, "Week 2 stash should start at zero")
	assertCondition(profile.VaultCash == 0, "Week 2 vault should start at zero")

	local statePayload = PlayerProfile.getStatePayload(fakePlayer)
	assertCondition(statePayload ~= nil, "Week 2 state payload should exist for active players")
	assertCondition(statePayload.tycoonId == nil, "Week 2 state payload should show no tycoon before claim")

	PlayerProfile.setTycoonId(fakePlayer, "TycoonA")
	local claimedPayload = PlayerProfile.getStatePayload(fakePlayer)
	assertCondition(claimedPayload.tycoonId == "TycoonA", "Week 2 state payload should reflect claimed tycoon")

	PlayerProfile.clearTycoonId(fakePlayer)
	local clearedPayload = PlayerProfile.getStatePayload(fakePlayer)
	assertCondition(clearedPayload.tycoonId == nil, "Week 2 state payload should clear tycoon ownership")

	PlayerProfile.removeProfile(fakePlayer)
end

local function testConfigHelpers()
	local purchased = {
		basic_dropper = true,
	}

	assertCondition(GameConfig.getUpgrade("basic_dropper").name == "Basic Dropper", "Upgrade lookup should return the basic dropper definition")
	assertCondition(GameConfig.getUpgrade("second_dropper").cost == 140, "Upgrade lookup should return the second dropper definition")
	assertCondition(GameConfig.areRequirementsMet(purchased, "collector"), "Collector should be available after the basic dropper")
	assertCondition(GameConfig.areRequirementsMet(purchased, "conveyor_speed"), "Conveyor speed should be available after the basic dropper")
	assertCondition(not GameConfig.areRequirementsMet(purchased, "second_dropper"), "Second dropper should still require more prerequisites")

	purchased.collector = true
	purchased.conveyor_speed = true
	assertCondition(GameConfig.areRequirementsMet(purchased, "second_dropper"), "Second dropper should unlock after all requirements are met")
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
	testWeek2Config()
	testConfigHelpers()
	testDefaultProfileState()
	testEconomyProfileHelpers()
	testOwnershipRegistry()
	print("[SelfTest] Week 2 checks passed")
end

return SelfTestService
