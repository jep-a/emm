hook.Add("CreateGlobalMinigameEventHooks", "Tag", function (lobby)
	lobby:AddEventHook("Tag", "Notification", function (self, is_local_lobby, involves_local_ply, taggable, tagger)
		if is_local_lobby then
			local taggable_is_victim = taggable.player_class.tag_victim

			if involves_local_ply then
				local taggable_is_local_ply = IsLocalPlayer(taggable)
				local victim_text = "tagged by"
				local attacker_text = "tagged"

				local text

				if taggable_is_local_ply then
					text = taggable_is_victim and victim_text or attacker_text
				else
					text = taggable_is_victim and attacker_text or victim_text
				end

				NotificationService.PushAvatarText(taggable_is_local_ply and tagger or taggable, text)
			else
				local action = " has tagged "

				local text

				if taggable_is_victim then
					text = tagger:GetName()..action..taggable:GetName()
				else
					text = taggable:GetName()..action..tagger:GetName()
				end

				NotificationService.PushSideText(text)
			end
		end
	end)
end)
