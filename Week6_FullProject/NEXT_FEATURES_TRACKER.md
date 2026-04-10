# Next Features Tracker

This file tracks the next major feature wave being prepared in parallel.

## Active Tracks

1. Save/load
Status:
- Live in the main server flow
- Wallet, upgrades, spins, codes, VIP state, and rebirth count serialize through `SaveService`
- Autosave and save-on-leave are enabled outside Studio by default

2. Rebirth
Status:
- Live in the current client/server flow
- HUD/menu expose prestige status
- Rebirth resets the build while preserving prestige count and the permanent payout multiplier

3. Raid/security
Status:
- Live as a controlled preview layer
- Owner raid console, breach pad, and collector theft cap are wired into the runtime
- The owner still controls when the raid window opens

4. Launch candidate polish
Status:
- Live in the current client/runtime
- Start menu includes shop and settings surfaces
- Launch checklist/tutorial panel is active
- Competition board is active in the shared hub

5. Base defense
Status:
- Live in the current runtime
- Alarm beacon, defense turret, and guard tower upgrades are wired into the first-floor structure chain
- Turrets automatically target zombies, perimeter soldiers, and hostile players near the owned tycoon

## Integration Order

1. Week 7 persistence and competition
2. Week 7 rebirth and raid
3. Week 8 onboarding, shop, and release polish

## Notes

- Second floor and third floor are already live.
- The project is now on a Week 8 launch-candidate baseline.
- The remaining validation gap is still real Studio/live server playtesting.

## Week 6 Runtime Rules To Preserve

- Shared lobby claim flow
- 8-tycoon ring layout with a decorated center hub and corner landmarks
- Owner-only claim and upgrade purchase
- Pad-based local upgrades near relevant machines/structures
- Door can be opened publicly by the owner through paired inside/outside buttons
- Developer full-build shortcut remains available for rapid testing
- Plot/owner summary should stay scale-aware as the lobby expands
