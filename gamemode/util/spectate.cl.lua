SpectateService = SpectateService or {}
SpectateService.unspectate_keys = bit.bor(IN_JUMP, IN_MOVELEFT, IN_MOVERIGHT, IN_FORWARD, IN_BACK)
SpectateService.buttons = 0


-- # Util

function SpectateService.TargetKeyDown(key)
	return bit.band(SpectateService.buttons, key)
end


-- # Spectate

function SpectateService.UnSpectateCheck(ply, key)
	if
		IsFirstTimePredicted() and
		ply:GetObserverMode() != 0 and
		bit.band(SpectateService.unspectate_keys, key) != 0
	then
		ply:ConCommand("emm_unspectate")
		SpectateService.buttons = 0
	end
end
hook.Add("KeyPress", "SpectateService.UnSpectateCheck", SpectateService.UnSpectateCheck)


-- # Button Networking

function SpectateService.UpdateSpectateKeys()
	SpectateService.buttons = net.ReadUInt(24)
end
net.Receive("SpectateKeys", SpectateService.UpdateSpectateKeys)