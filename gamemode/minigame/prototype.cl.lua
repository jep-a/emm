function MinigamePrototype:AddGlobalEventHooks()
	self:AddEventHook("PickRandomPlayerClasses", "Notification", function (self, is_local_lobby, involves_local_ply, picked_plys)
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
	end)
	
	self:AddEventHook("ForfeitPlayerClass", "Notification", function (self, is_local_lobby, involves_local_ply, forfeiter, closest_ply)
		if is_local_lobby then
			local ply_class_name = closest_ply.player_class.name

			if involves_local_ply then
				local forfeiter_is_local_ply = IsLocalPlayer(forfeiter)
	
				NotificationService.PushAvatarText(forfeiter_is_local_ply and closest_ply or forfeiter, forfeiter_is_local_ply and "forfeited "..ply_class_name.." to" or "inherited "..ply_class_name.." from")
			else
				NotificationService.PushSideText(closest_ply:GetName().." has inherited "..ply_class_name.." from "..forfeiter:GetName())
			end
		end
	end)

	hook.Run("CreateGlobalMinigameEventHooks", self)
end
