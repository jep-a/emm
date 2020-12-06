hook.Add("CreateMinigameHooks", "TaggingService", function (proto)
	proto:AddHook("Tag", "TaggingService.Tag", function (self, taggable, tagger)
		MinigameService.CallHook(self, taggable.player_class.key.."Tag", taggable, tagger)

		if taggable.player_class.Tag then
			taggable:Tag(tagger)
		end
	end)

	proto:AddHook("PostTag", "TaggingService.PostTag", function (self, taggable, tagger)
		MinigameService.CallHook(self, taggable.player_class.key.."PostTag", taggable, tagger)

		if taggable.player_class.PostTag then
			taggable:PostTag(tagger)
		end
	end)

	proto:AddHook("EndTag", "TaggingService.EndTag", function (self, taggable, tagger)
		MinigameService.CallHook(self, taggable.player_class.key.."EndTag", taggable, tagger)

		if taggable.player_class.EndTag then
			taggable:EndTag(tagger)
		end
	end)

	proto:AddHook("PostEndTag", "TaggingService.PostEndTag", function (self, taggable, tagger)
		MinigameService.CallHook(self, taggable.player_class.key.."PostEndTag", taggable, tagger)

		if taggable.player_class.PostEndTag then
			taggable:PostEndTag(tagger)
		end
	end)

	proto:AddHookNotification("Tag", function (self, involves_local_ply, taggable, tagger)
		if taggable.notify_on_tag then
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
				local action = " has "..tag_word.." "
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
		end
	end)
end)
