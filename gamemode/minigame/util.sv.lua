function MinigameService.ClearPlayerClasses(plys)
	for _, ply in pairs(plys) do
		if ply.player_class then
			ply:ClearPlayerClass()
		end
	end
end

function MinigameService.PickRandomPlayerClasses(plys, ply_count, ply_class, def_class, less_prob_plys, less_prob)
	ply_count = ply_count or 1
	less_prob = less_prob or 0.33

	local random_plys = {}
	while #random_plys < ply_count do
		local ply = plys[math.random(1, #plys)]
		if not table.HasValue(random_plys, ply) then
			if less_prob_plys and table.HasValue(less_prob_plys, ply) then
				if math.random() > less_prob then
					table.insert(random_plys, ply)
				end
			else
				table.insert(random_plys, ply)
			end
		end
	end

	for _, ply in pairs(plys) do
		if table.HasValue(random_plys, ply) then
			ply:SetPlayerClass(ply_class)
		elseif def_class then
			ply:SetPlayerClass(def_class)
		end
	end

	return random_plys
end