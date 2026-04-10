# Week 8 Test Cases

## Spawn And Bootstrap Gate

1. Open the rebuilt Week 8 `.rbxlx` in Studio.
2. Confirm you spawn on the real main lobby, not a fallback pad or void space.
3. Confirm `Workspace/Lobby`, `Workspace/SharedMap`, and `Workspace/TycoonPlots` exist.
4. Confirm all active tycoon plots appear and are spaced correctly.
5. If any fallback spawn appears, fail the build and inspect `Output` before continuing.

## Menu And HUD

1. Join the server.
2. Confirm the start menu opens automatically.
3. Confirm the menu can be minimized and reopened from the HUD.
4. Confirm `Start Now`, `Information`, `Settings`, and `Shop` all switch correctly.
5. Confirm the start tab shows wallet, collector, coins, gems, free spins, and last spin state.
6. Confirm the settings tab shows save runtime and last-save status.

## Daily Spin And Currency Flow

1. Open `Start Now`.
2. Confirm the daily spin panel shows the weighted reward tiles.
3. Confirm the daily spin can award cash or gems.
4. Confirm free spins are granted every 5 coins.
5. Confirm the spin button changes text when the daily spin is claimed versus when a free spin is available.

## Codes

1. Open the redeem panel.
2. Redeem `money`, `amanda`, `admin`, and `rematch` on a clean server.
3. Confirm each code grants the correct reward.
4. Confirm each code can only be redeemed once per server session.
5. Confirm the UI reports success or duplicate-use clearly.

## Save Visibility

1. Open the settings tab.
2. Confirm the save runtime status is readable.
3. Trigger a save or autosave in a live/published session.
4. Confirm the last-save text updates after the save path completes.

## Release Verification

1. Run `scripts\\Run-SmokeTests.ps1`.
2. Refresh `Weeks\\Week8\\src`.
3. Open the rebuilt Week 8 `.rbxlx` file in Studio.
4. Confirm the self-test output reports the Week 8 release pass.
