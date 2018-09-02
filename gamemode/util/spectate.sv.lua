SpectateService = SpectateService or {}


-- # Properties

function SpectateService.InitPlayerProperties(ply)
	ply.spectate_obs_mode = OBS_MODE_CHASE
	ply.spectate_timeout = 0
	ply.spectators = ply.spectators or {}
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

util.AddNetworkString "SpectateKeys"

function SpectateService.SendSpectateKeys(buttons, players)
	net.Start "SpectateKeys"
	net.WriteUInt(buttons, 24)
	net.Send(players)
end


-- # Hooks

function SpectateService.Spectate(ply, cmd, args)
	local target = SpectateService.FindPlayerByName(args[1])

	if CurTime() > ply.spectate_timeout then
		if target then
			if ply:GetObserverMode() == OBS_MODE_NONE then
				if not ply:IsOnGround() then
					ply:ChatPrint("You can't spectate in the air.")

					return
				end

				ply.spectate_savepoint = SavepointService.CreateSavepoint(ply)
			end

			table.insert(target.spectators, ply)
			ply:SpectateEntity(target)
			ply:Spectate(ply.spectate_obs_mode)
			ply.spectate_timeout = CurTime() + 1
			SpectateService.SendSpectateKeys(target.buttons, ply)
		else
			ply:ChatPrint("Player not found.")
		end
	end
end
concommand.Add("emm_spectate", SpectateService.Spectate)

function SpectateService.UnSpectate(ply)
	if ply:GetObserverMode() ~= OBS_MODE_NONE then
		table.RemoveByValue(ply:GetObserverTarget().spectators, ply)
		ply:UnSpectate()
		SavepointService.LoadSavepoint(ply, ply.spectate_savepoint)
	end
end
concommand.Add("emm_unspectate", SpectateService.UnSpectate)

function SpectateService.HandleDisconnect(ply)
	if ply:GetObserverMode() ~= OBS_MODE_NONE then
		SpectateService.UnSpectate(ply)
	end

	for _, spectator in pairs(ply.spectators) do
		SpectateService.UnSpectate(spectator)
	end
end
hook.Add("PlayerDisconnected", "SpectateService.HandleDisconnect", SpectateService.HandleDisconnect)

function SpectateService.UpdateSpectateKeys(ply, move)
	local buttons = move:GetButtons()

	if buttons ~= ply.buttons then
		ply.buttons = buttons
		SpectateService.SendSpectateKeys(buttons, ply.spectators)
	end
end
hook.Add("FinishMove", "SpectateService.UpdateSpectateKeys", SpectateService.UpdateSpectateKeys)
