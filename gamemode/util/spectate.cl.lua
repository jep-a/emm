SpectateService = SpectateService or {}
SpectateService.unspectate_keys = bit.bor(IN_JUMP, IN_MOVELEFT, IN_MOVERIGHT, IN_FORWARD, IN_BACK)
SpectateService.buttons = 0


-- # Utils

function SpectateService.AutoComplete(cmd, args)
	local tbl = {}

	for _, v in pairs(player.GetAll()) do
		if string.find(string.lower(" " .. v:Nick()), args:lower()) then
			table.insert(tbl, "emm_spectate " .. v:Nick())
		end
	end

	return tbl
end


-- # Spectating

concommand.Add("emm_spectate", function(ply, cmd, args)
	RunConsoleCommand("sv_emm_spectate", unpack(args))
end, SpectateService.AutoComplete)

function SpectateService.TargetKeyDown(key)
	return bit.band(SpectateService.buttons, key)
end

function SpectateService.UnSpectateCheck(ply, key)
	if
		IsFirstTimePredicted() and
		ply:GetObserverMode() ~= 0 and
		bit.band(SpectateService.unspectate_keys, key) ~= 0
	then
		SpectateService.buttons = 0
		ply:ConCommand "emm_unspectate"
	end
end
hook.Add("KeyPress", "SpectateService.UnSpectateCheck", SpectateService.UnSpectateCheck)

function SpectateService.SpectateMode(ply, key)
	if
		IsFirstTimePredicted() and
		ply:GetObserverMode() ~= 0 and
		key == IN_ATTACK
	then
		local obs_mode = OBS_MODE_IN_EYE

		if ply:GetObserverMode() == obs_mode then
			obs_mode = OBS_MODE_CHASE
		end

		ply:SetObserverMode(obs_mode)
	end
end
hook.Add("KeyPress", "SpectateService.SpectateMode", SpectateService.SpectateMode)

function SpectateService.UpdateSpectateKeys()
	SpectateService.buttons = net.ReadUInt(24)
end
net.Receive("SpectateKeys", SpectateService.UpdateSpectateKeys)
