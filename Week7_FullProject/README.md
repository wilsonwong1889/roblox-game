# Break-In Tycoon

Roblox tycoon prototype with a strict week-by-week development flow.

## Current Active Week

Week 7 Combat Polish

## Current Baseline

- 8 claimable tycoons in a ring layout
- tycoon entrances face inward toward the center
- center-hub shared spawn
- three-floor tycoon progression
- droppers, conveyors, collectors, and starter manual dropper
- walls, high walls, door controls, wall health, and paid rebuilds
- roaming NPC soldiers outside the bases
- daily spin, redeem codes, kills, coins, and free spins
- role-based health, speed, and weapon loadouts
- Japanese-style environment pass with sakura trees and mountains
- sealed front-door geometry with tighter wall integration
- armory weapon pickup prompts with click-aimed weapons, crosshair, and sights on supported guns

The live `src` tree is now the Week 7 combat-polish pass derived from the Week 6 baseline.

## Important Files

- [Week 6 README](./Week6/README.md)
- [Week 6 Test Cases](./Week6/TEST_CASES.md)
- [Week 1 Blueprint](./WEEK1_BLUEPRINT.md)
- [Week 2 Blueprint](./WEEK2_BLUEPRINT.md)
- [Week 3 Blueprint](./WEEK3_BLUEPRINT.md)
- [Week 4 Blueprint](./WEEK4_BLUEPRINT.md)
- [Week 5 Second Floor Blueprint](./Week5_SECOND_FLOOR_BLUEPRINT.md)
- [Week 6 Rebirth Blueprint](./Week6_REBIRTH_BLUEPRINT.md)
- [Week 6 Source Snapshot](./Weeks/Week6/src)
- [Week 7 Source Snapshot](./Weeks/Week7/src)
- [Week 8 Source Snapshot](./Weeks/Week8/src)

## Build And Test

Run the smoke test:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\Run-SmokeTests.ps1
```

Refresh the Week 7 source snapshot:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\Save-WeekSourceSnapshot.ps1 -WeekNumber 7 -Force
```

## Project Layout

- `src` contains the active source
- `Weeks` contains weekly source snapshots
- `releases` contains packaged `.rbxlx` builds
- `scripts` contains validation and snapshot helpers
