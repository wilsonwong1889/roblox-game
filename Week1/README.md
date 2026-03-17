# Week 1

## Archived Baseline

Week 1 is archived for reference. The active validation baseline has moved to Week 2 docs.

The game should do only these things well:

- all players spawn in one shared lobby
- players walk to the tycoon they want
- each player can claim only one tycoon
- a claimed tycoon cannot be stolen
- owner signage updates correctly
- future respawns send the owner to their tycoon spawn
- the codebase stays clean enough for Week 2 economy work later

## What Is Intentionally Not In Week 1

- no droppers
- no conveyor economy
- no collector cashout loop
- no upgrade chain
- no save/load
- no monetization
- no race HUD

Those systems were removed from the active runtime so the project is back to a real foundation milestone.

## Archived Week 1 Runtime

- `2` tycoon plots
- `1` shared lobby spawn
- reusable tycoon objects from config
- generated or bindable physical plots inside `Workspace/Lobby`, `Workspace/SharedMap`, and `Workspace/TycoonPlots`
- claim pads
- owner signs
- ownership value objects
- simple placeholder HUD

## Archived Architecture

- `src/ReplicatedStorage/Modules/GameConfig.luau`
  Defines Week 1 settings, tycoon origins, and workspace folder names
- `src/ReplicatedStorage/Modules/PlayerProfile.luau`
  Creates runtime player state for ownership and placeholder currencies
- `src/ServerScriptService/Services/TycoonOwnershipRegistry.luau`
  Prevents one player from owning more than one tycoon
- `src/ServerScriptService/Services/Tycoon.luau`
  Creates or binds a single Week 1 tycoon plot object
- `src/ServerScriptService/Services/TycoonService.luau`
  Creates `Lobby`, `SharedMap`, and `TycoonPlots`
- `src/ServerScriptService/MainServer.server.luau`
  Hooks player lifecycle, claim prompts, and respawn routing
- `src/StarterGui/MainClient.client.luau`
  Renders the Week 1 HUD and toasts

## Week 1 Success Criteria

- players join in the same lobby
- players claim by walking to a claim pad
- claim does not teleport instantly
- future respawns route to the owned tycoon
- owner signs update
- tycoon values update
- leaving frees the tycoon
- smoke tests pass
- Studio self-tests print `Week 1 tests passed`

## Related Files

- [WEEK1_BLUEPRINT.md](c:/Users/wilso/Coding/Roblox/roblox-trend-empire/WEEK1_BLUEPRINT.md)
- [EXPLORER_STRUCTURE.md](c:/Users/wilso/Coding/Roblox/roblox-trend-empire/Week1/EXPLORER_STRUCTURE.md)
- [TEST_CASES.md](c:/Users/wilso/Coding/Roblox/roblox-trend-empire/Week1/TEST_CASES.md)
