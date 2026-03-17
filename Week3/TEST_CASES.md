# Week 3 Test Cases

## Config Checks

- `GameConfig.ACTIVE_TYCOON_COUNT` is `2`.
- `GameConfig.TYCOONS` contains exactly two tycoon definitions.
- `GameConfig.STARTING_CASH` is `100`.
- `GameConfig.STARTING_STASH_CASH` is `0`.
- `GameConfig.STARTING_VAULT_CASH` is `0`.
- `GameConfig.CLAIM_TELEPORT_ON_CLAIM` is `false`.
- `GameConfig.getUpgrade("basic_dropper")` returns the basic dropper definition.
- `GameConfig.areRequirementsMet()` respects the upgrade graph.
- `GameConfig.DROPPERS.second_dropper` produces more earnings per second than `basic_dropper`.
- `GameConfig.BUTTON_LANE_X_OFFSET` keeps the upgrade lane separate from the factory lane.
- `GameConfig.EARNINGS_BOARD_OFFSET` exists so the earnings board can sit above the tycoon.

## Ownership Checks

- A player can claim only one tycoon.
- A tycoon can have only one owner.
- A claimed tycoon cannot be stolen by another player.
- Releasing a player frees their tycoon for the next claim.

## Profile Checks

- A new profile starts with no tycoon.
- Wallet starts at `100` for the validation pass.
- Stash and vault placeholders start at zero.
- Collector stored cash starts at zero.
- Clearing the tycoon id updates the state payload correctly.
- Wallet spending, stash/vault setters, and collector cash helpers behave consistently.
- Collected stored cash transfers into the wallet and resets the collector store.
- Total earned increases when earned cash is added to the wallet.

## Runtime Checks

- The factory lane reads cleaner than Week 2.
- Wall set 1 appears in the correct upgrade slot.
- The owner front door is blocked for non-owners.
- The reinforced door is visually distinct from the front door.
- High walls visibly upgrade the perimeter.
- Earnings per second is visible in the HUD or validation payload.
- The validation payload includes the same earnings-per-second number as the profile helper.
- Another player cannot buy your structure buttons.
- Another player cannot collect from your collector pad.

## Structure Flow Checks

- `wall_set_1` appears before `front_door` in the upgrade lane.
- `front_door` appears before `reinforced_door` in the upgrade lane.
- `reinforced_door` appears before `high_walls` in the upgrade lane.
- The earnings board remains readable without overlapping the button lane.

## Snapshot Checks

- `scripts\Save-WeekSourceSnapshot.ps1 -WeekNumber 3` creates `Weeks\Week3\src`.
- `scripts\Run-SmokeTests.ps1` passes after the current changes.
