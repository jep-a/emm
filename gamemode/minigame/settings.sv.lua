MinigameSettingsService = MinigameSettingsService or {}

function MinigameSettingsService.Adjust(lobby, settings)
	for k, setting in pairs(settings) do
		local adjustable

		for _k, _setting in pairs(lobby.adjustable_settings_map) do
			if string.find(k, _k) then
				if istable(_setting) then
					for __k, _ in pairs(_setting) do
						if string.find(k, _k.."%."..__k) then
							adjustable = true

							break
						end
					end
				else
					adjustable = true

					break
				end
			end
		end

		if adjustable then
			local tab = lobby
			local exploded_k = string.Explode(".", k)

			for i, lobby_k in pairs(exploded_k) do
				if #exploded_k == i and type(tab[lobby_k]) == type(setting) then
					tab[lobby_k] = setting
				else
					tab = tab[lobby_k]
				end
			end
		end
	end
end