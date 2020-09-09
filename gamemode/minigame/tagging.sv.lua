TaggingService.taggable_groups = TaggingService.taggable_groups or {}

function TaggingService.InitPlayerProperties(ply)
	ply.taggable_radius = 80
	ply.taggable_cooldown = 1
	ply.last_tag_time = 0
end
hook.Add("InitPlayerProperties", "TaggingService.InitPlayerProperties", TaggingService.InitPlayerProperties)

function TaggingService.Tag(lobby, taggable, tagger)
	taggable.last_tag_time = CurTime()

	MinigameService.CallNetHook(taggable.lobby, "Tag", taggable, tagger)

	local player_class_on_tag = taggable.player_class.player_class_on_tag
	local player_class_on_delay = taggable.player_class.player_class_on_delay -- Because the RHS value may change in the timer for delayed classes (don't want to risk it)

	if taggable.player_class.swap_on_tag then
		MinigameService.SwapPlayerClass(taggable, tagger, taggable.player_class.kill_on_tag, taggable.player_class.kill_tagger_on_tag)
	elseif taggable.player_class.recruit_on_tag then
		tagger:SetPlayerClass(taggable.player_class)
	elseif player_class_on_tag then
		tagger:SetPlayerClass(taggable.lobby:GetPlayerClass(player_class_on_tag)) -- Such as Tagger turning Runner -> Frozen
	end

	timer.Remove("timer_for_player_class_on_delay_" .. tagger:SteamID()) -- Remove any previous created timers for changing the player's class on delay

	if (taggable.player_class.delay_amount and taggable.player_class.delay_amount > 0) then
		timer.Create("timer_for_player_class_on_delay_" .. tagger:SteamID(), taggable.player_class.delay_amount, 1, function()
			if (player_class_on_delay and tagger.player_class.name == player_class_on_tag) then -- Make sure delayed class is valid, make sure the tagger is in the same class (stops runners becoming taggers if they once were frozen)
				tagger:SetPlayerClass(taggable.lobby:GetPlayerClass(player_class_on_delay)) -- Such as Frozen becoming Tagger
			end
		end)
	end
end

function TaggingService.Think()
	for i = 1, #TaggingService.taggable_groups do
		for _i = 1, #TaggingService.taggable_groups[i] do
			local taggable = TaggingService.taggable_groups[i][_i]

			if IsValid(taggable) then
				local ents = ents.FindInSphere(taggable:WorldSpaceCenter(), taggable.taggable_radius)

				if
					taggable:Alive() and
					CurTime() > (taggable.last_tag_time + taggable.taggable_cooldown)
				then
					for __i = 1, #ents do
						local ent = ents[__i]

						if
							taggable ~= ent and
							ent:IsPlayer() and
							ent:Alive() and
							MinigameService.IsSharingLobby(taggable, ent) and
							ent.player_class and
							taggable.player_class.can_tag and
							taggable.player_class.can_tag[ent.player_class.key]
						then
							TaggingService.Tag(taggable.lobby, taggable, ent)
						end
					end
				end
			end
		end
	end
end
hook.Add("Think", "TaggingService.Think", TaggingService.Think)

function TaggingService.InitLobby(lobby)
	for k, player_class in pairs(lobby.player_classes) do
		if player_class.can_tag then
			table.insert(TaggingService.taggable_groups, lobby[k])
		end
	end
end
hook.Add("LobbyCreate", "TaggingService.InitLobby", TaggingService.InitLobby)

function TaggingService.FinishLobby(lobby)
	for k, player_class in pairs(lobby.player_classes) do
		if player_class.can_tag then
			table.RemoveByValue(TaggingService.taggable_groups, lobby[k])
		end
	end
end
hook.Add("LobbyFinish", "TaggingService.FinishLobby", TaggingService.FinishLobby)
