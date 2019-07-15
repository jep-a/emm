function MINIGAME:StartStatePlaying()
	--
end

concommand.Add("leaderboard", function(ply, cmd, args)
	if ply.lobby.leaderboard then
		for mode, tbl in pairs(ply.lobby.leaderboard) do
			print(mode .. ": ")
			for place, v in pairs(tbl) do
				print(place .. ": " .. v.name .. " : " .. MINIGAME.GetTime(v.time))
				print(v.time)
			end
		end
		--PrintTable(ply.lobby.leaderboard)
	end
end)

function MINIGAME.LobbyPlayerJoin(lobby, ply)
	if lobby.key == "Race" and ply == LocalPlayer() then
		local timer_notification = NotificationService.PushMetaText(ply.race_timer, "Race_Timer", 3)
		local pr_notification = NotificationService.PushMetaText(ply.race_timer, "Race_PR", 4)

		timer_notification.children[1]:SetText(MINIGAME.GetTime(0))
		pr_notification.children[1]:SetText(MINIGAME.GetTime(0))
	end
end
hook.Add("LocalLobbyPlayerJoin", "MINIGAME.LobbyPlayerJoin", MINIGAME.LobbyPlayerJoin)
hook.Add("LocalLobbyInit", "MINIGAME.LobbyPlayerJoin", MINIGAME.LobbyPlayerJoin)

function MINIGAME.LobbyPlayerLeave(lobby, ply)
	if lobby.key == "Race" and ply == LocalPlayer() then
		NotificationService.stickies["Race_Timer"].children[1]:Finish()
		NotificationService.stickies["Race_PR"].children[1]:Finish()
	end

end
hook.Add("LocalLobbyPlayerLeave", "MINIGAME.LobbyPlayerLeave", MINIGAME.LobbyPlayerLeave)


-- # Zones

concommand.Add("remove", function(ply, cmd, args)
	if args[1] then
		MINIGAME.RemoveZone("checkpoint", args[1], ply.lobby.id)
		net.Start "RemoveZone"
		net.WriteString("checkpoint")
		net.WriteInt(args[1], 8)
		net.WriteInt(ply.lobby.id, 8)
		net.SendToServer()
	end
end)

function MINIGAME.ZoneSelector(ply, move)
	if IsFirstTimePredicted() and ply.lobby then
		if ply.lobby.host == ply and ply.lobby.prototype.name == "Race" then
			local zone_type = CheckpointService.type

			if input.WasKeyPressed(KEY_1) and zone_type ~= "start" then
				CheckpointService.type = "start"
				CheckpointService.save_mode_limit = 1
				chat.AddText(COLOR_WHITE, "Zone set to ", COLOR_GREEN, CheckpointService.type)
			elseif input.WasKeyPressed(KEY_2) and zone_type ~= "checkpoint" then
				CheckpointService.type = "checkpoint"
				CheckpointService.save_mode_limit = 3
				chat.AddText(COLOR_WHITE, "Zone set to ", COLOR_YELLOW, CheckpointService.type)
			elseif input.WasKeyPressed(KEY_3) and zone_type ~= "end" then
				CheckpointService.type = "end"
				CheckpointService.save_mode_limit = 3
				chat.AddText(COLOR_WHITE, "Zone set to ", COLOR_RED, CheckpointService.type)
			end
		end
	end
end
hook.Add("SetupMove", "MINIGAME.ZoneSelector", MINIGAME.ZoneSelector)

function MINIGAME.OnEntityCreated(ent)
	local zone_type, lobby_id = ent:GetType(), ent:GetLobby()
	local trace = util.TraceLine{
		start = ent:GetPos(),
		endpos = ent:GetPos() - Vector(0,0,1),
		mask = CONTENTS_SOLID
	}
	
	ent:SetDrawColor(MINIGAME.ZONES[zone_type], 0.5)

	if zone_type == "start" or zone_type == "end" then
		MinigameService.lobbies[lobby_id].zones[zone_type] = ent
		MINIGAME.ClearLeaderboard(MinigameService.lobbies[lobby_id])
	else
		if not MinigameService.lobbies[lobby_id].zones[zone_type] then
			MinigameService.lobbies[lobby_id].zones[zone_type] = {}
		end

		table.insert(MinigameService.lobbies[lobby_id].zones[zone_type], ent)
	end

	ent.GetCheckpoint = function(self, checkpoints, zone_type)
		if zone_type == "checkpoint" and isnumber(checkpoints) then
			if checkpoints > 0 then
				if checkpoints + 1 == self:GetID() then
					zone_type = "checkpoint_active"
				elseif checkpoints+1 > self:GetID() then
					zone_type = "checkpoint_activated"
				end
			elseif checkpoints == 0 and 1 == self:GetID() then
				zone_type = "checkpoint_active"
			end
		end
	
		return zone_type
	end
	
end
hook.Add("Emm_Trigger_Init", "MINIGAME.OnEntityCreated", MINIGAME.OnEntityCreated)
