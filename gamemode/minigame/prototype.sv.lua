function MinigamePrototype:Respawn(ply)
	ply:Spawn()
end

function MinigamePrototype:PickPlayerClasses()
	if self.random_player_classes then
		local picked_plys = MinigameService.PickRandomPlayerClasses(self, self.random_player_classes)
		MinigameService.CallNetHook(self, "RandomPlayerClassesPicked", picked_plys)
	elseif self.default_player_class then
		for _, ply in pairs(self.players) do
			ply:SetPlayerClass(self.player_classes[self.default_player_class])
		end
	end
end

function MinigamePrototype:ReplacePlayerClass(ply)
	local ply_class = ply.player_class

	if ply_class.minimum and ply_class.minimum > 0 and ply_class.minimum > (#self[ply_class.key] - 1) then
		self:PickPlayerClasses()
	end
end

function MinigamePrototype:ForfeitDeadPlayerClassToClosest(ply, inflictor, attacker)
	local ply_class = ply.player_class

	if ply_class and ply_class.swap_closest_on_death and not (ply_class.swap_with_attacker and IsPlayer(attacker) and ply ~= attacker and ply_class ~= attacker.player_class) then
		local closest_ply = MinigameService.PickClosestPlayerClass(self, ply, {
			blacklist_class_key = ply_class.key,
			swap_player_class = true
		})

		if closest_ply then
			MinigameService.CallNetHook(self, "DeadPlayerClassForfeitToClosest", ply, closest_ply)
		end
	end
end

function MinigamePrototype:ForfeitDepartedPlayerClassToClosest(ply)
	local ply_class = ply.player_class

	if ply_class and ply_class.swap_closest_on_leave then
		local closest_ply = MinigameService.PickClosestPlayerClass(self, ply, {
			blacklist_class_key = ply_class.key,
			swap_player_class = true
		})

		if closest_ply then
			MinigameService.CallNetHook(self, "DepartedPlayerClassForfeitToClosest", ply, closest_ply)
		end
	end
end

function MinigamePrototype:ForfeitPlayerClassToAttacker(ply, inflictor, attacker)
	local ply_class = ply.player_class

	if ply_class and IsPlayer(attacker) and ply_class.swap_with_attacker and ply_class ~= attacker.player_class then
		MinigameService.SwapPlayerClass(ply, attacker)
		MinigameService.CallNetHook(self, "PlayerClassForfeitToAttacker", ply, attacker)
	end
end

function MinigamePrototype:SetDefaultPlayerClass(ply)
	if self.default_player_class then
		ply:SetPlayerClass(self.player_classes[self.default_player_class])
	end
end

function MinigamePrototype:SetPlayerClassOnDeath(ply, inflictor, attacker)
	if ply.player_class and ply.player_class.player_class_on_death then
		ply:SetPlayerClass(self.player_classes[ply.player_class.player_class_on_death])
		MinigameService.CallNetHook(self, "PlayerClassChangeFromDeath", ply, attacker)
	end
end

function MinigamePrototype:CheckIfNoPlayerClasses(ply, old_class)
	if old_class and old_class.end_on_none and #self[old_class.key] == 0 then
		self:NextState()
	end
end

function MinigamePrototype:ReloadLoadouts(settings)
	local ply_classes_adjusted = {}

	for k, setting in pairs(settings) do
		local match = string.match(k, "player_classes%.(.*)%.weapons")

		if match then
			ply_classes_adjusted[match] = true
		end
	end

	if ply_classes_adjusted then
		for ply_class, _ in pairs(ply_classes_adjusted) do
			for _, ply in pairs(self[ply_class]) do
				ply:Strip()
				ply:SetupLoadout()
			end
		end
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
	self:AddHook("StartStateWaiting", "ClearEntities", MinigameService.ClearEntities)
	self:AddHook("StartStatePlaying", "PickPlayerClasses", self.PickPlayerClasses)
	self:AddStateHook("Playing", "PlayerJoin", "Respawn", self.Respawn)
	self:AddStateHook("Playing", "PlayerJoin", "SetDefaultPlayerClass", self.SetDefaultPlayerClass)
	self:AddStateHook("Playing", "PlayerDeath", "ForfeitDeadPlayerClassToClosest", self.ForfeitDeadPlayerClassToClosest)
	self:AddStateHook("Playing", "PlayerDeath", "ForfeitPlayerClassToAttacker", self.ForfeitPlayerClassToAttacker)
	self:AddStateHook("Playing", "PlayerDeath", "SetPlayerClassOnDeath", self.SetPlayerClassOnDeath)
	self:AddStateHook("Playing", "PlayerLeave", "ReplacePlayerClass", self.ReplacePlayerClass)
	self:AddStateHook("Playing", "PlayerLeave", "ForfeitDepartedPlayerClassToClosest", self.ForfeitDepartedPlayerClassToClosest)
	self:AddStateHook("Playing", "PlayerClassChange", "EndIfNoPlayerClasses", self.CheckIfNoPlayerClasses)
	self:AddStateHook("Playing", "SettingsChange", "ReloadLoadouts", self.ReloadLoadouts)

	hook.Run("CreateMinigameHooks", self)
end

function MinigamePrototype:AddRequirePlayersHooks()
	self:AddStateHook("Waiting", "PlayerJoin", "RequirePlayers", self.StartOnEnoughPlayers)
	self:AddHook("PlayerLeave", "RequirePlayers", self.WaitOnInsufficientPlayers)
end