SoundsService = SoundsService or {}


-- # Properties

function SoundsService.InitPlayerProperties(ply)
	ply.sounds = ply.sounds or {}
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"SoundsService.InitPlayerProperties",
	SoundsService.InitPlayerProperties
)


-- # Functions

function SoundsService.PlaySoundOnPlayer(ply, sound_file)
	if ply.sounds[sound_file] then
		ply.sounds[sound_file]:Stop()
	end

	SoundsService.UpdateSoundOnPlayer(ply, sound_file)
	ply.sounds[sound_file]:Play()
end


-- # Utility Functions

function SoundsService.UpdateSoundOnPlayer(ply, sound_file)
	ply.sounds[sound_file] = (CLIENT and ply.sounds[sound_file]) and ply.sounds[sound_file] or CreateSound(ply, sound_file, SoundsService.GetExclusiveFilter(ply))
end

function SoundsService.GetExclusiveFilter(ply)
	local filter = nil

	if SERVER then
		filter = RecipientFilter()
		filter:AddAllPlayers()
		filter:RemovePlayer(ply)
	end

	return filter
end
