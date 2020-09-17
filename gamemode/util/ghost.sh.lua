GhostService = GhostService or {}

NetService.CreateSchema("Ghost", {"entity", "vector", "boolean", "id"})
NetService.CreateSchema("UnGhost", {"entity"})
NetService.CreateUpstreamSchema "RequestGhosts"

function GhostService.InitPlayerProperties(ply)
	ply.ghosting = false

end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"GhostService.InitPlayerProperties",
	GhostService.InitPlayerProperties
)

function GhostService.Alive(ply)
	local alive

	if ply.ghosting then
		alive = ply.ghost_dead
	else
		alive = ply:Alive()
	end

	return alive
end

function GhostService.Position(ply)
	local pos

	if ply.ghosting then
		pos = ply.ghost_position
	else
		pos = ply:GetPos()
	end

	return pos
end

function GhostService.Entity(ply)
	local ent

	if ply.ghosting then
		ent = ply.ghost_ragdoll
	else
		ent = ply
	end

	return ent
end
