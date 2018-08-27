function MinigamePrototype:NotifyRandomPlayerClassPicks(is_local_lobby, involves_local_ply, picked_plys)
	if is_local_lobby then
		local ply_class_name = self.player_classes[self.random_player_classes.class_key].name

		for _, ply in pairs(picked_plys) do
			if IsLocalPlayer(ply) then
				NotificationService.PushText("you've been picked as "..ply_class_name)
			else
				NotificationService.PushSideText(ply:GetName().." has been picked as "..ply_class_name)
			end
		end
	end
end

function MinigamePrototype:NotifyPlayerClassForfeit(is_local_lobby, involves_local_ply, forfeiter, closest_ply)
	if is_local_lobby then
		local ply_class_name = closest_ply.player_class.name

		if involves_local_ply then
			local forfeiter_is_local_ply = IsLocalPlayer(forfeiter)

			NotificationService.PushAvatarText(forfeiter_is_local_ply and closest_ply or forfeiter, forfeiter_is_local_ply and "forfeited "..ply_class_name.." to" or "inherited "..ply_class_name.." from")
		else
			NotificationService.PushSideText(closest_ply:GetName().." has inherited "..ply_class_name.." from "..forfeiter:GetName())
		end
	end
end

function MinigamePrototype:NotifyPlayerClassChangeFromDeath(is_local_lobby, involves_local_ply, ply)
	if is_local_lobby then
		local ply_class_name = ply.player_class.name

		if involves_local_ply then
			NotificationService.PushText("you have turned into a "..ply_class_name)
		else
			NotificationService.PushSideText(ply:GetName().." has died and turned into a "..ply_class_name)
		end
	end
end

function MinigamePrototype:NotifyWaitingForPlayers(old_state_or_ply, new_state)
	if self:IsLocal() then
		local required_plys = self.required_players - #self.players

		if old_state_or_ply == self.states.Waiting or (old_state_or_ply and new_state == self.states.Waiting) then
			required_plys = required_plys + 1
		end

		if required_plys > 0 then
			NotificationService.PushText("waiting for "..required_plys.." more "..((required_plys == 1 and "person") or "people"))
		end
	end
end

function MinigamePrototype:NotifyTimedState(old_state, new_state)
	if self:IsLocal() and new_state.time and new_state.notify_countdown then
		NotificationService.PushCountdown(self.last_state_start + new_state.time, new_state.notify_countdown_text or string.lower(new_state.name).." in")
	end
end

function MinigamePrototype:AddDefaultHooks()
	self:AddHook("StartState", "Notification", self.NotifyTimedState)
	self:AddHook("StartStateWaiting", "Notification", self.NotifyWaitingForPlayers)
	self:AddStateHook("Waiting", "PlayerJoin", "Notification", self.NotifyWaitingForPlayers)
end

function MinigamePrototype:AddGlobalEventHooks()
	self:AddEventHook("PickRandomPlayerClasses", "Notification", self.NotifyRandomPlayerClassPicks)
	self:AddEventHook("PlayerClassForfeit", "Notification", self.NotifyPlayerClassForfeit)
	self:AddEventHook("PlayerClassChangeFromDeath", "Notification", self.NotifyPlayerClassChangeFromDeath)

	hook.Run("CreateGlobalMinigameEventHooks", self)
end
