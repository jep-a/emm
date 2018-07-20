PredictedSoundService = PredictedSoundService or {}
PredictedSoundService.RegisteredSounds = PredictedSoundService.RegisteredSounds or {}


-- # Server sounds

function PredictedSoundService.ExclusiveFilter(ply)
	local filter = RecipientFilter()
	filter:AddAllPlayers()
	filter:RemovePlayer(ply)

	return filter
end

function PredictedSoundService.RegisterSound(file)
	local sound_tab = {
		name = "server_predicted_sound_"..table.Count(PredictedSoundService.RegisteredSounds),
		channel = CHAN_STATIC,
		volume = 1,
		level = 80,
		pitch = {95, 110},
		sound = file
	}

	sound.Add(sound_tab)
	PredictedSoundService.RegisteredSounds[file] = sound_tab.name
end

function PredictedSoundService.PlaySound(ply, file)
	CreateSound(ply, file, PredictedSoundService.ExclusiveFilter(ply)):Play()
end

function PredictedSoundService.PlayWallslideSound(ply)
	if not PredictedSoundService.RegisteredSounds[ply.wallslide_sound_file] then
		PredictedSoundService.RegisterSound(ply.wallslide_sound_file)
	end

	if ply.wallslide_sound and ply.wallslide_sound:IsPlaying() then
		ply.wallslide_sound:Stop()
	end

	ply.wallslide_sound = CreateSound(ply, PredictedSoundService.RegisteredSounds[ply.wallslide_sound_file], PredictedSoundService.ExclusiveFilter(ply))
	ply.wallslide_sound:Play()
end

function PredictedSoundService.StopWallslideSound(ply)
	ply.wallslide_sound:FadeOut(0.25)
end