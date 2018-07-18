SpectateService = SpectateService or {}
util.AddNetworkString("Spectate Keys Update")


-- # Properties

function SavepointService.InitPlayerProperties(ply)
	ply.spectate_savepoint = ply.spectate_savepoint or nil
	ply.spectate_obs_mode = OBS_MODE_CHASE
	ply.spectate_timeout = 0
	ply.spectators = {}
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

	if ply.spectate_timeout > CurTime() then
		return
	end

	if not other then
		ply:ChatPrint("Player not found.")
		return
	end

	if ply:GetObserverMode() == OBS_MODE_NONE then
		if not ply:IsOnGround() then
			ply:ChatPrint("You can't spectate in the air.")
			return
		end
		
		ply.spectate_savepoint = SavepointService.CreateSavepoint(ply)
	end
	
	ply:SpectateEntity(other)
	ply:Spectate(ply.spectate_obs_mode)
	ply.spectate_timeout = CurTime() + 1
	table.insert(other.spectators, ply)
end
concommand.Add("emm_spectate", SpectateService.Spectate)

function SpectateService.Unspectate(ply)
	if ply:GetObserverMode() != OBS_MODE_NONE then
		table.RemoveByValue(ply:GetObserverTarget().spectators, ply)
		ply:UnSpectate()
		SavepointService.LoadSavepoint(ply, ply.spectate_savepoint)
	end
end
concommand.Add("emm_unspectate", SpectateService.Unspectate)

function SpectateService.HandleDisconnect(ply)
	if ply:GetObserverMode() != OBS_MODE_NONE then
		SpectateService.Unspectate(ply)
	end

	for _, v in pairs(ply.spectators) do
		SpectateService.Unspectate(v)
	end
end
hook.Add("PlayerDisconnected", "SpectateService.HandleDisconnect", SpectateService.HandleDisconnect)


-- # Button Networking

function SpectateService.UpdateButtons(ply, cmovedata)
	local buttons = cmovedata:GetButtons()

	if buttons != ply.buttons then
		ply.buttons = buttons	
		net.Start("Spectate Keys Update")
		net.WriteUInt(buttons, 24)
		net.Send(ply.spectators)
	end
end
hook.Add("FinishMove", "SpectateService.UpdateButtons", SpectateService.UpdateButtons)
