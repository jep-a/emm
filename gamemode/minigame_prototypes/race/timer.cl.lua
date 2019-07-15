concommand.Add("reset", function(ply, cmd, args)
	MINIGAME.Reset(ply)
end)

function MINIGAME.TimerNotification(time)
	if not NotificationService.stickies["Race_Timer"] or not NotificationService.stickies["Race_Timer"].children[1] then
		NotificationService.PushMetaText(MINIGAME.GetTime(time), "Race_Timer", 3)
	else
		if NotificationService.stickies["Race_Timer"].attributes.alpha.current < 200 then
			NotificationContainer.super.Finish(NotificationService.stickies["Race_Timer"])
		end

		NotificationService.stickies["Race_Timer"].children[1]:SetText(MINIGAME.GetTime(time))
	end
end

function MINIGAME.PRNotification(time)
	if not NotificationService.stickies["Race_PR"] or not NotificationService.stickies["Race_PR"].children[1] then
		NotificationService.PushMetaText("PR: " .. MINIGAME.GetTime(time), "Race_PR", 4)
	else
		if NotificationService.stickies["Race_PR"].attributes.alpha.current < 255 then
			NotificationContainer.super.Finish(NotificationService.stickies["Race_PR"])
		end
		
		NotificationService.stickies["Race_PR"].children[1]:SetText("PR: " .. MINIGAME.GetTime(time))
	end
end

function MINIGAME.Notification(ply, mode, pr, time)
	local sign = "-"
	local mode_notification = mode:gsub("^%l", string.upper)
	local message = "You got a time in "
	
	if pr == 0 then
		pr = time*2
	end
	
	if time >= pr then
		sign = "+"
	else
		local best_time, lobby_record_holder = MINIGAME.GetBest(ply.lobby, mode)
		
		if best_time == time or best_time == 0 then
			message = string.Replace(message, "time", "lobby record")
			NotificationService.PushAvatarText(ply, MINIGAME.GetTime(time))
		else
			message = string.Replace(message, "time", "personal record")
		end
	end
	
	message = "[" .. mode_notification .. "] " .. message .. MINIGAME.GetTime(time) .. " (" .. sign .. MINIGAME.GetTime(time, pr) .. ")"
	
	if ply == LocalPlayer() then
		NotificationService.PushSideText(message)
		MsgC(ply.lobby.color, message, "\n")
	else
		if sign == "-" then
			message = string.Replace(message, "You", ply:Nick())
			NotificationService.PushSideText(message)
			MsgC(ply.lobby.color, message, "\n")
		end
	end
end

net.Receive("Race_Timer", function()
	local ply = net.ReadEntity()
	local time = net.ReadFloat()
	local mode = net.ReadString()
	local pr = MINIGAME.GetPR(ply, mode)
	
	MINIGAME.PRNotification(time)
	MINIGAME.StopTimer(ply, time)
	MINIGAME.UpdateLeaderboard(ply, mode, time)
	MINIGAME.Notification(ply, mode, pr, time)
end)

net.Receive("Race_Reset", function()
	MINIGAME.Reset(net.ReadEntity())
end)