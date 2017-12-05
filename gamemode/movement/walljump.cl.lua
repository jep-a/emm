WalljumpService = WalljumpService or {}


-- # Time Mapped Variables

local last_walljump_time = last_walljump_time or TimeAssociatedMapService.CreateMap(2, function() return LocalPlayer().last_walljump_time end)
local played_sound = played_sound or TimeAssociatedMapService.CreateMap(2, function() return true end)


-- # Client-side prediction

function WalljumpService.CooledDown(ply)
	return CurTime() > (last_walljump_time:Value() + ply.walljump_delay)
end

function WalljumpService.PlayedSound(ply)
	return played_sound:HasChecked() or not played_sound:Value()
end