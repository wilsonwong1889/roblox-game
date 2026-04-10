# Week 7 Test Cases

## Startup And World Bootstrap

1. Start a fresh local server and confirm you do not spawn in empty space.
2. Confirm `Workspace/Lobby`, `Workspace/SharedMap`, and `Workspace/TycoonPlots` are all created before interacting with the game.
3. Confirm `Workspace/Lobby/SpawnLocation` exists and the player spawns on the center courtyard.
4. Confirm all 8 tycoon models exist under `Workspace/TycoonPlots`.
5. Confirm every tycoon has a base floor, claim pad, owner sign, and tycoon spawn.
6. If the main world fails to build, confirm `Workspace/EmergencyBootstrap` appears with an emergency spawn instead of leaving the player in the void.

## Door Seal

1. Claim a tycoon and buy `Wall Set 1`.
2. Buy `Front Door`.
3. Stand against the closed door seam from both the left and right edges.
4. Confirm the character cannot slip through the wall-door join when the door is closed.
5. Open the door with the owner button and confirm players can pass.
6. Close it again and confirm collision returns immediately.

## Armory Pickup And Weapon Flow

1. Claim a tycoon and buy `Armory Bay`.
2. Buy `Combat Knife`, `Money Blaster`, `Money Shotgun`, `Money Sniper`, and `Money RPG`.
3. Confirm each weapon display appears in a neat left-to-right row.
4. Walk to each display and hold `E`.
5. Confirm the unlocked weapon is added to the backpack.
6. Confirm non-owners cannot pick up weapons from another player's armory.
7. Reset the character and confirm starter knife/pistol return, while armory weapons require pickup again.

## Weapon Aim And Sights

1. Equip the starter pistol.
2. Confirm the crosshair appears.
3. Click left, right, and diagonally across the map and confirm shots follow the click target instead of only character facing.
4. Equip `Money Blaster`, `Money Sniper`, and `Money RPG`.
5. Hold right mouse on supported guns and confirm the view zooms for sights.
6. Release right mouse and confirm the camera returns to the normal FOV.
7. Equip the knife and confirm the crosshair/sights UI is hidden.

## Live Event Rotation

1. Join the server and wait for the shared-map event board to load.
2. Confirm the first active mode is `PvP Arena` with a 10-minute timer.
3. Confirm the center join pad is only enabled during the PvP round.
4. Join the PvP arena and confirm your character is teleported to an arena spawn.
5. Reset during the PvP round and confirm you respawn back into the arena.
6. Wait for the rotation to switch to `Zombie Siege`.
7. Confirm the PvP join pad disables and the event board updates to zombie mode.

## Zombie Siege

1. Claim a tycoon before `Zombie Siege` begins.
2. Wait for the zombie round to start.
3. Confirm zombies spawn outside the claimed tycoon and move toward players or walls.
4. Confirm zombies damage wall health when they reach the perimeter.
5. Confirm killing zombies still grants the NPC coin reward.
6. Confirm the zombie round ends cleanly and clears active zombies.

## Defense Upgrades

1. Claim a tycoon and build through `Alarm Beacon`, `Defense Turret`, and `Guard Tower`.
2. Confirm the defense pads appear in the right-side structure lane in the expected order.
3. Confirm the beacon, turret, and tower visuals only appear after their upgrades are purchased.
4. During a zombie round, confirm the turret acquires zombies and deals damage automatically.
5. Confirm turret kills still award the normal kill/coin flow to the tycoon owner.
6. Confirm the upgraded guard tower turret fires farther and faster than the base turret.

## Save And Load

1. Join a live server, claim a tycoon, and buy upgrades.
2. Leave and rejoin.
3. Confirm wallet, total earned, upgrades, spins, codes, and rebirth count restore.
4. Claim a fresh tycoon and confirm the saved build state reapplies.

## Rebirth

1. Reach the rebirth requirements.
2. Press the `Rebirth` button.
3. Confirm prestige count increases.
4. Confirm purchased upgrades reset.
5. Confirm starter cash is replaced by the rebirth starter amount.

## Raids

1. Claim a tycoon and buy the front door.
2. Open the raid window from the raid console.
3. As a second player, breach the raid pad.
4. Confirm the door opens and the collector can be stolen from.
5. Confirm theft cannot exceed the raid cap.
6. Confirm the raid closes when the timer expires.

## Shop

1. Open the start menu.
2. Go to `Shop`.
3. Confirm the VIP starter pack offer appears.
4. Press the shop button and confirm the gamepass prompt opens.
