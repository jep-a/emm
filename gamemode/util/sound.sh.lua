SoundsService = SoundsService or {}


-- # Properties

function SoundsService.InitPlayerProperties(ply)
	ply.sound_emitter = ply
end
hook.Add("InitPlayerProperties", "SoundsService.InitPlayerProperties", SoundsService.InitPlayerProperties)

function SoundsService.InitLocalPlayerProperties(ply)
	ply.sound_emitter = ClientsideModel("models/hunter/blocks/cube025x025x025.mdl")
	ply.sound_emitter:SetPos(ply:GetShootPos())
	ply.sound_emitter:SetNoDraw(true)
	ply.sound_emitter:SetParent(ply)
end
hook.Add("InitLocalPlayerProperties", "SoundsService.InitLocalPlayerProperties", SoundsService.InitLocalPlayerProperties)


-- # Sound Services

function SoundsService.PlaySoundShared(ply, sound_file)
	CreateSound(ply.sound_emitter, sound_file, SoundsService.GetExclusiveFilter(ply)):Play()
end


-- # Utility Functions

function SoundsService.GetExclusiveFilter(ply)
	local filter = nil

	if SERVER then
		filter = RecipientFilter()
		filter:AddAllPlayers()
		filter:RemovePlayer(ply)
	end

	return filter
end