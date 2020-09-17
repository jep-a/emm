util.AddNetworkString "Ghosts"

GhostService.ghosts = GhostService.ghosts or {}

function GhostService.Ragdoll(ply, freeze)
	local ragdoll = ents.Create "prop_ragdoll"

	ragdoll:SetOwner(ply)
	ragdoll:SetPos(ply:GetPos())
	ragdoll:SetModel(ply:GetModel())
	ragdoll:SetSkin(ply:GetSkin())

	for _, body_group in pairs(ply:GetBodyGroups()) do
		ragdoll:SetBodygroup(body_group.id, ply:GetBodygroup(body_group.id))
	end

	ragdoll:SetAngles(ply:GetAngles())
	ragdoll:SetColor(ply:GetColor())
	ragdoll:Spawn()
	ragdoll:Activate()
	ragdoll:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	ragdoll.ghost_player = ply
	ragdoll.lobby = ply.lobby

	local phys_count = ragdoll:GetPhysicsObjectCount() - 1
	local vel = ply:GetVelocity()

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

	if freeze then
		timer.Simple(SAFE_FRAME * 3, function ()
			for i = 0, phys_count do
				local bone = ragdoll:GetPhysicsObjectNum(i)

				if IsValid(bone) then
					bone:Sleep()
				end
			end
		end)
	end

	return ragdoll
end

function GhostService.Ghost(ply, options)
	options = options or {}

	ply.ghosting = true
	ply.ghost_position = ply:GetPos()
	ply.ghost_dead = options.kill

	if options.kill then
		ply:KillSilent()
	end

	if options.ragdoll then
		ply.ghost_ragdoll = GhostService.Ragdoll(ply, options.freeze)
	end

	table.insert(GhostService.ghosts, ply)
	hook.Run("PlayerGhost", ply)
	NetService.Broadcast("Ghost", ply, ply.ghost_position, options.ragdoll and ply.ghost_ragdoll:EntIndex())
end

function GhostService.UnGhost(ply)
	if ply.ghosting then
		ply.ghosting = false
		ply.ghost_position = nil
		ply.ghost_dead = nil
		ply.ghost_ragdoll_id = nil

		if IsValid(ply.ghost_ragdoll) then
			ply.ghost_ragdoll:Remove()
		end

		table.RemoveByValue(GhostService.ghosts, ply)

		hook.Run("PlayerUnGhost", ply)
		NetService.Broadcast("UnGhost", ply)
	end
end
hook.Add("EndPlayerClass", "GhostService.UnGhost", GhostService.UnGhost)

function GhostService.EntityTakeDamage(victim, dmg)
	if victim:GetClass() == "prop_ragdoll" and IsValid(victim.ghost_player) and victim.ghost_player:Alive() then
		victim.ghost_player:TakeDamageInfo(dmg)
	end
end
hook.Add("EntityTakeDamage", "GhostService.EntityTakeDamage", GhostService.EntityTakeDamage)

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