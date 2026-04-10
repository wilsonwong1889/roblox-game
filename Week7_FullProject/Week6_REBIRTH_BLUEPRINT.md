# Week 6 Rebirth Blueprint

## Goal
Add a prestige loop that resets the tycoon for a permanent reward, without changing the current gameplay yet.

## Core Flow
1. Player finishes the first-floor progression path.
2. Player meets an earned-cash threshold.
3. Player opens the rebirth panel.
4. Game shows what will be reset and what will be kept.
5. Player confirms rebirth.
6. Tycoon resets to a clean state and the player receives permanent prestige bonuses.

## Eligibility Rules
- Rebirth should require a fully built first-floor shell.
- The current scaffold treats `roof_frame` as the completion marker.
- Rebirth should also require a large enough `TotalEarned` value.
- The service should stay pure and derive eligibility from state only.

## Reset Scope
Reset on rebirth:
- wallet cash
- stash cash
- vault cash
- collector stored cash
- claimed tycoon ownership
- purchased upgrades
- active structures
- door state
- upgrade buttons
- dropper loops

Keep on rebirth:
- rebirth count
- identity data
- prestige history
- cosmetic-only future data

## Reward Model
- Each rebirth increases the permanent payout multiplier.
- Each rebirth also increases the starting cash for the next run.
- The scaffold caps the bonus growth so it does not explode early.

## Proposed UI
- `Rebirth Ready`
- `Current Progress`
- `Will Reset`
- `Will Keep`
- `Permanent Bonus`
- `Confirm Rebirth`

## Integration Points Later
- add a rebirth button to the HUD
- wire the confirmation prompt to `RebirthService`
- store prestige state in save/load
- rebuild tycoon ownership and starter cash after a confirmed rebirth
- show the prestige title in the HUD and leaderboard

## Current Scaffold Assumptions
- The first-floor shell is the threshold for prestige.
- Rebirth is a reset-first, reward-second loop.
- The feature should stay separate from raids and second-floor expansion.
- The service should remain pure until integration work begins.
