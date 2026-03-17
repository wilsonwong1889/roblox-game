# Week 3 Blueprint

Week 3 is the structure and earnings pass. The goal is to make the tycoon feel cleaner, add the wall/door upgrade path, and surface how much money the factory is earning per second.

## Week 3 Goal

By the end of Week 3:

- the tycoon layout reads more clearly
- wall upgrades appear in a sensible progression
- the front door is owner-only
- the reinforced door upgrade is visually distinct
- higher walls make the base feel more complete
- the HUD and validation payload show wallet cash, collector cash, total earned, and earnings per second
- the factory still runs from the Week 2 dropper/conveyor/collector loop

## Week 3 Build Order

1. Clean the tycoon layout.
2. Add wall set 1.
3. Add the owner front door.
4. Add the reinforced door upgrade.
5. Add high walls.
6. Add the earnings-per-second display.
7. Verify the cleaner button lane and earnings board placement.
8. Run the Week 3 self-tests.
9. Snapshot `Weeks/Week3/src`.

## Week 3 Scope

- wall upgrades
- owner-only front door
- reinforced door
- high walls
- earnings per second
- cleaner layout and button flow

## Week 3 Validation Targets

- `wall_set_1` must unlock before `front_door`
- `front_door` must unlock before `reinforced_door`
- `reinforced_door` must unlock before `high_walls`
- earnings per second must be exposed through the player state payload
- the button lane must stay separated from the factory lane

## Not In Week 3

- second floor
- save/load
- monetization
- raids
- combat

## Related Docs

- [Week3/README.md](c:/Users/wilso/Coding/Roblox/roblox-trend-empire/Week3/README.md)
- [Week3/EXPLORER_STRUCTURE.md](c:/Users/wilso/Coding/Roblox/roblox-trend-empire/Week3/EXPLORER_STRUCTURE.md)
- [Week3/TEST_CASES.md](c:/Users/wilso/Coding/Roblox/roblox-trend-empire/Week3/TEST_CASES.md)
