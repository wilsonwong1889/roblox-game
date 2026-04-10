# Week 8 Blueprint

Week 8 is the release-owner polish pass.

## Goal

Ship the current Week 7/8 gameplay as a clean, readable, release-ready build with stable HUD state, coherent gem/spin flow, and release docs that match the runtime.

## Standing Agent Roles

- `Spawn & Regression Gate`: owns startup verification, lobby spawn checks, and "no fallback spawn" testing every run.
- `UI / State Owner`: owns the HUD, menu minimize flow, daily spin presentation, and currency summary readability.
- `Save / Release Owner`: owns save payload shape, settings-tab save visibility, docs, and release artifacts.
- `QA Pass`: validates menu, economy, redeem codes, and release build behavior against the test cases.

## Scope

- front menu polish
- minimize and reopen behavior
- start tab state presentation
- daily spin, free spins, cash, and gems coherence
- settings tab save/runtime visibility
- docs and test cases aligned with the live build
- release build and snapshot workflow

## Non-Goals

- no new map structure work
- no new startup bootstrap rewrites
- no new combat systems
- no new tycoon layout expansion

## Deliverables

- readable HUD state for wallet, collector, coins, gems, kills, and free spins
- daily spin panel that clearly shows the weighted reward table
- front menu that can be minimized and reopened
- release-ready Week 8 README and test cases
- validated save payload fields for gems, spins, and last reward metadata
- smoke-tested release build

## Validation Gates

1. Spawn gate passes and the real main lobby loads first.
2. Menu tabs all open, switch, and minimize correctly.
3. Economy state is readable at a glance.
4. Daily spin rewards and free spins match the live server state.
5. Save/runtime state is visible in Settings.
6. Smoke tests pass.
7. Week 8 build opens cleanly in Studio.

## Definition Of Done

Week 8 is done when the HUD is clear, the menu is coherent, the save/runtime state is readable, the spawn gate passes, and the release docs/tests match the current build without stale bootstrap text.
