SpectateService = SpectateService or {}


-- # Properties

function SpectateService.InitPlayerProperties(ply)
	ply.can_spectate = true
	ply.spectate_obs_mode = OBS_MODE_IN_EYE
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
		if string.find(string.lower(" "..v:Nick()), name:lower()) then
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

	if ply.can_spectate and not ply.spectating and CurTime() > ply.spectate_timeout then
		if target then
			if ply:GetObserverMode() == OBS_MODE_NONE then
				if target == ply then
					ply:ChatPrint "You can't spectate yourself."

					return
				end

				if ply.lobby then
					ply.lobby:RemovePlayer(ply)
				end

				ply.spectating = true
				ply.spectate_timeout = CurTime() + 1

				table.insert(target.spectators, ply)

				GhostService.Ghost(ply, {
					kill = true,
					ragdoll = true,
					statue = true,
					savepoint = {
						health = true
					}
				})

				ply:SpectateEntity(target)
				ply:Spectate(ply.spectate_obs_mode)

				SpectateService.SendSpectateKeys(target.buttons, ply)
				StaminaService.SendStamina(ply, target, "airaccel")
			end
		else
			ply:ChatPrint "Player not found."
		end
	end
end
concommand.Add("sv_emm_spectate", SpectateService.Spectate)

function SpectateService.UnSpectate(ply)
	if ply.spectating then
		ply.spectating = false

		table.RemoveByValue(ply:GetObserverTarget().spectators, ply)

		ply:UnSpectate()
		ply:Spawn()

		GhostService.UnGhost(ply)
	end
end
concommand.Add("emm_unspectate", SpectateService.UnSpectate)
hook.Add("LobbyPlayerJoin", "SpectateService.UnSpectate", SpectateService.UnSpectate)
hook.Add("FinishPlayerClass", "SpectateService.UnSpectate", SpectateService.UnSpectate)

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

function SpectateService.CanSuicide(ply)
	return ply:GetObserverMode() == OBS_MODE_NONE
end
hook.Add("CanPlayerSuicide", "SpectateService.CanSuicide", SpectateService.CanSuicide)