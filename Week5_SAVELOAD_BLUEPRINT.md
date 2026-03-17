# Week 5 Save/Load Blueprint

## Goal

Add persistence for the current tycoon profile shape without changing live runtime flow yet. The save layer should round-trip player cash, stash, vault, collector storage, tycoon ownership, total earned, and purchased upgrades.

## Current Scaffold

The new save scaffold lives in:
- [`src/ServerScriptService/Services/SaveService.luau`](c:/Users/wilso/Coding/Roblox/roblox-trend-empire/src/ServerScriptService/Services/SaveService.luau)

It currently provides:
- DataStore access by user id
- default record creation
- serialize and deserialize helpers
- profile validation
- retry-based load and save calls
- a reset-plan helper for prestige or wipe flows later

## Integration Points

The next step is to wire SaveService into the normal player lifecycle in the server bootstrap layer.

Suggested flow:
- `PlayerAdded` should create or load a profile before gameplay state is exposed
- `PlayerRemoving` should save the latest profile snapshot before cleanup
- tycoon claim state should be restored before buttons and visuals are activated
- purchased upgrades should be re-applied before dropper loops begin
- respawn routing should use the loaded tycoon id after profile hydration

## Data Shape

The current profile shape supports:
- `UserId`
- `Name`
- `DisplayName`
- `TycoonId`
- `WalletCash`
- `StashCash`
- `VaultCash`
- `CollectorStoredCash`
- `TotalEarned`
- `PurchasedUpgrades`

The scaffold filters unknown upgrade ids so bad or stale data does not leak into the live state.

## Risks

- Save-before-load ordering can wipe progress if a default profile is created and saved before the DataStore result returns.
- Concurrent writes can race if autosave and leave-save run at the same time.
- Schema migrations need a version bump path once the profile shape changes.
- DataStore throttling can fail saves under load if too many writes happen too quickly.
- A malformed record should never block spawn or claim flow.

## Implementation Rules

- Load the profile before any claim or upgrade systems start.
- Normalize every value before it touches gameplay state.
- Keep save calls server-side only.
- Keep the runtime profile as the single source of truth after load.
- Treat a failed save as a warning, not a gameplay error.

## Recommended Next Files To Touch

- `src/ServerScriptService/MainServer.server.luau`
- `src/ReplicatedStorage/Modules/PlayerProfile.luau`
- `src/ServerScriptService/Services/TycoonService.luau`

## Deferred Work

- Autosave timer
- leave-save hook
- migration support for future schema versions
- recovery UI for save failures

