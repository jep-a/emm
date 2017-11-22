PredictedSoundService = PredictedSoundService or {}
PredictedSoundService.Cache = PredictedSoundService.Cache or {}

function PredictedSoundService.PlaySound(ply, sound_file, soundLevel, pitchPercent, volume, channel)
	ply:EmitSound(sound_file, soundLevel, pitchPercent, volume, channel)
end

function PredictedSoundService.PlayWallslideSound(ply)
	if PredictedSoundService.Cache[ply.wallslide_sound_file] == nil then
		if ply.wallslide_sound and ply.wallslide_sound:IsPlaying() then
			ply.wallslide_sound:Stop()
		end
		
		PredictedSoundService.Cache[ply.wallslide_sound_file] = CreateSound(ply, ply.wallslide_sound_file)
	end
	
	ply.wallslide_sound = PredictedSoundService.Cache[ply.wallslide_sound_file]
	ply.wallslide_sound:Play()
end

function PredictedSoundService.StopWallslideSound(ply)
	ply.wallslide_sound:ChangeVolume(0, 0.25)
end