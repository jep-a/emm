AiraccelService = AiraccelService or {}
AiraccelService.has_stamina = AiraccelService.has_stamina or TimeAssociatedMapService.CreateMap(2, function() return LocalPlayer().stamina.airaccel:HasStamina() end)


-- # Prediction handling

function AiraccelService.HasStamina(ply)
	return AiraccelService.has_stamina:Value()
end