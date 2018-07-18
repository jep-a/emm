SpectateService = SpectateService or {}
SpectateService.UNSPECTATE_KEYS = bit.bor(IN_JUMP, IN_MOVELEFT, IN_MOVERIGHT, IN_FORWARD, IN_BACK)
SpectateService.buttons = 0


-- # Util
function SpectateService.TargetKeyDown(key)
	return bit.band(SpectateService.buttons, key)
end


-- # Spectate

function SpectateService.UnspectateCheck(ply, key)
	if
		IsFirstTimePredicted() and
		ply:GetObserverMode() != 0 and
		bit.band(SpectateService.UNSPECTATE_KEYS, key) != 0
	then
		ply:ConCommand("emm_unspectate")
		SpectateService.buttons = 0
	end
end
hook.Add("KeyPress", "SpectateService.UnspectateCheck", SpectateService.UnspectateCheck)


-- # Button Networking

function SpectateService.SpectateKeysUpdate()
	SpectateService.buttons = net.ReadUInt(24)
end
net.Receive("Spectate Keys Update", SpectateService.SpectateKeysUpdate)