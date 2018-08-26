function MinigamePrototype:PickRandomPlayerClasses()
	if self.random_player_classes then
		local picked_plys = MinigameService.PickRandomPlayerClasses(self, self.random_player_classes)
		MinigameEventService.Call(self, "PickRandomPlayerClasses", picked_plys)
	end
end

function MinigamePrototype:ForfeitPlayerClass(ply)
	if ply.player_class and ply.player_class.swap_closest_on_death then
		local closest_ply = MinigameService.PickClosestPlayerClass(self, ply, {
			blacklist_class_key = ply.player_class.key,
			swap_player_class = true
		})

		if closest_ply then
			MinigameEventService.Call(self, "ForfeitPlayerClass", ply, closest_ply)
		end
	end
end

function MinigamePrototype:SetDefaultPlayerClass(ply)
	if self.default_player_class then
		ply:SetPlayerClass(self.player_classes[self.default_player_class])
	end
end

function MinigamePrototype:CheckIfNoPlayerClasses(ply, old_class)
	if old_class and old_class.end_on_none and 1 > #self[old_class.key] then
		self:NextState()
	end
end

function MinigamePrototype:AddDefaultHooks()
	self:AddHook("StartStateWaiting", "ClearPlayerClasses", self.ClearPlayerClasses)
	self:AddHook("StartStatePlaying", "PickRandomPlayerClasses", self.PickRandomPlayerClasses)
	self:AddStateHook("Playing", "PlayerJoin", "SetDefaultPlayerClass", self.SetDefaultPlayerClass)
	self:AddStateHook("Playing", "PlayerDeath", "ForfeitPlayerClass", self.ForfeitPlayerClass)
	self:AddStateHook("Playing", "PlayerLeave", "ForfeitPlayerClass", self.ForfeitPlayerClass)
	self:AddStateHook("Playing", "PlayerClassChange", "EndIfNoPlayerClasses", self.CheckIfNoPlayerClasses)
end

function MinigamePrototype:AddRequirePlayersHooks()
	self:AddStateHook("Waiting", "PlayerJoin", "RequirePlayers", function (self, ply)
		if #self.players >= self.required_players then
			self:NextState()
		end
	end)

	self:AddHook("PlayerLeave", "RequirePlayers", function (self, ply)
		if self.state ~= self.states.Waiting and (#self.players - 1) < self.required_players then
			self:SetState(self.states.Waiting)
		end
	end)
end