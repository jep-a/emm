MINIGAME:AddEventHook("Tag", "Notification", function (self, is_local_lobby, involves_local_ply, hunted, hunter)
	if is_local_lobby then
		if involves_local_ply then
			local hunted_is_local_ply = IsLocalPlayer(hunted)

			NotificationService.PushAvatarText(hunted_is_local_ply and hunter or hunted, hunted_is_local_ply and "tagged by" or "tagged")
		else
			NotificationService.PushSideText(hunter:GetName().." has tagged "..hunted:GetName())
		end
	end
end)

MINIGAME:AddEventHook("RandomHunted", "Notification", function (self, is_local_lobby, involves_local_ply, hunted)
	if is_local_lobby then
		if involves_local_ply then
			NotificationService.PushText "you've been picked as hunted"
		else
			NotificationService.PushSideText(hunted:GetName().." has been picked as hunted")
		end
	end
end)

MINIGAME:AddEventHook("ResetHunted", "Notification", function (self, is_local_lobby, involves_local_ply, hunted, hunter)
	if is_local_lobby then
		if involves_local_ply then
			local hunted_is_local_ply = IsLocalPlayer(hunted)

			NotificationService.PushAvatarText(hunted_is_local_ply and hunter or hunted, hunted_is_local_ply and "forfeited hunted to" or "inherited hunted from")
		else
			NotificationService.PushSideText(hunter:GetName().." has inherited hunted from "..hunted:GetName())
		end
	end
end)