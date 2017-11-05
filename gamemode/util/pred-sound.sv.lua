PredictedSoundService = PredictedSoundService or {}

function PredictedSoundService.InitPlayerProperties(ply)
	ply.predicted_sound_emitter = ply
end
hook.Add("InitPlayerProperties", "PredictedSoundService.InitPlayerProperties", PredictedSoundService.InitPlayerProperties)

function PredictedSoundService.GetExclusiveFilter(ply)
	local filter = RecipientFilter()
	filter:AddAllPlayers()
	filter:RemovePlayer(ply)
	return filter
end

function PredictedSoundService.PlaySound(ply, sound_file)
	CreateSound(ply.predicted_sound_emitter, sound_file, PredictedSoundService.GetExclusiveFilter(ply)):Play()
end