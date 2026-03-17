# Next Features Tracker

This file tracks the next major feature wave being prepared in parallel.

## Active Tracks

1. Second floor
Status:
- Live and integrated in the current runtime
- Upper-floor build path, pads, droppers, visuals, and HUD state are active
Responsible output:
- `src/ReplicatedStorage/Modules/SecondFloorConfig.luau`
- `Week5_SECOND_FLOOR_BLUEPRINT.md`

Integration target:
- `src/ReplicatedStorage/Modules/GameConfig.luau`
- `src/ServerScriptService/Services/Tycoon.luau`
- `src/ServerScriptService/MainServer.server.luau`
- `src/StarterGui/MainClient.client.luau`

Key live concerns:
- Keep upper-floor upgrades visually connected to the current first-floor footprint
- Avoid blocking movement on the first floor
- Extend the current pad-based upgrade pattern instead of reintroducing a long button lane
- Validate upper-floor crate pathing and collision feel in Studio

2. Save/load
Responsible output:
- `src/ServerScriptService/Services/SaveService.luau`
- `Week5_SAVELOAD_BLUEPRINT.md`

Integration target:
- `src/ReplicatedStorage/Modules/PlayerProfile.luau`
- `src/ServerScriptService/MainServer.server.luau`

Key live concerns:
- Serialize current wallet, collector, total earned, purchased upgrades, and future multipliers safely
- Do not double-award stored money on load
- Make Studio-safe behavior explicit

3. Rebirth
Responsible output:
- `src/ServerScriptService/Services/RebirthService.luau`
- `Week6_REBIRTH_BLUEPRINT.md`

Integration target:
- `src/ReplicatedStorage/Modules/PlayerProfile.luau`
- `src/ServerScriptService/MainServer.server.luau`
- `src/StarterGui/MainClient.client.luau`

Key live concerns:
- Reset the build while preserving the long-term multiplier/state
- Keep the current developer full-build shortcut compatible with rebirth testing

4. Raid/security
Responsible output:
- `src/ServerScriptService/Services/RaidService.luau`
- `Week7_RAID_BLUEPRINT.md`

Integration target:
- `src/ServerScriptService/MainServer.server.luau`
- `src/ServerScriptService/Services/Tycoon.luau`
- `src/StarterGui/MainClient.client.luau`

Key live concerns:
- Respect the current owner-door model
- Avoid grief-heavy mechanics that make the tycoon unreadable
- Keep raid windows explicit and reversible

## Integration Order

1. Second floor
2. Save/load
3. Rebirth
4. Raid/security

## Notes

- The second-floor plan is now live in the runtime and no longer just a planning track.
- The server layout now scales to an 8-tycoon map with a larger shared hub.
- The next major work starts with save/load integration.

## Week 6 Runtime Rules To Preserve

- Shared lobby claim flow
- 8-tycoon ring layout with a decorated center hub and corner landmarks
- Owner-only claim and upgrade purchase
- Pad-based local upgrades near relevant machines/structures
- Door can be opened publicly by the owner through paired inside/outside buttons
- Developer full-build shortcut remains available for rapid testing
- Plot/owner summary should stay scale-aware as the lobby expands
