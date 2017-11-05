WalljumpService = WalljumpService or {}


-- # Server Functions

function WalljumpService.CooledDown(ply)
	return CurTime() > (ply.last_walljump_time + ply.walljump_delay)
end

function WalljumpService.PlayedSound(ply)
	return IsFirstTimePredicted()
end