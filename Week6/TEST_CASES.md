# Week 6 Test Cases

## Automated Checks

Run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\Run-SmokeTests.ps1
```

Expected:

- Rojo build completes
- no missing file errors
- no project mapping errors for `Workspace` or `ServerStorage`

## Studio Self-Test

Open the place in Studio and start Play Solo.

Expected output:

- `[SelfTest] Week 6 perimeter-defense checks passed`

## Map Layout Tests

1. Confirm there are 8 tycoons total.
2. Confirm there are 2 tycoons on the left side of the hub.
3. Confirm there are 2 tycoons on the right side of the hub.
4. Confirm there are 2 tycoons on the front side of the hub.
5. Confirm there are 2 tycoons on the back side of the hub.
6. Confirm each tycoon entrance faces toward the center hub.
7. Confirm the center contains shared decoration objects.
8. Confirm each corner contains decoration objects.
9. Confirm the shared spawn is in the middle hub area.

## Claim Flow Tests

1. Spawn in the shared lobby.
2. Walk to any unclaimed tycoon.
3. Claim it.
4. Confirm the claim pad shrinks and shows the username.
5. Confirm the owner sign updates.
6. Confirm a second player cannot claim that same tycoon.
7. Confirm one player cannot own more than one tycoon.
8. Confirm leaving the server frees the tycoon.

## Door Tests

1. Claim a tycoon and buy `Wall Set 1`.
2. Buy `Front Door`.
3. Confirm both outside and inside owner door buttons appear.
4. Confirm only the owner can use those buttons.
5. Open the door as the owner.
6. Confirm the door panel physically moves out of the doorway.
7. Confirm a non-owner can walk through the open doorway.
8. Close the door as the owner.
9. Confirm the non-owner is blocked again.
10. Buy `Reinforced Door` and repeat the same checks.

## Starter Dropper Tests

1. Claim a tycoon without buying `Basic Dropper`.
2. Use the `Starter Dropper`.
3. Confirm a money crate spawns from the starter device itself.
4. Confirm the crate lands on the conveyor and moves to the collector.
5. Confirm stored money rises on the collector pad.
6. Collect the money and confirm wallet increases.

## First-Floor Progression Tests

1. Buy `Basic Dropper`.
2. Confirm the starter device hides.
3. Confirm the first automated dropper appears.
4. Buy through all 8 droppers.
5. Confirm each dropper creates money and feeds the conveyor.
6. Confirm `Auto Collector` stays locked until all 8 droppers are owned.
7. Buy `Auto Collector`.
8. Confirm new income goes directly to wallet instead of stored cash.

## Structure Tests

1. Buy `Wall Set 1`.
2. Confirm wall segments connect cleanly.
3. Buy `High Walls`.
4. Confirm higher wall segments sit directly on top of the first wall shell.
5. Confirm the door frame visually joins the front wall cleanly.

## Wall Health Tests

1. Buy `Wall Set 1`.
2. Buy `Armory Bay` and then a weapon, or use a second player with a purchased weapon.
3. Hit a wall segment with the knife, blaster, or RPG.
4. Confirm the repair console health total drops.
5. Confirm the repair prompt changes to `Rebuild $X`.
6. Keep damaging a wall until it disappears.
7. Confirm that destroyed wall segment no longer blocks movement.
8. Use the repair console as the owner.
9. Confirm wallet cash decreases by exactly the missing wall health.
10. Confirm the wall segment rebuilds and blocks movement again.

## NPC Patrol Tests

1. Join the map and walk around the outside perimeter.
2. Confirm 8 soldier NPCs spawn on pads outside the tycoon walls.
3. Confirm they roam between perimeter patrol points.
4. Confirm the patrols stay outside the tycoon walls instead of entering the bases.
5. Confirm soldiers still exist after multiple players claim tycoons.

## Daily Spin Tests

1. Join the game and open the start menu.
2. Confirm the `Daily Spin` panel appears on the `Start Now` tab.
3. Confirm the prize board shows 9 total tiles.
4. Confirm `$10,000` appears 6 times, `$100,000` appears 2 times, and `$1,000,000` appears 1 time.
5. Press `Spin Now`.
6. Confirm wallet cash increases by one of the configured reward amounts.
7. Confirm the button changes to the claimed state after use.
8. Confirm re-pressing it in the same session does not pay again.

## Second-Floor Tests

1. Use `Developer Full Build` or buy through the chain.
2. Buy `Second Floor`.
3. Confirm the second-floor deck appears.
4. Confirm the stairwell hole is open.
5. Walk up to the second floor.
6. Buy `Upper Conveyor`.
7. Buy upper droppers and confirm crates route to the upper collector path.

## Regression Checks

1. Respawn after claiming a tycoon and confirm you spawn in your own base.
2. Confirm another player does not spawn in your base.
3. Confirm HUD still shows wallet, stored cash, EPS, and plot summary.
4. Confirm background music still plays.
5. Confirm sprinting still works.
