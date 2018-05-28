PlayerClassService = PlayerClassService or {}

function PlayerClassService.MinigamePlayerClass(ply, id)
	for _, ply_class in pairs(ply.lobby.player_classes) do
		if id == ply_class.id then
			return ply_class
		end
	end
end