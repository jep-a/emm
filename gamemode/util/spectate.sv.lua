SpectateService = SpectateService or {}


-- # Properties

function SavepointService.InitPlayerProperties(ply)
	ply.spectate_savepoint = ply.spectate_savepoint or nil
	ply.spectate_obs_mode = OBS_MODE_CHASE
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"SavepointService.InitPlayerProperties",
	SavepointService.InitPlayerProperties
)


-- # Util

function SpectateService.FindPlayerByName(name)
	for k, v in pairs(player.GetAll()) do
		if v:GetName() == name then
			return v
		end
	end

	return nil
end


-- # Spectate

function SpectateService.Spectate(ply, cmd, args)
	other = SpectateService.FindPlayerByName(args[1])

	if not other then
		ply:ChatPrint("Player not found.")
		return
	end

	if not ply:IsOnGround() then
		ply:ChatPrint("You can't spectate in the air.")
		return
	end

	ply.spectate_savepoint = SavepointService.CreateSavepoint(ply)
	ply:SpectateEntity(cmd)
	ply:Spectate(ply.spectate_obs_mode)
end
concommand.Add("emm_spectate", SpectateService.Spectate)

function SpectateService.Unspectate(ply, cmd, args)
	if ply:GetObserverMode() then
		ply:UnSpectate()
		SavepointService.LoadSavepoint(ply, ply.spectate_savepoint)
	end
end
concommand.Add("emm_unspectate", SpectateService.Unspectate)
