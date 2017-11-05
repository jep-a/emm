PredictedSoundsService = PredictedSoundsService or {}


-- # Sound Services

function PredictedSoundsService.PlaySound(ply, sound_file, soundLevel, pitchPercent, volume, channel)
	ply:EmitSound(sound_file, soundLevel, pitchPercent, volume, channel)
end