PlayerClassService = PlayerClassService or {}

function PlayerClassService.MinigamePlayerClass(ply, id_or_key)
	for _, ply_class in pairs(ply.lobby.player_classes) do
		if id_or_key == ply_class.id or id_or_key == ply_class.key then
			return ply_class
		end
	end
end

function PlayerClassService.ReloadPlayerClasses()
	for _, ply in pairs(player.GetAll()) do
		if ply.player_class then
			ply.player_class = MinigameService.prototypes[ply.lobby.prototype.key].player_classes[ply.player_class.key]
		end
	end
end
hook.Add("OnReloaded", "PlayerClassService.ReloadPlayerClasses", PlayerClassService.ReloadPlayerClasses)