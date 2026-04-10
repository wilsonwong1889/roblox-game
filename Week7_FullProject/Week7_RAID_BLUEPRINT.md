# Week 7 Raid Blueprint

Week 7 is the security and break-in layer for the existing 2-player tycoon.

The current runtime already has:

- owner-only tycoon ownership
- a visible front door with open/close behavior
- outside and inside door buttons for the owner
- a larger first-floor shell with walls and conveyor/collector lanes

This blueprint defines how raid/security should layer onto that model without wiring it into gameplay yet.

## Goal

Add a controlled raid system where a second player can interact with a base only during a permitted raid window, with strict theft caps and anti-grief checks.

The raid layer should feel like:

- deliberate
- time-limited
- server-authoritative
- hard to exploit

## Core Rules

- The owner controls when a raid window opens.
- The door can only be breached during an active raid window.
- Theft must be capped per raid window.
- Owners cannot raid their own tycoon.
- All breach and theft validation stays on the server.
- The system should fail closed if state is missing or invalid.

## Data Model

The pure `RaidService` scaffold should track:

- `RaidWindow`
- `DoorBreachState`
- `TheftLedger`
- `RaidSession`

The main concepts are:

- raid window open or closed
- door locked or breached
- breach count and cooldown
- theft cap and stolen amount

## Layering Onto The Current Base

The current model has the right anchors for a future raid pass:

- front door frame and door panel
- outside owner door button
- inside owner door button
- wall shell and corner support pieces
- collector lane and utility lane

That means the raid layer should extend the doorway and wall flow, not replace it.

## Recommended Integration Points

- `RaidService` should be the policy layer for raid state and validation.
- `MainServer.server.luau` should eventually own the live event wiring.
- `Tycoon.luau` should only expose the physical door, wall, and collector anchors.
- `PlayerProfile.luau` should eventually store raid-related progression if the feature persists.
- `GameConfig.luau` should eventually define raid durations, caps, and cooldowns.

## Anti-Grief Rules

The raid layer should reject:

- owner self-raids
- breach spam outside cooldown
- theft after cap is reached
- theft before the door is breached
- attempts during a closed window
- stale actions from disconnected or mismatched players

The scaffold should keep these as pure validation checks so they can be tested without running the game.

## Suggested Future Flow

1. Owner opens a raid window.
2. Door changes state to allow breach.
3. Raider breaches door within the allowed window.
4. Raider steals cash up to the per-window cap.
5. Window closes and the door locks again.

## Unresolved Integration Points

- how raid windows are triggered in UI
- whether the owner manually starts raids or uses a queued system
- whether the door breach is visual only or also changes collision
- whether theft comes from wallet cash, collector cash, or both
- whether raids affect one tycoon or both tycoons in a match
- whether raid progress persists across respawns

## Validation Targets

The future implementation should be testable for:

- window open/close correctness
- breach cooldown enforcement
- theft cap enforcement
- owner-only restrictions
- anti-grief rejection reasons
- safe behavior when session state is missing

## Current Status

This is scaffold-only.
It is intentionally not wired into live gameplay yet.
