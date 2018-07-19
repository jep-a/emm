SpectateService = SpectateService or {}
SpectateService.UNSPECTATE_KEYS = bit.bor(IN_JUMP, IN_MOVELEFT, IN_MOVERIGHT, IN_FORWARD, IN_BACK)

-- # Spectate

function SpectateService.UnspectateCheck(ply, key)
	if
		ply:GetObserverMode() != 0 and
		bit.band(SpectateService.UNSPECTATE_KEYS, key) != 0
	then
		ply:ConCommand("emm_unspectate")
	end
end
hook.Add("KeyPress", "SpectateService.UnspectateCheck", SpectateService.UnspectateCheck)
