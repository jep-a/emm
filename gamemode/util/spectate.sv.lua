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

	if ply.can_spectate and CurTime() > ply.spectate_timeout then
		if target then
			if ply:GetObserverMode() == OBS_MODE_NONE then
				if not ply:IsOnGround() then
					ply:ChatPrint "You can't spectate in the air."

					return
				end

				if ply:Crouching() then
					ply:ChatPrint "You can't spectate while crouching."

					return
				end

				if target == ply then
					ply:ChatPrint "You can't spectate yourself."

					return
				end

				ply.spectating = true
				ply.spectate_savepoint = SavepointService.CreateSavepoint(ply)
				ply.spectate_timeout = CurTime() + 1

				table.insert(target.spectators, ply)

				GhostService.Ghost(ply, {
					ragdoll = true,
					freeze = true
				})

				ply:KillSilent()
				ply:SpectateEntity(target)
				ply:Spectate(ply.spectate_obs_mode)

				SpectateService.SendSpectateKeys(target.buttons, ply)
				StaminaService.SendStamina(ply, target, "airaccel")
				TrailService.RemoveTrail(ply)
			end
		else
			ply:ChatPrint "Player not found."
		end
	end
end
concommand.Add("sv_emm_spectate", SpectateService.Spectate)

function SpectateService.UnSpectate(ply)
	if ply:GetObserverMode() ~= OBS_MODE_NONE then
		local health = ply:Health()

		ply.spectating = false

		table.RemoveByValue(ply:GetObserverTarget().spectators, ply)

		TrailService.SetupTrail(ply)

		ply:UnSpectate()
		ply:Spawn()
		ply:SetHealth(health)

		GhostService.UnGhost(ply)
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