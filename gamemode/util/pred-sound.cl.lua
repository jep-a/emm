PredictedSoundService = PredictedSoundService or {}

function PredictedSoundService.InitPlayerProperties(ply)
	ply.predicted_sound_emitter = ClientsideModel("models/hunter/blocks/cube025x025x025.mdl")
	ply.predicted_sound_emitter:SetPos(ply:GetShootPos())
	ply.predicted_sound_emitter:SetNoDraw(true)
	ply.predicted_sound_emitter:SetParent(ply)
end
hook.Add("InitLocalPlayerProperties", "PredictedSoundService.InitPlayerProperties", PredictedSoundService.InitPlayerProperties)

function PredictedSoundService.PlaySound(ply, sound_file)
	CreateSound(ply.predicted_sound_emitter, sound_file):Play()
end