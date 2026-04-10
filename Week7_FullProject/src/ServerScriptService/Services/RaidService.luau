local RaidService = {}

export type RaidWindow = {
	enabled: boolean,
	open: boolean,
	ownerUserId: number?,
	targetTycoonId: string?,
	openedAt: number?,
	closesAt: number?,
}

export type DoorBreachState = {
	locked: boolean,
	breached: boolean,
	attackerUserId: number?,
	targetTycoonId: string?,
	lastBreachAt: number?,
	breachCount: number,
	maxBreaches: number,
	breachCooldownSeconds: number,
}

export type TheftLedger = {
	stolen: number,
	cap: number,
	maxPerPull: number,
}

export type RaidSession = {
	window: RaidWindow,
	door: DoorBreachState,
	theft: TheftLedger,
}

export type ValidationResult = {
	allowed: boolean,
	reason: string?,
}

RaidService.DEFAULT_RAID_WINDOW_SECONDS = 180
RaidService.DEFAULT_BREACH_COOLDOWN_SECONDS = 20
RaidService.DEFAULT_THEFT_CAP_MULTIPLIER = 0.25
RaidService.DEFAULT_MAX_BREACHES = 3
RaidService.DEFAULT_MAX_THEFT_PER_PULL = 750

local function cloneWindow(window: RaidWindow): RaidWindow
	return {
		enabled = window.enabled,
		open = window.open,
		ownerUserId = window.ownerUserId,
		targetTycoonId = window.targetTycoonId,
		openedAt = window.openedAt,
		closesAt = window.closesAt,
	}
end

local function cloneDoorState(doorState: DoorBreachState): DoorBreachState
	return {
		locked = doorState.locked,
		breached = doorState.breached,
		attackerUserId = doorState.attackerUserId,
		targetTycoonId = doorState.targetTycoonId,
		lastBreachAt = doorState.lastBreachAt,
		breachCount = doorState.breachCount,
		maxBreaches = doorState.maxBreaches,
		breachCooldownSeconds = doorState.breachCooldownSeconds,
	}
end

local function cloneLedger(ledger: TheftLedger): TheftLedger
	return {
		stolen = ledger.stolen,
		cap = ledger.cap,
		maxPerPull = ledger.maxPerPull,
	}
end

function RaidService.createWindow(targetTycoonId: string, ownerUserId: number?, now: number?, durationSeconds: number?): RaidWindow
	local openedAt = now or 0
	local duration = durationSeconds or RaidService.DEFAULT_RAID_WINDOW_SECONDS

	return {
		enabled = true,
		open = false,
		ownerUserId = ownerUserId,
		targetTycoonId = targetTycoonId,
		openedAt = nil,
		closesAt = openedAt + duration,
	}
end

function RaidService.createDoorBreachState(targetTycoonId: string): DoorBreachState
	return {
		locked = true,
		breached = false,
		attackerUserId = nil,
		targetTycoonId = targetTycoonId,
		lastBreachAt = nil,
		breachCount = 0,
		maxBreaches = RaidService.DEFAULT_MAX_BREACHES,
		breachCooldownSeconds = RaidService.DEFAULT_BREACH_COOLDOWN_SECONDS,
	}
end

function RaidService.createTheftLedger(theftCap: number?, maxPerPull: number?): TheftLedger
	return {
		stolen = 0,
		cap = theftCap or 0,
		maxPerPull = maxPerPull or RaidService.DEFAULT_MAX_THEFT_PER_PULL,
	}
end

function RaidService.createSession(targetTycoonId: string, ownerUserId: number?, now: number?, theftCap: number?): RaidSession
	local window = RaidService.createWindow(targetTycoonId, ownerUserId, now)
	local door = RaidService.createDoorBreachState(targetTycoonId)
	local theft = RaidService.createTheftLedger(theftCap)

	return {
		window = window,
		door = door,
		theft = theft,
	}
end

function RaidService.computeTheftCap(baseStoredCash: number, multiplier: number?): number
	local effectiveMultiplier = multiplier or RaidService.DEFAULT_THEFT_CAP_MULTIPLIER
	if baseStoredCash <= 0 then
		return 0
	end

	return math.max(0, math.floor(baseStoredCash * effectiveMultiplier + 0.5))
end

function RaidService.isWindowActive(window: RaidWindow, now: number): boolean
	if not window.enabled then
		return false
	end

	if not window.open then
		return false
	end

	if window.closesAt and now > window.closesAt then
		return false
	end

	return true
end

function RaidService.getWindowRemainingSeconds(window: RaidWindow, now: number): number
	if not RaidService.isWindowActive(window, now) or not window.closesAt then
		return 0
	end

	return math.max(0, math.floor((window.closesAt - now) + 0.5))
end

