AiraccelService = AiraccelService or {}


-- # Prediction handling

function AiraccelService.HasStamina(ply)
	return ply.stamina.airaccel:HasStamina()
end

function AiraccelService.ReduceStamina(ply, value)
	ply.stamina.airaccel:ReduceStamina(value)
end