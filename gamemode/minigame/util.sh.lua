function MinigameService.IsSharingLobby(a, b)
	if CLIENT then
		b = b or LocalPlayer()
	end

	local sharing
	local lobby_a
	local lobby_b

	if isentity(a) then
		local owner = a:GetOwner()

		lobby_a = IsValid(owner) and owner.lobby or a.lobby
	else
		lobby_a = a
	end

	if isentity(b) then
		local owner = b:GetOwner()

		lobby_b = IsValid(owner) and owner.lobby or b.lobby
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
