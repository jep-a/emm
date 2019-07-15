MinigameStateService = MinigameStateService or {}

function MinigameStateService.State(lobby, k_or_id)
	for _, state in pairs(lobby.states) do
		if k_or_id == state.key or k_or_id == state.id then
			return state
		end
	end
end

function MinigamePrototype:CanRestart()
	return self.prototype.key ~= "Miscellaneous" and self.state == self.states.Playing or self.state == self.states.Starting
end

function MinigamePrototype:AddState(state)
	state.key = state.key or state.name
	state.id = self.states[state.key] and self.states[state.key].id or (table.Count(self.states) + 1)
	self.states[state.key] = state
end

function MinigamePrototype:AddDefaultStates()
	self:AddState {
		name = "Waiting",
		next = "Starting"
	}
	
	self:AddState {
		name = "Starting",
		time = 5,
		next = "Playing",
		notify_countdown = true
	}
	
	self:AddState {
		name = "Playing",
		next = "Ending",
		notify_countdown = true,
		notify_countdown_text = ""
	}
	
	self:AddState {
		name = "Ending",
		time = 5,
		next = "Starting",
		notify_countdown = true,
		notify_countdown_text = "restarting in"
	}
end