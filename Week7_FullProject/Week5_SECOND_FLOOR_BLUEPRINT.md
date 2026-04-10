# Week 5 Second Floor Blueprint

## Goal

Add a second floor that feels like a natural continuation of the current Week 4 first-floor layout.

This track is now integrated into the live runtime. The upper-floor build path, pads, droppers, conveyor visuals, HUD progression, and shared payout flow are wired into the current playable build.

## Current Layout Assumptions

- The tycoon footprint is already larger than the original Week 3 shell.
- The production lane sits left of center with the belt and collector pushed to the side.
- The claim pad is small after claim and shows the owner name.
- The owner door has outside and inside buttons.
- The first floor already supports walls, reinforced door, premium conveyor, cash compressor, collector array, rear extension, utility bay, roof frame, and a developer full-build shortcut.

## Second Floor Intent

The second floor should feel like an upper production wing, not just a flat copy of the first floor.

It should add:

- vertical progression
- a visible stair or ramp route
- an upper landing
- a smaller upper conveyor line
- a few high-value upper droppers
- an upper collector or payout processor
- upper perimeter walls and roof framing

## Current Integration Slice

1. Unlock the second floor through a standalone upgrade entry.
2. Spawn the upper landing and stairs after the upgrade is bought.
3. Attach the upper wall shell to the back/right side of the current factory.
4. Add the upper conveyor and collector lane.
5. Add four upper droppers with faster but smaller count progression than the first floor.
6. Add a roof frame or canopy to make the upper structure read as complete.

The live build now points at and runs this chain end to end.

## Design Rules

- Keep the second floor visually connected to the current shell.
- Do not place the upper lane in the middle of the map.
- Preserve the first-floor belt path and the outside owner door.
- Do not hide the upper floor behind the HUD or a menu flow.
- Make every upper piece match the current industrial style.

## Proposed Object Set

- `SecondFloorFoundation`
- `SecondFloorLanding`
- `SecondFloorStairs`
- `UpperWalls`
- `UpperConveyor`
- `UpperCollector`
- `UpperDropper1`
- `UpperDropper2`
- `UpperDropper3`
- `UpperDropper4`
- `UpperRoofFrame`

## Proposed Upgrade Chain

- `Second Floor`
- `Upper Walls`
- `Upper Conveyor`
- `Upper Dropper 1`
- `Upper Dropper 2`
- `Upper Dropper 3`
- `Upper Dropper 4`
- `Upper Collector`
- `Roof Frame`

## Suggested Test Cases

- Claim a tycoon, then buy the second floor.
- Verify the stairs or ramp spawn in the correct side of the base.
- Verify the upper landing does not block the first-floor lane.
- Verify upper droppers face inward toward the upper conveyor.
- Verify upper-floor payouts feed the shared stored-cash flow cleanly.
- Verify the roof frame aligns with the larger shell.
- Verify leaving the server resets the upper floor cleanly if not saved.

## Runtime Integration Points

- `SecondFloorConfig.luau` remains the single source of layout constants for the upper floor.
- `Tycoon.luau` should create or bind the upper floor pieces from those constants.
- `MainServer.server.luau` should add the buy logic and payout routing.
- `PlayerProfile.luau` should track second-floor purchase state and upper-floor earnings.
- `SelfTestService.luau` should validate the upgrade order and layout constants.

## Risks

- The upper floor can become too cramped if the landing is too small.
- The stairs can block the first-floor door if they are placed too far forward.
- The second-floor conveyor can overlap the first-floor shell if the x-offset is not consistent.
- The upper collector can create confusion if it shares the same stored-cash UI as the first floor.

## Recommendation

Build the second floor in a back-right cluster first, then widen only if playtests show the upper lane feels too tight.

## Related File

- [SecondFloorConfig.luau](c:/Users/wilso/Coding/Roblox/roblox-trend-empire/src/ReplicatedStorage/Modules/SecondFloorConfig.luau)
