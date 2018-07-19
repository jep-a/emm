PlayerClassService = PlayerClassService or {}

function PlayerClassService.ReloadPlayerClasses()
	for _, ply in pairs(player.GetAll()) do
		if ply.player_class then
			ply.player_class = MinigameService.prototypes[ply.lobby.prototype.key].player_classes[ply.player_class.key]
		end
	end
end
hook.Add("OnReloaded", "PlayerClassService.ReloadPlayerClasses", PlayerClassService.ReloadPlayerClasses)