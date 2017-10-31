WalljumpService = WalljumpService or {}


-- # Properties

function WalljumpService.InitLocalPlayerProperties(ply)
	ply.walljumps = {}
	ply.played_sounds = {}
end
hook.Add("InitLocalPlayerProperties", "WalljumpService.InitLocalPlayerProperties", WalljumpService.InitLocalPlayerProperties)


-- # Client Functions

function WalljumpService.CooledDown(ply)
	if not ply.walljumps[CurTime()] then
		ply.walljumps[CurTime()] = ply.last_walljump_time
	end

	return CurTime() > (ply.walljumps[CurTime()] + ply.walljump_delay)
end

function WalljumpService.PlayedSound(ply)
	if ply.played_sounds[CurTime()] == nil then
		ply.played_sounds[CurTime()] = true
		return false
	end

	return ply.played_sounds[CurTime()]
end


-- # Cleanup

function WalljumpService.PredictionCleanup()
	local ply = LocalPlayer()
	local cuttoff = CurTime() - ply.walljump_delay

	for k, _ in pairs(ply.walljumps) do
		if k < cuttoff then
			ply.walljumps[k] = nil
		end
	end

	for k, _ in pairs(ply.played_sounds) do
		if k < cuttoff then
			ply.played_sounds[k] = nil
		end
	end
end
hook.Add("Think", "WalljumpService.PredictionCleanup", WalljumpService.PredictionCleanup)