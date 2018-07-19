SpectateService = SpectateService or {}
util.AddNetworkString("SpectateKeys")


-- # Properties

function SpectateService.InitPlayerProperties(ply)
	ply.spectate_obs_mode = OBS_MODE_CHASE
	ply.spectate_timeout = 0
	ply.spectators = {}
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"SpectateService.InitPlayerProperties",
	SpectateService.InitPlayerProperties
)


-- # Util

function SpectateService.FindPlayerByName(name)
	for _, v in pairs(player.GetAll()) do
		if v:GetName() == name then
			return v
		end
	end
end

function SpectateService.SendSpectateKeys(buttons, players)
	net.Start("SpectateKeys")
	net.WriteUInt(buttons, 24)
	net.Send(players)
end


-- # Spectate

function SpectateService.Spectate(ply, cmd, args)
	local target = SpectateService.FindPlayerByName(args[1])

	if ply.spectate_timeout > CurTime() then
		return
	end

	if not target then
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

	ply:SpectateEntity(target)
	ply:Spectate(ply.spectate_obs_mode)
	ply.spectate_timeout = CurTime() + 1
	SpectateService.SendSpectateKeys(target.buttons, ply)
	table.insert(target.spectators, ply)
end
concommand.Add("emm_spectate", SpectateService.Spectate)

function SpectateService.UnSpectate(ply)
	if ply:GetObserverMode() != OBS_MODE_NONE then
		table.RemoveByValue(ply:GetObserverTarget().spectators, ply)
		ply:UnSpectate()
		SavepointService.LoadSavepoint(ply, ply.spectate_savepoint)
	end
end
concommand.Add("emm_unspectate", SpectateService.UnSpectate)

function SpectateService.HandleDisconnect(ply)
	if ply:GetObserverMode() != OBS_MODE_NONE then
		SpectateService.UnSpectate(ply)
	end

	for _, v in pairs(ply.spectators) do
		SpectateService.UnSpectate(v)
	end
end
hook.Add("PlayerDisconnected", "SpectateService.HandleDisconnect", SpectateService.HandleDisconnect)


-- # Button Networking

function SpectateService.UpdateSpectateKeys(ply, move)
	local buttons = move:GetButtons()

	if buttons != ply.buttons then
		ply.buttons = buttons
		SpectateService.SendSpectateKeys(buttons, ply.spectators)
	end
end
hook.Add("FinishMove", "SpectateService.UpdateSpectateKeys", SpectateService.UpdateSpectateKeys)
