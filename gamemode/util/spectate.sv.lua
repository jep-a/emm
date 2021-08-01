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

util.AddNetworkString "SpectateKeys"

function SpectateService.SendSpectateKeys(buttons, players)
	net.Start "SpectateKeys"
	net.WriteUInt(buttons, 24)
	net.Send(players)
end


-- # Hooks

function SpectateService.Spectate(ply, target)
	if ply.can_spectate and CurTime() > ply.spectate_timeout then
		if target then
			if ply:GetObserverMode() == OBS_MODE_NONE then
				if not ply:IsOnGround() then
					ply:ChatPrint("You can't spectate in the air.")
					return
				end

				if ply:Crouching() then
					ply:ChatPrint("You can't spectate while crouching.")
					return
				end

				if target == ply then
					ply:ChatPrint("You can't spectate yourself.")
					return
				end

				ply.spectate_savepoint = SavepointService.CreateSavepoint(ply)
			end

			table.insert(target.spectators, ply)
			ply:SpectateEntity(target)
			ply:Spectate(ply.spectate_obs_mode)
			ply.spectate_timeout = CurTime() + 1
			TrailService.RemoveTrail(ply)
			SpectateService.SendSpectateKeys(target.buttons, ply)
			StaminaService.SendStamina(ply, target, "airaccel")
		else
			ply:ChatPrint("Player not found.")
		end
	end
end
CommandService.AddCommand({name = "spectate", varargs = {"player"}, callback = SpectateService.Spectate})

function SpectateService.UnSpectate(ply)
	if ply:GetObserverMode() ~= OBS_MODE_NONE then
		local health = ply:Health()

		table.RemoveByValue(ply:GetObserverTarget().spectators, ply)
		TrailService.SetupTrail(ply)
		ply:UnSpectate()
		ply:Spawn()
		ply:SetHealth(health)
		SavepointService.LoadSavepoint(ply, ply.spectate_savepoint)
		ply:SetVelocity(Vector(0,0,0))
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

function SpectateService.CanSuicide(ply)
	return ply:GetObserverMode() == OBS_MODE_NONE
end
hook.Add("CanPlayerSuicide", "SpectateService.CanSuicide", SpectateService.CanSuicide)