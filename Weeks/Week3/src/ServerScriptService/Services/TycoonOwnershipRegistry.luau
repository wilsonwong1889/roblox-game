local TycoonOwnershipRegistry = {}

export type Registry = {
	ownersByTycoonId: { [string]: Player },
	tycoonIdByUserId: { [number]: string },
}

function TycoonOwnershipRegistry.new(): Registry
	return {
		ownersByTycoonId = {},
		tycoonIdByUserId = {},
	}
end

function TycoonOwnershipRegistry.canClaim(registry: Registry, player: Player, tycoonId: string): boolean
	return registry.ownersByTycoonId[tycoonId] == nil and registry.tycoonIdByUserId[player.UserId] == nil
end

function TycoonOwnershipRegistry.claim(registry: Registry, player: Player, tycoonId: string): boolean
	if not TycoonOwnershipRegistry.canClaim(registry, player, tycoonId) then
		return false
	end

	registry.ownersByTycoonId[tycoonId] = player
	registry.tycoonIdByUserId[player.UserId] = tycoonId
	return true
end

function TycoonOwnershipRegistry.releaseTycoon(registry: Registry, tycoonId: string): Player?
	local owner = registry.ownersByTycoonId[tycoonId]
	if not owner then
		return nil
	end

	registry.ownersByTycoonId[tycoonId] = nil
	registry.tycoonIdByUserId[owner.UserId] = nil
	return owner
end

function TycoonOwnershipRegistry.releasePlayer(registry: Registry, player: Player): string?
	local tycoonId = registry.tycoonIdByUserId[player.UserId]
	if not tycoonId then
		return nil
	end

	registry.tycoonIdByUserId[player.UserId] = nil
	registry.ownersByTycoonId[tycoonId] = nil
	return tycoonId
end

function TycoonOwnershipRegistry.getOwner(registry: Registry, tycoonId: string): Player?
	return registry.ownersByTycoonId[tycoonId]
end

function TycoonOwnershipRegistry.getPlayerTycoonId(registry: Registry, player: Player): string?
	return registry.tycoonIdByUserId[player.UserId]
end

return TycoonOwnershipRegistry
