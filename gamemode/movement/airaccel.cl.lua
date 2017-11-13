AiraccelService = AiraccelService or {}


-- # Prediction handling

player_has_stamina = player_has_stamina or TimeAssociatedMapService.CreateMap(2, function() return LocalPlayer().stamina.airaccel:HasStamina() end)

function AiraccelService.HasStamina(ply)
	return player_has_stamina:Value()
end