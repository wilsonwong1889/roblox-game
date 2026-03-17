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

local function testWeek1Config()
	assertCondition(GameConfig.GAME_STAGE == "Week 1 Foundation", "Game stage should match Week 1")
	assertCondition(GameConfig.ACTIVE_TYCOON_COUNT == 2, "Week 1 should define exactly 2 active tycoons")
	assertCondition(GameConfig.CLAIM_TELEPORT_ON_CLAIM == false, "Players should not be teleported on claim in Week 1")
	assertCondition(#GameConfig.TYCOONS == GameConfig.ACTIVE_TYCOON_COUNT, "Tycoon count should match the active Week 1 count")

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
	assertCondition(profile.TycoonId == nil, "New Week 1 profiles should not start with a claimed tycoon")
	assertCondition(profile.WalletCash == GameConfig.STARTING_CASH, "Week 1 wallet cash should start from config")
	assertCondition(profile.StashCash == 0, "Week 1 stash should start at zero")
	assertCondition(profile.VaultCash == 0, "Week 1 vault should start at zero")

	local statePayload = PlayerProfile.getStatePayload(fakePlayer)
	assertCondition(statePayload ~= nil, "Week 1 state payload should exist for active players")
	assertCondition(statePayload.tycoonId == nil, "Week 1 state payload should show no tycoon before claim")

	PlayerProfile.setTycoonId(fakePlayer, "TycoonA")
	local claimedPayload = PlayerProfile.getStatePayload(fakePlayer)
	assertCondition(claimedPayload.tycoonId == "TycoonA", "Week 1 state payload should reflect claimed tycoon")

	PlayerProfile.clearTycoonId(fakePlayer)
	local clearedPayload = PlayerProfile.getStatePayload(fakePlayer)
	assertCondition(clearedPayload.tycoonId == nil, "Week 1 state payload should clear tycoon ownership")

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
	testWeek1Config()
	testDefaultProfileState()
	testOwnershipRegistry()
	print("[SelfTest] Week 1 tests passed")
end

return SelfTestService
