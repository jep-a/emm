util.AddNetworkString "Ghosts"

GhostService.ghosts = GhostService.ghosts or {}

function GhostService.Ragdoll(ply, statue)
	local ragdoll = ents.Create "prop_ragdoll"

	ragdoll:SetOwner(ply)
	ragdoll:SetPos(ply:GetPos())
	ragdoll:SetAngles(ply:GetAngles())
	ragdoll:SetModel(ply:GetModel())
	ragdoll:SetSkin(ply:GetSkin())

	for _, body_group in pairs(ply:GetBodyGroups()) do
		ragdoll:SetBodygroup(body_group.id, ply:GetBodygroup(body_group.id))
	end

	ragdoll:SetColor(ply:GetColor())
	ragdoll:Spawn()
	ragdoll:Activate()
	ragdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	ragdoll.ghost = true
	ragdoll.ghost_player = ply
	ragdoll.lobby = ply.lobby

	local phys_count = ragdoll:GetPhysicsObjectCount() - 1

	for i = 0, phys_count do
		local bone = ragdoll:GetPhysicsObjectNum(i)

		if IsValid(bone) then
			local bone_pos, bone_ang = ply:GetBonePosition(ragdoll:TranslatePhysBoneToBone(i))

			if bone_pos and bone_ang then
				bone:SetPos(bone_pos)
				bone:SetAngles(bone_ang)
			end
		end
	end

	if statue then
		for i = 1, phys_count do
			constraint.Weld(ragdoll, ragdoll, 0, i, 0)

			ragdoll:GetPhysicsObjectNum(i):SetVelocity(ply:GetVelocity())
		end
	end

	return ragdoll
end

function GhostService.Ghost(ply, options)
	options = options or {}

	ply.ghosting = true
	ply.ghost_position = ply:GetPos()
	ply.ghost_dead = options.kill

	if options.savepoint then
		ply.ghost_savepoint = SavepointService.CreateSavepoint(ply, istable(options.savepoint) and options.savepoint or {})
	end

	if options.kill then
		ply:KillSilent()
	end

	if options.ragdoll then
		ply.ghost_ragdoll = GhostService.Ragdoll(ply, options.statue)
	end

	TrailService.RemoveTrail(ply)
	table.insert(GhostService.ghosts, ply)
	hook.Run("PlayerGhost", ply)
	NetService.Broadcast("Ghost", ply, ply.ghost_position, ply.ghost_dead, options.ragdoll and ply.ghost_ragdoll:EntIndex())
end

function GhostService.UnGhost(ply)
	if ply.ghosting then
		if not ply:Alive() then
			ply:Spawn()
		end

		ply.ghosting = false
		ply.ghost_position = nil
		ply.ghost_dead = nil
		ply.ghost_ragdoll_id = nil

		if ply.ghost_savepoint then
			if ply.ghost_ragdoll then
				local pos = ply.ghost_ragdoll:GetPos()
				local vel = ply.ghost_ragdoll:GetVelocity()

				local trace = util.TraceLine {
					start = pos,
					endpos = pos + Vector(0, 0, -38),
					filter = ply,
					mask = MASK_PLAYERSOLID
				}

				SavepointService.LoadSavepoint(ply, ply.ghost_savepoint, {
					position = trace.HitPos,
					velocity = vel
				})
			else
				SavepointService.LoadSavepoint(ply, ply.ghost_savepoint)
			end

			SavepointService.FinishSavepoint(ply.ghost_savepoint)
		end

		if IsValid(ply.ghost_ragdoll) then
			ply.ghost_ragdoll:Remove()
		end

		TrailService.SetupTrail(ply)
		table.RemoveByValue(GhostService.ghosts, ply)
		hook.Run("PlayerUnGhost", ply)
		NetService.Broadcast("UnGhost", ply)
	end
end
hook.Add("FinishPlayerClass", "GhostService.UnGhost", GhostService.UnGhost)

function GhostService.SendGhosts(ply)
	net.Start "Ghosts"
	net.WriteUInt(table.Count(GhostService.ghosts), 8)

	for _, ghost in pairs(GhostService.ghosts) do
		net.WriteEntity(ghost)
		net.WriteVector(ghost.ghost_position)
		net.WriteBool(ghost.ghost_dead)
		net.WriteEntity(ghost.ghost_ragdoll)
	end

	net.Send(ply)

	ply.received_ghosts = true
end
NetService.Receive("RequestGhosts", GhostService.SendGhosts)