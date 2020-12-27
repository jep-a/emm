GhostService.queued_ragdolls = GhostService.queued_ragdolls or {}

function GhostService.IsGhostingWithoutRagdoll(ply)
	return ply.ghosting and not IsValid(ply.ghost_ragdoll)
end

function GhostService.Ghost(ply, pos, dead, ragdoll_id)
	ply.ghosting = true
	ply.ghost_position = pos
	ply.ghost_dead = dead
	ply.ghost_ragdoll_id = ragdoll_id

	if ragdoll_id then
		if IsValid(GhostService.queued_ragdolls[ragdoll_id]) then
			ply.ghost_ragdoll = GhostService.queued_ragdolls[ragdoll_id]
			GhostService.queued_ragdolls[ragdoll_id] = nil
		else
			GhostService.queued_ragdolls[ragdoll_id] = ply
		end
	end

	if IsLocalPlayer(ply) then
		hook.Run("LocalPlayerGhost", ply)
	end

	hook.Run("PlayerGhost", ply)

	if ply.lobby then
		if MinigameService.IsLocalLobby(ply) then
			hook.Run("LocalLobbyPlayerGhost", ply.lobby, ply)
		end
	end
end
NetService.Receive("Ghost", GhostService.Ghost)

function GhostService.UnGhost(ply, ragdoll)
	ply.ghosting = false
	ply.ghost_position = nil
	ply.ghost_dead = nil
	ply.ghost_ragdoll_id = nil
	ply.ghost_ragdoll = nil

	if IsLocalPlayer(ply) then
		hook.Run("LocalPlayerUnGhost", ply)
	end

	hook.Run("PlayerUnGhost", ply)

	if ply.lobby then
		if MinigameService.IsLocalLobby(ply) then
			hook.Run("LocalLobbyPlayerUnGhost", ply.lobby, ply)
		end
	end
end
NetService.Receive("UnGhost", GhostService.UnGhost)

function GhostService.OnEntityCreated(ent)
	if ent:GetClass() == "prop_ragdoll" then
		local i = ent:EntIndex()
		local ply = GhostService.queued_ragdolls[i]

		if IsValid(ply) then
			ply.ghost_ragdoll = ent

			ent.ghost = true
			ent.ghost_player = ply
			ent.lobby = ply.lobby

			GhostService.queued_ragdolls[i] = nil
		else
			GhostService.queued_ragdolls[i] = ent
		end
	end
end
hook.Add("OnEntityCreated", "GhostService.OnEntityCreated", GhostService.OnEntityCreated)

function GhostService.PrePlayerDraw(ply)
	if ply.ghosting then
		render.SetBlend(0.5)
	end
end
hook.Add("PrePlayerDraw", "GhostService.PrePlayerDraw", GhostService.PrePlayerDraw)

function GhostService.PostPlayerDraw(ply)
    render.SetBlend(1)
end
hook.Add("PostPlayerDraw", "GhostService.PostPlayerDraw", GhostService.PostPlayerDraw)

function GhostService.RequestGhosts()
	NetService.SendToServer "RequestGhosts"
end
hook.Add("InitPostEntity", "GhostService.RequestGhosts", GhostService.RequestGhosts)

function GhostService.ReceiveGhosts(len)
	local ghost_count = NetService.ReadID()

	for i = 1, ghost_count do
		local ply = net.ReadEntity()
		local pos = net.ReadVector()
		local dead = net.ReadBool()
		local ragdoll = net.ReadEntity()

		ragdoll.ghost = true
		ragdoll.ghost_player = ply

		ply.ghosting = true
		ply.ghost_position = pos
		ply.ghost_dead = dead
		ply.ghost_ragdoll = ragdoll
	end

	GhostService.received_ghosts = true
	hook.Run "ReceiveGhosts"
end
net.Receive("Ghosts", GhostService.ReceiveGhosts)