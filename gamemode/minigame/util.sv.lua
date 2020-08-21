function MinigameService.ClearPlayerClasses(lobby)
	for _, ply in pairs(lobby.players) do
		if ply.player_class then
			ply:ClearPlayerClass()
		end
	end
end

function MinigameService.ClearEntities(lobby)
	for _, ent in pairs(lobby.entities) do
		ent:Remove()
	end
end

function MinigameService.PickRandomPlayerClasses(lobby, props)
	props = props or {}

	local ply_count = props.count or 1

	local ply_classes = lobby.player_classes
	local class = ply_classes[props.class_key]
	local rejected_class = ply_classes[props.rejected_class_key]

	local less_prob_plys = props.less_probable_players
	local less_prob_ply_chance = props.less_probable_player_chance or 0.33

	local plys = MinigameService.FilterPlayers(lobby, props)
	local picked_plys = {}
	local rejected_plys = {}

	while #picked_plys < ply_count do
		local ply = plys[math.random(1, #plys)]

		if not table.HasValue(picked_plys, ply) then
			if less_prob_plys and table.HasValue(less_prob_plys, ply) then
				if math.random() > less_prob_ply_chance then
					table.insert(picked_plys, ply)
				end
			else
				table.insert(picked_plys, ply)
			end
		end
	end

	for _, ply in pairs(plys) do
		if table.HasValue(picked_plys, ply) then
			ply:SetPlayerClass(class)
		elseif rejected_class then
			table.insert(rejected_plys, ply)
			ply:SetPlayerClass(rejected_class)
		end
	end

	return picked_plys, rejected_plys
end

function MinigameService.PickClosestPlayerClass(lobby, origin_ply, props)
	props = props or {}

	local ply_classes = lobby.player_classes

	local origin_ply_class = ply_classes[props.origin_player_class_key]

	if origin_ply_class then
		origin_ply:SetPlayerClass(origin_ply_class)
	end

	local closest_ply = MinigameService.ClosestPlayer(lobby, origin_ply, props)

	if closest_ply then
		if ply_classes[props.class_key] then
			closest_ply:SetPlayerClass(ply_classes[props.class_key])
		elseif props.swap_player_class then
			MinigameService.SwapPlayerClass(origin_ply, closest_ply)
		end
	end

	return closest_ply
end

function MinigameService.SwapPlayerClass(ply_a, ply_b, kill_ply_a, kill_ply_b)
	local class_a = ply_a.player_class
	local class_b = ply_b.player_class

	ply_a:SetPlayerClass(class_b)
	ply_b:SetPlayerClass(class_a)

	if kill_ply_a then
		ply_a:Kill()
	end

	if kill_ply_b then
		ply_b:Kill()
	end
end