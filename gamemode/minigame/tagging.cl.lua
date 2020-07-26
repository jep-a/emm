hook.Add("CreateMinigameHooks", "TaggingService", function (proto)
	proto:AddHookNotification("Tag", function (self, involves_local_ply, taggable, tagger)
		local taggable_is_victim = taggable.tag_victim
		local tag_word = taggable.tag_word or "tagged"

		if involves_local_ply then
			local taggable_is_local_ply = IsLocalPlayer(taggable)
			local victim_text = tag_word.." by"
			local attacker_text = tag_word

			local text

			if taggable_is_local_ply then
				text = taggable_is_victim and victim_text or attacker_text
			else
				text = taggable_is_victim and attacker_text or victim_text
			end

			NotificationService.PushAvatarText(taggable_is_local_ply and tagger or taggable, text)
		else
			local action = " has "..taggable.tag_word.." "
			local taggable_name = taggable:GetName()
			local tagger_name = tagger:GetName()

			local text

			if taggable_is_victim then
				text = tagger_name..action..taggable_name
			else
				text = taggable_name..action..tagger_name
			end

			NotificationService.PushSideText(text)
		end
	end)
end)
