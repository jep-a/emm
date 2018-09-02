MinigameModifierService = MinigameModifierService or {}

function MinigameModifierService.ModifyVars(lobby, vars)
	for k, v in pairs(vars) do
		local modifiable

		for _k, _v in pairs(lobby.modifiable_vars_map) do
			if string.find(k, _k) then
				if istable(_v) then
					for __k, _ in pairs(_v) do
						if string.find(k, _k.."%."..__k) then
							modifiable = true

							break
						end
					end
				else
					modifiable = true

					break
				end
			end
		end

		if modifiable then
			local var = lobby
			local exploded_k = string.Explode(".", k)

			for i, lobby_k in pairs(exploded_k) do
				if #exploded_k == i and type(var[lobby_k]) == type(v) then
					var[lobby_k] = v
				else
					var = var[lobby_k]
				end
			end
		end
	end
end