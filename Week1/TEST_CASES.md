# Week 1 Test Cases

Archived Week 1 test cases.

## Shared Spawn

- Player 1 joins and spawns in `Workspace/Lobby/SpawnLocation`.
- Player 2 joins and spawns in the same shared lobby area.
- Before claiming, neither player respawns inside a tycoon.

## Claim Flow

- Player 1 walks to `TycoonA` and claims it.
- `TycoonA/Values/IsClaimed` becomes `true`.
- `TycoonA/Values/OwnerUserId` becomes Player 1's user id.
- `TycoonA/Values/OwnerName` becomes Player 1's username.
- `TycoonA/OwnerSign` changes from `Unclaimed` to the owner text.
- Player 2 can still claim `TycoonB`.

## Ownership Integrity

- Player 1 cannot claim `TycoonB` after already owning `TycoonA`.
- Player 2 cannot steal `TycoonA` after Player 1 has claimed it.
- Two players racing for the same pad results in exactly one owner.
- The ownership registry always returns at most one tycoon per player.

## Respawn Rules

- Claiming does not teleport the player immediately.
- After claiming, death respawns the player inside `SpawnPoints/TycoonSpawn` for that tycoon.
- A player never respawns inside the other player's tycoon.

## Release Rules

- If a claimed player leaves, their tycoon becomes unclaimed again.
- `OwnerUserId` resets to `0`.
- `OwnerName` resets to an empty string.
- `IsClaimed` resets to `false`.
- The sign returns to `Unclaimed`.
- A new player can claim the released tycoon.

## Code Checks

- `scripts\\Run-SmokeTests.ps1` passes.
- Rojo build includes `Workspace` and `ServerStorage` mappings.
- Studio output includes `[SelfTest] Week 1 tests passed`.

For the active Week 2 baseline, use [Week2/TEST_CASES.md](c:/Users/wilso/Coding/Roblox/roblox-trend-empire/Week2/TEST_CASES.md).
