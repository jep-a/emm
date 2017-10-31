PredictedSoundsService = PredictedSoundsService or {}


-- # Properties

function PredictedSoundsService.InitLocalPlayerProperties(ply)
	ply.sound_emitter = ClientsideModel("models/hunter/blocks/cube025x025x025.mdl")
	ply.sound_emitter:SetPos(ply:GetShootPos())
	ply.sound_emitter:SetNoDraw(true)
	ply.sound_emitter:SetParent(ply)
end
hook.Add("InitLocalPlayerProperties", "PredictedSoundsService.InitLocalPlayerProperties", PredictedSoundsService.InitLocalPlayerProperties)


-- # Sound Services

function PredictedSoundsService.PlaySound(ply, sound_file)
	CreateSound(ply.sound_emitter, sound_file):Play()
end