AiraccelService = AiraccelService or {}


-- # Prediction handling

function AiraccelService.HasStamina(ply)
	return ply.stamina.airaccel:HasStamina()
end