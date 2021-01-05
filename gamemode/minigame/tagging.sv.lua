TaggingService = TaggingService or {}
TaggingService.taggable_groups = TaggingService.taggable_groups or {}

function TaggingService.InitPlayerProperties(ply)
	ply.taggable_radius = 80
	ply.taggable_cooldown = 1
	ply.last_tag_time = 0
end
hook.Add("InitPlayerProperties", "TaggingService.InitPlayerProperties", TaggingService.InitPlayerProperties)

local function SequentialTableHasValue(tab, val)
	for i = 1, #tab do
		if val == tab[i] then
			return true
		end
	end

	return false
end

function TaggingService.Think()
	for i = 1, #TaggingService.taggable_groups do
		for _i = 1, #TaggingService.taggable_groups[i] do
			local taggable = TaggingService.taggable_groups[i][_i]

			if taggable.player_class and taggable.player_class.can_tag then
				local ents = ents.FindInSphere(taggable:WorldSpaceCenter(), taggable.taggable_radius)

				if
					taggable:IsPlayer() and
					taggable:Alive() and
					CurTime() > (taggable.last_tag_time + 0.1)
				then
					for __i = 1, #ents do
						local ent = ents[__i]

						if
							taggable ~= ent and
							ent:IsPlayer() and
							ent:Alive() and
							taggable.lobby == ent.lobby and
							ent.player_class and
							SequentialTableHasValue(taggable.player_class.can_tag, ent.player_class.key)
						then
							taggable.last_tag_time = CurTime()
							MinigameService.CallHook(taggable.lobby, "Tag", taggable, ent)
						end
					end
				end
			end
		end
	end
end
hook.Add("Think", "TaggingService.Think", TaggingService.Think)

function TaggingService.CreateLobby(lobby)
	for k, player_class in pairs(lobby.player_classes) do
		if player_class.can_tag then
			table.insert(TaggingService.taggable_groups, lobby[k])
		end
	end
end
hook.Add("CreateLobby", "TaggingService.CreateLobby", TaggingService.CreateLobby)

function TaggingService.RemoveLobby(lobby)
	for k, player_class in pairs(lobby.player_classes) do
		if player_class.can_tag then
			table.RemoveByValue(TaggingService.taggable_groups, lobby[k])
		end
	end
end
hook.Add("RemoveLobby", "TaggingService.RemoveLobby", TaggingService.RemoveLobby)