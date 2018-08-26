hook.Add("CreateGlobalMinigameEventHooks", "Tag", function (lobby)
	lobby:AddEventHook("Tag", "Notification", function (self, is_local_lobby, involves_local_ply, hunted, hunter)
		if is_local_lobby then
			if involves_local_ply then
				local hunted_is_local_ply = IsLocalPlayer(hunted)

				NotificationService.PushAvatarText(hunted_is_local_ply and hunter or hunted, hunted_is_local_ply and "tagged by" or "tagged")
			else
				NotificationService.PushSideText(hunter:GetName().." has tagged "..hunted:GetName())
			end
		end
	end)
end)
