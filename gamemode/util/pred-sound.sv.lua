PredictedSoundsService = PredictedSoundsService or {}


-- # Properties

function PredictedSoundsService.InitPlayerProperties(ply)
	ply.sound_emitter = ply
end
hook.Add("InitPlayerProperties", "PredictedSoundsService.InitPlayerProperties", PredictedSoundsService.InitPlayerProperties)


-- # Utility Functions

function PredictedSoundsService.GetExclusiveFilter(ply)
	local filter = nil

	if SERVER then
		filter = RecipientFilter()
		filter:AddAllPlayers()
		filter:RemovePlayer(ply)
	end

	return filter
end


-- # Sound Services

function PredictedSoundsService.PlaySound(ply, sound_file)
	CreateSound(ply.sound_emitter, sound_file, PredictedSoundsService.GetExclusiveFilter(ply)):Play()
end