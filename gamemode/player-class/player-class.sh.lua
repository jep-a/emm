PlayerClassService = PlayerClassService or {}

function PlayerClassService.MinigamePlayerClass(ply, id_or_key)
	for _, ply_class in pairs(ply.lobby.player_classes) do
		if id_or_key == ply_class.id or id_or_key == ply_class.key then
			return ply_class
		end
	end
end