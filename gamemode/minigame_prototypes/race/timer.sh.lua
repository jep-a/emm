MINIGAME.START_KEYS = {
	[1] = IN_FORWARD,
	[2] = IN_BACK,
	[3] = IN_MOVERIGHT,
	[4] = IN_MOVELEFT,
	[5] = IN_JUMP,
	[6] = IN_ATTACK,
	[7] = IN_DUCK
}


-- # Leaderboard

function MINIGAME.UpdateLeaderboard(ply, mode, time)
	if not ply.lobby.leaderboard[mode] then
		ply.lobby.leaderboard[mode] = {}
	else
		local steam_id = ply:EntIndex()
		local personal_record = MINIGAME.GetPR(ply, mode)
		
		if personal_record >= time or personal_record == 0 then
			ply.lobby.leaderboard[mode][steam_id] = {
				["time"] = time,
				["name"] = ply:Nick()
			}
		end
	end
end

function MINIGAME.GetPR(ply, mode)
	local steam_id = ply:EntIndex()
	
	if ply.lobby.leaderboard[mode] then
		if ply.lobby.leaderboard[mode][steam_id] then
			return ply.lobby.leaderboard[mode][steam_id].time
		end
	end
	
	return 0
end

function MINIGAME.GetPlacement(lobby, mode, ply)
	if lobby.leaderboard[mode] then
		local steam_id = ply:EntIndex()
		
		if lobby.leaderboard[mode][steam_id] then
			table.sort(lobby.leaderboard[mode], function(a, b) return a.time > b.time end)
			PrintTable(lobby.leaderboard[mode])
			--return lobby.leaderboard[mode][placement],
		end
	end
	
	return 0
end

function MINIGAME.GetBest(lobby, mode)
	if lobby.leaderboard[mode] then
		local time = 0
		local steam_id
		local nick
		
		for k, v in pairs(lobby.leaderboard[mode]) do
			if time > v.time or time == 0 then
				time = v.time
				steam_id = k
				nick = v.name
			end
		end
		
		return time, steamid, nick
	end
	
	return 0
end

function MINIGAME.RemoveFromLeaderboard(steam_id, mode)
	if ply.lobby.leaderboard[mode] then
		if ply.lobby.leaderboard[mode][steam_id] then
			ply.lobby.leaderboard[mode][steam_id] = nil
		end
	end
end

function MINIGAME.ClearLeaderboard(lobby, mode)
	if mode then
		lobby.leaderboard[mode] = {}
	else
		lobby.leaderboard = {}
	end
end


-- # Timer

function MINIGAME.Reset(ply)
	ply:SetHealth(100)
	ply.stamina.airaccel:SetStamina(100)
	ply.race_frozen = true
	ply.race_start_time = 0
	ply.race_checkpoints = {}
	
	if ply.lobby then
		if ply.lobby.zones.checkpoint then
			if #ply.lobby.zones.checkpoint > 0 and CLIENT then
				for k, v in pairs(ply.lobby.zones.checkpoint) do
					v:SetDrawColor(MINIGAME.ZONES["checkpoint"], 2)
				end
				
				ply.lobby.zones.checkpoint[1]:SetDrawColor(MINIGAME.ZONES["checkpoint_active"], 2)
			end
		end
	end
	
	if CLIENT then
		NotificationService.FinishSticky("Race_Timer")
	elseif SERVER then
		TrailService.RemoveTrail(ply)
		TrailService.SetupTrail(ply)
		
		net.Start "Race_Reset"
			net.WriteEntity(ply)
		net.Send(MINIGAME.GetPlayers(ply.lobby))
	end
end

function MINIGAME.GetTime(start, last)
	if isnumber(start) then
		return string.ToMinutesSecondsMilliseconds(math.abs(start - (last or 0)))
	end
	
	return start
end

function MINIGAME.StartTimer(ply)
	if ply.lobby.zones.start and ply.lobby.zones["end"] and ply:GetMoveType() ~= MOVETYPE_NOCLIP then
		if CLIENT then
			MINIGAME.TimerNotification(0)
		end
		
		ply.race_timer = 0
		ply.race_start_time = CurTime()
	end
end

function MINIGAME.StopTimer(ply, time)
	ply.race_start_time = 0
	
	if time then
		ply.race_timer = time
		
		if CLIENT then
			if ply == GetPlayer() then
				MINIGAME.TimerNotification(time)
			end
		end
	end
end

function MINIGAME.Timer(ply, move)
	if ply.race_start_time ~= 0 then
		ply.race_timer = CurTime() - ply.race_start_time
		
		if CLIENT then
			MINIGAME.TimerNotification(ply.race_timer)
		end
	end
end
hook.Add("SetupMove", "MINIGAME.Timer", MINIGAME.Timer)

function MINIGAME.StartMove(ply, mv)
	if ply.lobby then
		if ply.lobby.key == "Race" and ply.lobby.zones and ply.race_frozen then
			if IsValid(ply.lobby.zones.start) then
				local validKeys = bit.band(mv:GetButtons(), bit.bor(unpack(MINIGAME.START_KEYS)))
				
				mv:SetOrigin(ply.lobby.zones.start:GetPos())
				mv:SetVelocity(Vector(0,0,0))
				
				if mv:KeyPressed(validKeys) and IsFirstTimePredicted() then
					ply.race_frozen = false
					MINIGAME.StartTimer(ply)
				end
			end
		end
	end
end
hook.Add("SetupMove", "MINIGAME.StartMove", MINIGAME.StartMove)