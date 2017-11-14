PredictedSoundService = PredictedSoundService or {}

sound.Add( {
	name = "server_wallslide_sound",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = { 95, 110 },
	sound = "physics/body/body_medium_scrape_smooth_loop1.wav"
} )

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

function PredictedSoundService.PlayWallslideSound(ply)
	if ply.wallslide_sound and ply.wallslide_sound:IsPlaying() then
		ply.wallslide_sound:Stop()
	end
	
	ply.wallslide_sound = CreateSound(ply, "server_wallslide_sound", PredictedSoundService.GetExclusiveFilter(ply))
	ply.wallslide_sound:Play()
end

function PredictedSoundService.StopWallslideSound(ply)
	ply.wallslide_sound:FadeOut(0.25)
end