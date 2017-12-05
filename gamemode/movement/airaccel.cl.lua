AiraccelService = AiraccelService or {}


-- # Time Mapped Variables

local has_stamina = has_stamina or TimeAssociatedMapService.CreateMap(2, function() return LocalPlayer().stamina.airaccel:HasStamina() end)
local last_stamina_reduced = last_stamina_reduced or TimeAssociatedMapService.CreateMap(2, function() return 0 end)

-- # Prediction handling

function AiraccelService.HasStamina(ply)
	return has_stamina:Value() 
end

function AiraccelService.ReduceStamina(ply, value)
	ply.stamina.airaccel:ReduceStamina(value - last_stamina_reduced:Value())
	last_stamina_reduced:Set(value)
end