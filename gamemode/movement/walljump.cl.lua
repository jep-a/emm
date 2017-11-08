WalljumpService = WalljumpService or {}


-- # Client-side prediction

local walljumps = {}
local played_walljump_sounds = {}

function WalljumpService.CooledDown(ply)
	local cur_time = CurTime()

	if not walljumps[cur_time] then
		walljumps[cur_time] = ply.last_walljump_time
	end

	return cur_time > (walljumps[cur_time] + ply.walljump_delay)
end

function WalljumpService.PlayedSound(ply)
	local played_snd

	local cur_time = CurTime()
	if played_walljump_sounds[cur_time] then
		played_snd = true
	else
		played_walljump_sounds[cur_time] = true
		played_snd = false
	end

	return played_snd
end

function WalljumpService.CleanupPrediction()
	local cutoff = CurTime() - LocalPlayer().walljump_delay

	for k, _ in pairs(walljumps) do
		if cutoff > k then
			walljumps[k] = nil
		end
	end

	for k, _ in pairs(played_walljump_sounds) do
		if cutoff > k then
			played_walljump_sounds[k] = nil
		end
	end
end
hook.Add("Think", "WalljumpService.CleanupPrediction", WalljumpService.CleanupPrediction)