AiraccelService = AiraccelService or {}
AiraccelService.has_stamina = AiraccelService.has_stamina or TimeAssociatedMapService.CreateMap(2, function() return LocalPlayer().stamina.airaccel:HasStamina() end)
AiraccelService.last_stamina_reduced = AiraccelService.last_stamina_reduced or TimeAssociatedMapService.CreateMap(2, function() return 0 end)

-- # Prediction handling

function AiraccelService.HasStamina(ply)
	return AiraccelService.has_stamina:Value() 
end

function AiraccelService.ReduceStamina(ply, value)
	ply.stamina.airaccel:ReduceStamina(value - AiraccelService.last_stamina_reduced:Value())
	AiraccelService.last_stamina_reduced:Set(value)
end