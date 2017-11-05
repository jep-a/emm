WalljumpService = WalljumpService or {}


-- # Server-side prediction

function WalljumpService.CooledDown(ply)
	return CurTime() > (ply.last_walljump_time + ply.walljump_delay)
end

function WalljumpService.PlayedSound(ply)
	return not IsFirstTimePredicted()
end