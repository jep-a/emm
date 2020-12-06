function MinigamePrototype:NotifyRandomPlayerClassesPicked(involves_local_ply, picked_plys)
	local ply_class_name = self.player_classes[self.random_player_classes.class_key].name

	for _, ply in pairs(picked_plys) do
		if IsLocalPlayer(ply) then
			NotificationService.PushText("you've been picked as "..ply_class_name)
		else
			NotificationService.PushSideText(ply:GetName().." has been picked as "..ply_class_name)
		end
	end
end

function MinigamePrototype:NotifyDeadPlayerClassForfeitToClosest(involves_local_ply, forfeiter, closest_ply)
	local ply_class_name = closest_ply.player_class.name

	if involves_local_ply then
		local forfeiter_is_local_ply = IsLocalPlayer(forfeiter)

		NotificationService.PushAvatarText(forfeiter_is_local_ply and closest_ply or forfeiter, forfeiter_is_local_ply and "forfeited "..ply_class_name.." to" or "inherited "..ply_class_name.." from")
	else
		NotificationService.PushSideText(closest_ply:GetName().." has inherited "..ply_class_name.." from "..forfeiter:GetName())
	end
end

function MinigamePrototype:NotifyDepartedPlayerClassForfeitToClosest(involves_local_ply, forfeiter, closest_ply)
	local ply_class_name = closest_ply.player_class.name
	local inheriter_is_local_ply = IsLocalPlayer(closest_ply)

	if involves_local_ply and inheriter_is_local_ply then
		NotificationService.PushAvatarText(forfeiter, "inherited "..ply_class_name.." from")
	else
		NotificationService.PushSideText(closest_ply:GetName().." has inherited "..ply_class_name.." from "..forfeiter:GetName())
	end
end

function MinigamePrototype:NotifyPlayerClassForfeitToAttacker(involves_local_ply, forfeiter, attacker)
	local ply_class_name = attacker.player_class.name

	if involves_local_ply then
		local attacker_is_local_ply = IsLocalPlayer(attacker)

		NotificationService.PushAvatarText(attacker_is_local_ply and forfeiter or attacker, (attacker_is_local_ply and "killed" or "killed by").." for "..ply_class_name)
	else
		NotificationService.PushSideText(attacker:GetName().." has killed "..forfeiter:GetName().." for "..ply_class_name)
	end

	forfeiter.block_kill_notification = true
end

function MinigamePrototype:NotifyPlayerClassChangeFromDeath(involves_local_ply, ply, attacker)
	local ply_class = ply.player_class
	local ply_class_name = ply_class.name

	if ply_class.notify_player_class_on_death then
		if involves_local_ply then
			NotificationService.PushText("you have turned into a "..ply_class_name)
		else
			NotificationService.PushSideText(ply:GetName().." has died and turned into a "..ply_class_name)
		end
	end
end

function MinigamePrototype:NotifyPlayerDeath(involves_local_ply, ply, inflictor, attacker)
	if ply.block_kill_notification then
		ply.block_kill_notification = nil
	else
		local ply_class = ply.player_class

		if ply_class then
			local ply_class_name = ply_class.name

			if ply_class.notify_on_killed_by_player and IsPlayer(attacker) and ply ~= attacker then
				if involves_local_ply then
					local attacker_is_local_ply = IsLocalPlayer(attacker)

					NotificationService.PushAvatarText(attacker_is_local_ply and ply or attacker, attacker_is_local_ply and "killed" or "killed by")
				else
					NotificationService.PushSideText(attacker:GetName().." has killed "..ply:GetName())
				end
			elseif not involves_local_ply and ply_class.notify_on_killed_by_other then
				NotificationService.PushSideText(ply:GetName().." has died")
			end
		end
	end
end

function MinigamePrototype:NotifyWaitingForPlayers(involves_local_ply, old_state, new_state)
	local required_plys = self.required_players - #self.players

	if old_state == self.states.Waiting or (involves_local_ply and new_state == self.states.Waiting) then
		required_plys = required_plys + 1
	end

	if required_plys > 0 then
		NotificationService.PushText("waiting for "..required_plys.." more "..((required_plys == 1 and "person") or "people"))
	end
end

function MinigamePrototype:NotifyStateCountdown(involves_local_ply, old_state, new_state)
	new_state = new_state or self.state

	if new_state and new_state.time and new_state.notify_countdown then
		if self.countdown_notification then
			self.countdown_notification:Finish()
			self.countdown_notification = nil
		end

		local text

		if new_state.notify_countdown_text then
			text = new_state.notify_countdown_text
		else
			text = string.lower(new_state.name).." in"
		end

		self.countdown_notification = NotificationService.PushCountdown(self.last_state_start + new_state.time, text, "StateCountdown", 3)
	end
end

function MinigameService.InvolvesLocalPlayer(...)
	local local_ply = LocalPlayer()

	local involves_local_ply

	for _, v in pairs({...}) do
		if local_ply == v or (istable(v) and table.HasValue(v, local_ply)) then
			involves_local_ply = true

			break
		end
	end

	return involves_local_ply
end

function MinigameService.NotificationFunction(func)
	return function (lobby, ...)
		if lobby:IsLocal() then
			func(lobby, MinigameService.InvolvesLocalPlayer(...), ...)
		end
	end
end

function MinigamePrototype:AddHookNotification(hk_name, func)
	self:AddHook(hk_name, "Notification", MinigameService.NotificationFunction(func))
end

function MinigamePrototype:AddStateHookNotification(state_key, hk_name, func)
	self:AddStateHook(state_key, hk_name, "Notification", MinigameService.NotificationFunction(func))
end

function MinigamePrototype:AddDefaultHooks()
	self:AddHookNotification("StartState", self.NotifyStateCountdown)
	self:AddHookNotification("StartStateWaiting", self.NotifyWaitingForPlayers)
	self:AddHookNotification("RandomPlayerClassesPicked", self.NotifyRandomPlayerClassesPicked)
	self:AddHookNotification("DeadPlayerClassForfeitToClosest", self.NotifyDeadPlayerClassForfeitToClosest)
	self:AddHookNotification("DepartedPlayerClassForfeitToClosest", self.NotifyDepartedPlayerClassForfeitToClosest)
	self:AddHookNotification("PlayerClassForfeitToAttacker", self.NotifyPlayerClassForfeitToAttacker)
	self:AddHookNotification("PlayerClassChangeFromDeath", self.NotifyPlayerClassChangeFromDeath)
	self:AddHookNotification("PlayerDeath", self.NotifyPlayerDeath)
	self:AddStateHookNotification("Waiting", "PlayerJoin", self.NotifyWaitingForPlayers)

	hook.Run("CreateMinigameHooks", self)
end

function MinigameService.ReloadStateCountdown(lobby, ply)
	ply = ply or LocalPlayer()
	lobby = lobby or ply.lobby

	if IsLocalPlayer(ply) and lobby then
		lobby:NotifyStateCountdown()
	end
end
hook.Add("LocalLobbyPlayerJoin", "MinigameService.ReloadStateCountdown", MinigameService.ReloadStateCountdown)
hook.Add("InitHUDElements", "MinigameService.ReloadStateCountdown", MinigameService.ReloadStateCountdown)