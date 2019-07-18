GhostService = GhostService or {}

NetService.CreateSchema("Ghost", {"entity", "vector", "id"})
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

function GhostService.Position(ply)
	local pos

	if ply.ghosting then
		if IsValid(ply.ghost_ragdoll) then
			pos = ply.ghost_ragdoll:WorldSpaceCenter()
		else
			pos = ply.ghost_position
		end
	else
		pos = ply:WorldSpaceCenter()
	end

	return pos
end
