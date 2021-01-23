TaggingService.TaggableTarget_groups = TaggingService.TaggableTarget_groups or {}

function TaggingService.Tag(lobby, taggable, tagger)
	if not table.HasValue(taggable.tagging, tagger) then
		table.insert(taggable.tagging, tagger)

		taggable.last_tag_time = CurTime()
		tagger.last_tag_time = CurTime()

		local taggable_ply_class = taggable.player_class

		MinigameService.CallNetHook(taggable.lobby, "Tag", taggable, tagger)
		MinigameService.CallHook(taggable.lobby, taggable_ply_class.key.."Tag", taggable, tagger)

		if taggable_ply_class.Tag then
			taggable:Tag(tagger)
		end

		if taggable_ply_class.swap_on_tag then
			MinigameService.SwapPlayerClass(taggable, tagger, taggable_ply_class.kill_on_tag, taggable_ply_class.kill_tagger_on_tag)
		elseif taggable_ply_class.recruit_on_tag then
			tagger:SetPlayerClass(taggable_ply_class)
		else
			if taggable_ply_class.player_class_on_tag then
				taggable:SetPlayerClass(lobby.player_classes[taggable_ply_class.player_class_on_tag])
			end

			if taggable_ply_class.give_player_class_on_tag then
				tagger:SetPlayerClass(lobby.player_classes[taggable_ply_class.give_player_class_on_tag])
			end
		end

		MinigameService.CallNetHook(taggable.lobby, "PostTag", taggable, tagger)
		MinigameService.CallHook(taggable.lobby, taggable_ply_class.key.."PostTag", taggable, tagger)

		if taggable_ply_class.PostTag then
			taggable:PostTag(tagger)
		end
	end
end

function TaggingService.EndTag(lobby, taggable, tagger)
	if table.HasValue(taggable.tagging, tagger) then
		table.RemoveByValue(taggable.tagging, tagger)

		MinigameService.CallNetHook(taggable.lobby, "EndTag", taggable, tagger)
		MinigameService.CallHook(taggable.lobby, taggable.player_class.key.."EndTag", taggable, tagger)

		local taggable_ply_class = taggable.player_class

		if taggable_ply_class.EndTag then
			taggable:EndTag(tagger)
		end

		MinigameService.CallNetHook(taggable.lobby, "PostEndTag", taggable, tagger)
		MinigameService.CallHook(taggable.lobby, taggable_ply_class.key.."PostEndTag", taggable, tagger)

		if taggable_ply_class.PostEndTag then
			taggable:PostEndTag(tagger)
		end
	end
end

function TaggingService.Taggable(taggable)
	return (
		taggable.taggable and
		GhostService.Alive(taggable) and
		CurTime() > (taggable.last_tag_time + taggable.taggable_cooldown)
	)
end

function TaggingService.TaggableTarget(taggable, tagger)
	local can_tag = taggable.player_class and taggable.player_class.can_tag or taggable.can_tag

	return (
		taggable ~= tagger and
		tagger:IsPlayer() and
		GhostService.Alive(tagger) and
		MinigameService.IsSharingLobby(taggable, tagger) and
		can_tag[tagger.player_class.key] and
		CurTime() > ((tagger.last_tag_time or 0) + (tagger.taggable_cooldown or 1))
	)
end

function TaggingService.LoopEnts(taggable, ents)
	if TaggingService.Taggable(taggable) then
		for i = 1, #ents do
			local ent = ents[i]

			if TaggingService.TaggableTarget(taggable, ent) then
				TaggingService.Tag(taggable.lobby, taggable, ent)
			end
		end
	end

	local tagging = taggable.tagging
	local tagging_len = #tagging

	if tagging_len > 0 then
		for i = tagging_len, 1, -1 do
			local ent = tagging[i]

			if not table.HasValue(ents, ent) then
				TaggingService.EndTag(taggable.lobby, taggable, ent)
			end
		end
	end
end

function TaggingService.Think()
	for i = 1, #TaggingService.TaggableTarget_groups do
		for _i = 1, #TaggingService.TaggableTarget_groups[i] do
			local taggable = TaggingService.TaggableTarget_groups[i][_i]

			if IsValid(taggable) then
				local ents = ents.FindInSphere(GhostService.Entity(taggable):GetPos() + taggable:OBBCenter(), taggable.taggable_radius)

				TaggingService.LoopEnts(taggable, ents)
			end
		end
	end
end
hook.Add("Think", "TaggingService.Think", TaggingService.Think)

hook.Add("TriggerStartTouch", "TaggingService.Tag", function (a, b)
	TaggingService.Tag(a.lobby, a.owner_tag and a:GetOwner() or a, b)
end)

hook.Add("TriggerEndTouch", "TaggingService.EndTag", function (a, b)
	TaggingService.EndTag(a.lobby, a.owner_tag and a:GetOwner() or a, b)
end)

function TaggingService.InitLobby(lobby)
	for k, ply_class in pairs(lobby.player_classes) do
		if ply_class.can_tag then
			table.insert(TaggingService.TaggableTarget_groups, lobby[k])
		end
	end
end
hook.Add("LobbyCreate", "TaggingService.InitLobby", TaggingService.InitLobby)

function TaggingService.FinishLobby(lobby)
	for k, ply_class in pairs(lobby.player_classes) do
		if ply_class.can_tag then
			table.RemoveByValue(TaggingService.TaggableTarget_groups, lobby[k])
		end
	end
end
hook.Add("LobbyFinish", "TaggingService.FinishLobby", TaggingService.FinishLobby)

function TaggingService.TagOnDamage(lobby, victim, inflictor, attacker)
	if TaggingService.Taggable(attacker) and TaggingService.TaggableTarget(attacker, victim) and attacker.tag_on_damage then
		TaggingService.Tag(lobby, attacker, victim)
		TaggingService.EndTag(lobby, attacker, victim)
	end
end
hook.Add("CreateMinigameHooks", "TaggingService", function (proto)
	proto:AddStateHook("Playing", "EntityTakeDamage", "TaggingService.TagOnDamage", TaggingService.TagOnDamage)
end)