function RaidService.openWindow(window: RaidWindow, now: number, durationSeconds: number?): (RaidWindow, ValidationResult)
	if not window.enabled then
		return cloneWindow(window), { allowed = false, reason = "Raid windows are disabled." }
	end

	local nextWindow = cloneWindow(window)
	local duration = durationSeconds or RaidService.DEFAULT_RAID_WINDOW_SECONDS
	nextWindow.open = true
	nextWindow.openedAt = now
	nextWindow.closesAt = now + duration
	return nextWindow, { allowed = true }
end

function RaidService.closeWindow(window: RaidWindow): RaidWindow
	local nextWindow = cloneWindow(window)
	nextWindow.open = false
	nextWindow.openedAt = nil
	nextWindow.closesAt = nil
	return nextWindow
end

function RaidService.setDoorLocked(doorState: DoorBreachState, locked: boolean): DoorBreachState
	local nextDoor = cloneDoorState(doorState)
	nextDoor.locked = locked
	if locked then
		nextDoor.breached = false
	end
	return nextDoor
end

function RaidService.recordBreachAttempt(doorState: DoorBreachState, attackerUserId: number, now: number): (DoorBreachState, ValidationResult)
	local nextDoor = cloneDoorState(doorState)

	if nextDoor.breachCount >= nextDoor.maxBreaches then
		return nextDoor, { allowed = false, reason = "This door has already been breached too many times this raid." }
	end

	if nextDoor.lastBreachAt and (now - nextDoor.lastBreachAt) < nextDoor.breachCooldownSeconds then
		return nextDoor, { allowed = false, reason = "Door breach is on cooldown." }
	end

	nextDoor.breached = true
	nextDoor.locked = false
	nextDoor.attackerUserId = attackerUserId
	nextDoor.lastBreachAt = now
	nextDoor.breachCount += 1
	return nextDoor, { allowed = true }
end

function RaidService.canPlayerBreachDoor(session: RaidSession, playerUserId: number, now: number): ValidationResult
	if not session.window.enabled then
		return { allowed = false, reason = "Raid system is disabled." }
	end

	if not RaidService.isWindowActive(session.window, now) then
		return { allowed = false, reason = "Raid window is closed." }
	end

	if session.window.ownerUserId and session.window.ownerUserId == playerUserId then
		return { allowed = false, reason = "Owners cannot breach their own door." }
	end

	if not session.door.locked then
		return { allowed = true }
	end

	if session.door.breachCount >= session.door.maxBreaches then
		return { allowed = false, reason = "Door breach cap reached." }
	end

	return { allowed = true }
end

function RaidService.recordTheft(ledger: TheftLedger, requestedAmount: number): (TheftLedger, number)
	local nextLedger = cloneLedger(ledger)
	if requestedAmount <= 0 then
		return nextLedger, 0
	end

	local remainingCap = math.max(0, nextLedger.cap - nextLedger.stolen)
	local cappedAmount = math.min(requestedAmount, remainingCap, nextLedger.maxPerPull)
	if cappedAmount <= 0 then
		return nextLedger, 0
	end

	nextLedger.stolen += cappedAmount
	return nextLedger, cappedAmount
end

function RaidService.getRemainingTheftBudget(ledger: TheftLedger): number
	return math.max(0, ledger.cap - ledger.stolen)
end

function RaidService.validateAntiGriefAction(
	session: RaidSession,
	playerUserId: number,
	actionName: string,
	now: number
): ValidationResult
	if actionName == "open_window" then
		if session.window.ownerUserId ~= playerUserId then
			return { allowed = false, reason = "Only the owner can open the raid window." }
		end

		if session.window.open then
			return { allowed = false, reason = "Raid window is already open." }
		end

		return { allowed = true }
	end

	if actionName == "breach_door" then
		return RaidService.canPlayerBreachDoor(session, playerUserId, now)
	end

	if actionName == "steal_cash" then
		if not RaidService.isWindowActive(session.window, now) then
			return { allowed = false, reason = "Raid window is closed." }
		end

		if session.door.locked then
			return { allowed = false, reason = "Door must be breached before theft." }
		end

		if session.door.attackerUserId ~= playerUserId then
			return { allowed = false, reason = "Only the active raider can steal cash." }
		end

		if RaidService.getRemainingTheftBudget(session.theft) <= 0 then
			return { allowed = false, reason = "Theft cap reached." }
		end

		return { allowed = true }
	end

	return { allowed = false, reason = "Unknown raid action." }
end

function RaidService.summarizeSession(session: RaidSession, now: number)
	return {
		windowOpen = RaidService.isWindowActive(session.window, now),
		windowRemainingSeconds = RaidService.getWindowRemainingSeconds(session.window, now),
		doorLocked = session.door.locked,
		doorBreached = session.door.breached,
		breachCount = session.door.breachCount,
		theftCap = session.theft.cap,
		theftStolen = session.theft.stolen,
		theftRemaining = RaidService.getRemainingTheftBudget(session.theft),
	}
end

return RaidService
