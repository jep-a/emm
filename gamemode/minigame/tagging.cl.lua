hook.Add("CreateGlobalMinigameEventHooks", "Tag", function (lobby)
	lobby:AddEventHook("Tag", "Notification", function (self, is_local_lobby, involves_local_ply, taggable, tagger)
		if is_local_lobby then
			if involves_local_ply then
				local taggable_is_local_ply = IsLocalPlayer(taggable)

				NotificationService.PushAvatarText(taggable_is_local_ply and tagger or taggable, taggable_is_local_ply and "tagged by" or "tagged")
			else
				NotificationService.PushSideText(tagger:GetName().." has tagged "..taggable:GetName())
			end
		end
	end)
end)
