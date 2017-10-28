WalljumpService = WalljumpService or {}


-- # Properties

function WalljumpService.InitLocalPlayerProperties(ply)
	ply.walljumps = {}
end
hook.Add("InitLocalPlayerProperties", "WalljumpService.InitLocalPlayerProperties", WalljumpService.InitLocalPlayerProperties)


-- # Prediction

function WalljumpService.IsCooledDown(ply)
	if not ply.walljumps[CurTime()] then
		ply.walljumps[CurTime()] = ply.last_walljump_time
	end
	
	return CurTime() > (ply.walljumps[CurTime()] + ply.walljump_delay)
end

function WalljumpService.ThinkCleanup()
	local ply = LocalPlayer()
	local cuttoff = CurTime() - ply.walljump_delay
	
	for i, t in pairs(ply.walljumps) do
		if i < cuttoff then
			ply.walljumps[i] = nil
		end
	end
end
hook.Add("Think", "WalljumpService.ThinkCleanup", WalljumpService.ThinkCleanup)
