WalljumpService = WalljumpService or {}
WalljumpService.last_walljump_time = WalljumpService.last_walljump_time or TimeAssociatedMapService.CreateMap(2, function() return LocalPlayer().last_walljump_time end)
WalljumpService.played_sound = WalljumpService.played_sound or TimeAssociatedMapService.CreateMap(2, function() return true end)


-- # Client-side prediction

function WalljumpService.CooledDown(ply)
	return CurTime() > (WalljumpService.last_walljump_time:Value() + ply.walljump_delay)
end

function WalljumpService.PlayedSound(ply)
	return WalljumpService.played_sound:HasChecked() or not WalljumpService.played_sound:Value()
end