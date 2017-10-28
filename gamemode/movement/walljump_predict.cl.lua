WalljumpService = WalljumpService or {}


-- # Properties

function WalljumpService.InitLocalPlayerProperties(ply)
	ply.walljumps = {}
	ply.playedsounds = {}
end
hook.Add("InitLocalPlayerProperties", "WalljumpService.InitLocalPlayerProperties", WalljumpService.InitLocalPlayerProperties)


-- # Prediction

function WalljumpService.IsCooledDown(ply)
	if not ply.walljumps[CurTime()] then
		ply.walljumps[CurTime()] = ply.last_walljump_time
	end

	return CurTime() > (ply.walljumps[CurTime()] + ply.walljump_delay)
end

function WalljumpService.PlayedSound(ply)
	if ply.playedsounds[CurTime()] == nil then
		ply.playedsounds[CurTime()] = true
		return false
	end

	return ply.playedsounds[CurTime()]
end

function WalljumpService.PredictionCleanup()
	local ply = LocalPlayer()
	local cuttoff = CurTime() - ply.walljump_delay

	for i, t in pairs(ply.walljumps) do
		if i < cuttoff then
			ply.walljumps[i] = nil
		end
	end

	for i, t in pairs(ply.playedsounds) do
		if i < cuttoff then
			ply.playedsounds[i] = nil
		end
	end
end
hook.Add("Think", "WalljumpService.PredictionCleanup", WalljumpService.PredictionCleanup)