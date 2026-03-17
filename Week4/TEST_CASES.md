# Week 4 Test Cases

## Target Checks

- The first floor should be larger than the Week 3 layout.
- There should be 8 droppers on the first floor target lane.
- The starter clicker should spawn the same kind of income as the first dropper path.
- The second dropper should become automated after purchase for `$100`.
- The owner-only door should open and close through a control button.
- The auto collector should unlock only after all 8 droppers are purchased.
- The spawn should sit in a base corner instead of the center of the lot.
- The test wallet should be `100000` for local verification.

## Runtime Safety Checks

- Claim flow should still allow only one tycoon per player.
- Owner-only access should still block non-owners.
- The earnings payload should still expose wallet cash, collector cash, total earned, and earnings per second.
- The smoke build should still complete successfully from the active runtime tree.

## Validation Notes

These cases define the Week 4 target pass. They should be used when the gameplay implementation catches up to the expanded first-floor build.
