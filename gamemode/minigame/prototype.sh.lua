MinigamePrototype = MinigamePrototype or Class.New()

function MinigamePrototype:Init()
	self.player_classes = {}
	self.states = {}
	self.hooks = {}
	self.state_hooks = {}
	self.display = true
	self.default_state = "Waiting"
	self.required_players = 2

	self:AddDefaultStates()
	self:AddRequirePlayersHooks()
end

function MinigamePrototype:AddPlayerClass(ply_class)
	ply_class.id = table.Count(self.player_classes) + 1
	ply_class.key = ply_class.key or ply_class.name
	ply_class.color = ply_class.color or self.color
	self.player_classes[ply_class.key] = ply_class
end

function MinigamePrototype:AddHook(hk_name, hk_id, func)
	self.hooks[hk_name] = self.hooks[hk_name] or {}
	self.hooks[hk_name][hk_id] = func
end

function MinigamePrototype:RemoveHook(hk_name, hk_id)
	self.hooks[hk_name][hk_id] = nil
end

function MinigamePrototype:AddStateHook(state_key, hk_name, hk_id, func)
	self.state_hooks[state_key] = self.state_hooks[state_key] or {}
	self.state_hooks[state_key][hk_name] = self.state_hooks[state_key][hk_name] or {}
	self.state_hooks[state_key][hk_name][hk_id] = func
end

function MinigamePrototype:RemoveStateHook(state_key, hk_name, hk_id)
	self.state_hooks[state_key][hk_name][hk_id] = nil
end

function MinigamePrototype:AddDefaultStates()
	self:AddState {
		name = "Waiting",
		next = "Starting"
	}
	
	self:AddState {
		name = "Starting",
		time = 3,
		next = "Playing"
	}
	
	self:AddState {
		name = "Playing",
		next = "Ending"
	}
	
	self:AddState {
		name = "Ending",
		time = 3,
		next = "Starting"
	}
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