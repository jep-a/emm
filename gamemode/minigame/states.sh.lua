MinigameService.states = MinigameService.states or {}

MinigameService.states.Waiting = {
	id = 1,
	name = "Waiting",
	next = "Starting"
}

MinigameService.states.Starting = {
	id = 2,
	name = "Starting",
	time = 5,
	next = "Playing"
}

MinigameService.states.Playing = {
	id = 3,
	name = "Playing",
	next = "Ending"
}

MinigameService.states.Ending = {
	id = 4,
	name = "Ending",
	time = 5,
	next = "Starting"
}

MinigamePrototype = MinigamePrototype or {}

function MinigameService.State(lobby, id)
	for _, state in pairs(lobby.states) do
		if id == state.id then
			return state
		end
	end
end

function MinigamePrototype:AddState(state)
	state.id = table.Count(self.states) + 1
	state.key = state.key or state.name
	self.states[state.key] = state
end