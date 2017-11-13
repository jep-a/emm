WalljumpService = WalljumpService or {}


-- # Client-side prediction

last_walljump_time = last_walljump_time or TimeAssociatedMapService.CreateMap(2, function() return LocalPlayer().last_walljump_time end)
played_walljump_sound = played_walljump_sound or TimeAssociatedMapService.CreateMap(2, function() return true end)

function WalljumpService.CooledDown(ply)
	return CurTime() > (last_walljump_time:Value() + ply.walljump_delay)
end

function WalljumpService.PlayedSound(ply)
	return played_walljump_sound:HasChecked() or not played_walljump_sound:Value()
end