PredictedSoundService = PredictedSoundService or {}
PredictedSoundService.RegisteredSounds = PredictedSoundService.RegisteredSounds or {}


-- # Server Sounds

function PredictedSoundService.GetExclusiveFilter(ply)
	local filter = RecipientFilter()
	filter:AddAllPlayers()
	filter:RemovePlayer(ply)
	return filter
end

function PredictedSoundService.RegisterSound(sound_file)
	local sound_table = {
		name = "server_predicted_sound_" .. table.Count(PredictedSoundService.RegisteredSounds),
		channel = CHAN_STATIC,
		volume = 1.0,
		level = 80,
		pitch = { 95, 110 },
		sound = sound_file
	}

	sound.Add(sound_table)
	PredictedSoundService.RegisteredSounds[sound_file] = sound_table.name
end

function PredictedSoundService.PlaySound(ply, sound_file)
	CreateSound(ply, sound_file, PredictedSoundService.GetExclusiveFilter(ply)):Play()
end

function PredictedSoundService.PlayWallslideSound(ply)
	if not PredictedSoundService.RegisteredSounds[ply.wallslide_sound_file] then
		PredictedSoundService.RegisterSound(ply.wallslide_sound_file)
	end

	if ply.wallslide_sound and ply.wallslide_sound:IsPlaying() then
		ply.wallslide_sound:Stop()
	end
	
	ply.wallslide_sound = CreateSound(ply, PredictedSoundService.RegisteredSounds[ply.wallslide_sound_file], PredictedSoundService.GetExclusiveFilter(ply))
	ply.wallslide_sound:Play()
end

function PredictedSoundService.StopWallslideSound(ply)
	ply.wallslide_sound:FadeOut(0.25)
end