function MinigameService.IsSharingLobby(a, b)
	local sharing
	local lobby_a
	local lobby_b

	if isentity(a) then
		lobby_a = a.lobby
	else
		lobby_a = a
	end

	if isentity(b) then
		lobby_b = b.lobby
	else
		lobby_b = b
	end

	if lobby_a and lobby_b and lobby_a == lobby_b then
		sharing = true
	else
		sharing = false
	end

	return sharing
end

function MinigameService.FilterPlayers(lobby, props)
	props = props or {}

	local whitelist_class_plys = lobby[props.whitelist_class_key]
	local blacklist_class_plys = lobby[props.blacklist_class_key]
	local blacklist_plys = props.blacklist_plys or {}

	local filtered_plys = {}

	if whitelist_class_plys then
		filtered_plys = table.Copy(whitelist_class_plys)
	else
		filtered_plys = table.Copy(lobby.players)

		if blacklist_class_plys then
			blacklist_plys = table.Add(blacklist_plys, table.Copy(blacklist_class_plys))
		end
	end

	if #blacklist_plys > 0 then
		local removed_plys_i = {}

		for i, ply in pairs(filtered_plys) do
			if table.HasValue(blacklist_plys, ply) then
				table.insert(removed_plys_i, i)
			end
		end

		for i, ply_i in pairs(removed_plys_i) do
			table.remove(filtered_plys, ply_i)
		end
	end

	return filtered_plys
end

function MinigameService.ClosestPlayer(lobby, origin_ply, filter)
	local plys = MinigameService.FilterPlayers(lobby, filter)
	local origin = origin_ply:WorldSpaceCenter()

	local closest_ply
	local closest_dist

	for i = 1, #plys do
		local ply = plys[i]

		if origin_ply ~= ply and ply:Alive() then
			local dist = origin:Distance(ply:WorldSpaceCenter())

			if not closest_dist or dist < closest_dist then
				closest_ply = ply
				closest_dist = dist
			end
		end
	end

	return closest_ply
end

function MinigameService.SoundIsolation(snd)
	local ent = snd.Entity

	if SERVER and IsPlayer(ent) and snd.DSP ~= 200 then
		if IsValid(ent:GetActiveWeapon()) then
			if (table.HasValue(MINIGAME_WEAPONS, ent:GetActiveWeapon():GetKeyValues().classname) and ent.lobby) then
				local filter = RecipientFilter()

				for _, ply in pairs(ent.lobby.players) do
					if ply != ent then
						filter:AddPlayer(ply)
					end
				end

				local sound = CreateSound( ent, snd.SoundName, filter )
				
				sound:ChangeVolume(snd.Volume)
				sound:ChangePitch(snd.Pitch)
				sound:SetSoundLevel(snd.SoundLevel)
				sound:SetDSP(200)
				sound:Play()

				return false
			end
		end
	end
end
hook.Add( "EntityEmitSound", "MinigameService.SoundIsolation", MinigameService.SoundIsolation)