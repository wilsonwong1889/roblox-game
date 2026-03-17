# Break-In Tycoon

Roblox tycoon prototype with a strict week-by-week development flow.

## Current Active Week

Week 6 Ring Layout Expansion

## What Is In The Current Baseline

- lobby and claim flow that scales with the configured tycoon count
- reusable tycoon objects driven from config
- one tycoon max per player
- owner-only claim routing and respawn routing
- first-floor and second-floor economy progression with dropper, collector, and door/wall chains
- 8 claimable tycoons in a ring layout: 2 left, 2 right, 2 front, 2 back
- tycoon entrances face inward toward the center
- expanded shared map with center spawn, center decorations, and corner decorations
- earnings-per-second validation in the HUD and payloads
- live owners/open-plots summary for larger server reads
- smoke tests and self-tests

## Week 6 Target

Week 6 is the current expansion pass that the docs now target:

- expand the server from 2 tycoons to 8
- spread the tycoons into a ring around the center hub
- keep the current first-floor and second-floor progression intact per base
- improve shared-map readability with a larger hub, corner decorations, and open-plot awareness
- preserve test-friendly wallet balance and developer full-build flow

The runtime code is now on the 8-tycoon expansion baseline, and the current docs describe that live implementation target.

## Important Files

- [Week 1 Blueprint](./WEEK1_BLUEPRINT.md)
- [Week 2 Blueprint](./WEEK2_BLUEPRINT.md)
- [Week 3 Blueprint](./WEEK3_BLUEPRINT.md)
- [Week 4 Blueprint](./WEEK4_BLUEPRINT.md)
- [Week 3 README](./Week3/README.md)
- [Week 3 Explorer Structure](./Week3/EXPLORER_STRUCTURE.md)
- [Week 3 Test Cases](./Week3/TEST_CASES.md)
- [Week 4 README](./Week4/README.md)
- [Week 4 Explorer Structure](./Week4/EXPLORER_STRUCTURE.md)
- [Week 4 Test Cases](./Week4/TEST_CASES.md)
- [Week 5 Second Floor Blueprint](./Week5_SECOND_FLOOR_BLUEPRINT.md)
- [Week 6 README](./Week6/README.md)
- [Week 6 Test Cases](./Week6/TEST_CASES.md)
- [Week 1 Source Snapshot](./Weeks/Week1/src)
- [Week 2 Source Snapshot](./Weeks/Week2/src)
- [Week 3 Source Snapshot](./Weeks/Week3/src)
- [Week 5 Source Snapshot](./Weeks/Week5/src)
- [Week 6 Source Snapshot](./Weeks/Week6/src)

## Build And Test

Run the smoke test:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\Run-SmokeTests.ps1
```

Refresh the Week 6 source snapshot:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\Save-WeekSourceSnapshot.ps1 -WeekNumber 6 -Force
```

## Project Layout

- `src` contains the active source
- `Weeks` contains weekly source snapshots
- `releases` contains packaged `.rbxlx` builds
- `scripts` contains validation and snapshot helpers
