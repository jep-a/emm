function MinigamePrototype:Respawn(ply)
	ply:Spawn()
end

function MinigamePrototype:PickRandomPlayerClasses()
	if self.random_player_classes then
		local picked_plys = MinigameService.PickRandomPlayerClasses(self, self.random_player_classes)
		MinigameService.CallNetHook(self, "PickRandomPlayerClasses", picked_plys)
	end
end

function MinigamePrototype:ReplacePlayerClass(ply)
	local ply_class = ply.player_class

	if ply_class.minimum and ply_class.minimum > 0 and ply_class.minimum > (#self[ply_class.key] - 1) then
		self:PickRandomPlayerClasses()
	end
end

function MinigamePrototype:ForfeitPlayerClass(ply)
	local ply_class = ply.player_class

	if ply_class and ply_class.swap_closest_on_death then
		local closest_ply = MinigameService.PickClosestPlayerClass(self, ply, {
			blacklist_class_key = ply_class.key,
			swap_player_class = true
		})

		if closest_ply then
			MinigameService.CallNetHook(self, "PlayerClassForfeit", ply, closest_ply)
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

function MinigamePrototype:SetPlayerClassOnDeath(ply)
	if ply.player_class and ply.player_class.player_class_on_death then
		ply:SetPlayerClass(self.player_classes[ply.player_class.player_class_on_death])
		MinigameService.CallNetHook(self, "PlayerClassChangeFromDeath", ply)
	end
end

function MinigamePrototype:StartOnEnoughPlayers()
	if #self.players >= self.required_players then
		self:NextState()
	end
end

function MinigamePrototype:WaitOnInsufficientPlayers()
	if self.state ~= self.states.Waiting and (#self.players - 1) < self.required_players then
		self:SetState(self.states.Waiting)
	end
end

function MinigamePrototype:AddDefaultHooks()
	self:AddHook("StartStateWaiting", "ClearPlayerClasses", MinigameService.ClearPlayerClasses)
	self:AddHook("StartStatePlaying", "PickRandomPlayerClasses", self.PickRandomPlayerClasses)
	self:AddStateHook("Playing", "PlayerJoin", "Respawn", self.Respawn)
	self:AddStateHook("Playing", "PlayerJoin", "SetDefaultPlayerClass", self.SetDefaultPlayerClass)
	self:AddStateHook("Playing", "PlayerLeave", "ReplacePlayerClass", self.ReplacePlayerClass)
	self:AddStateHook("Playing", "PlayerLeave", "ForfeitPlayerClass", self.ForfeitPlayerClass)
	self:AddStateHook("Playing", "PlayerDeath", "ForfeitPlayerClass", self.ForfeitPlayerClass)
	self:AddStateHook("Playing", "PlayerDeath", "SetPlayerClassOnDeath", self.SetPlayerClassOnDeath)
	self:AddStateHook("Playing", "PlayerClassChange", "EndIfNoPlayerClasses", self.CheckIfNoPlayerClasses)
end

function MinigamePrototype:AddRequirePlayersHooks()
	self:AddStateHook("Waiting", "PlayerJoin", "RequirePlayers", self.StartOnEnoughPlayers)
	self:AddHook("PlayerLeave", "RequirePlayers", self.WaitOnInsufficientPlayers)
end