# Week 1 Explorer Target

Archived Week 1 Explorer target.

## Runtime Workspace Structure

### Workspace

- `Lobby`
- `SharedMap`
- `TycoonPlots`

### Workspace/Lobby

- `SpawnPlatform`
- `SpawnLocation`

### Workspace/SharedMap

- `Ground`
- `Divider`

### Workspace/TycoonPlots

- `TycoonA`
- `TycoonB`

### Inside Each Tycoon

- `BaseFloor`
- `ClaimPad`
- `OwnerSign`
- `Zones`
- `Boundaries`
- `SpawnPoints`
- `Values`
- `UpgradeButtons`
- `StructureSockets`

### Inside `Zones`

- `ProductionZone`
- `StashZone`
- `VaultZone`
- `EntranceZone`

### Inside `Boundaries`

- `BackBoundary`
- `FrontBoundary`
- `LeftBoundary`
- `RightBoundary`

### Inside `SpawnPoints`

- `TycoonSpawn`

### Inside `Values`

- `OwnerUserId`
- `OwnerName`
- `IsClaimed`
- `TycoonId`

### Inside `StructureSockets`

- `GeneratorSocket`
- `CollectorSocket`
- `DoorSocket`
- `SecondFloorSocket`

## Source Folder Structure

### ReplicatedStorage

- `Modules`
- `Remotes`

### ServerScriptService

- `Services`
- `MainServer.server.luau`

### StarterGui

- `MainClient.client.luau`

### Reference Files

- `src/Workspace/TycoonModels.luau`
- `src/ServerStorage/TycoonAssets.luau`

## Studio-Built Workflow

If you hand-build the Week 1 physical base in Studio, keep the names above. The runtime binder in:

- [Tycoon.luau](c:/Users/wilso/Coding/Roblox/roblox-trend-empire/src/ServerScriptService/Services/Tycoon.luau)
- [TycoonService.luau](c:/Users/wilso/Coding/Roblox/roblox-trend-empire/src/ServerScriptService/Services/TycoonService.luau)

will reuse matching models and fill in missing Week 1 scaffolding if needed.

For the active Week 2 baseline, use:

- [WEEK2_BLUEPRINT.md](c:/Users/wilso/Coding/Roblox/roblox-trend-empire/WEEK2_BLUEPRINT.md)
- [Week2/README.md](c:/Users/wilso/Coding/Roblox/roblox-trend-empire/Week2/README.md)
