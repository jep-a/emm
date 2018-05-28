function MinigameService.State(lobby, id)
	for _, state in pairs(lobby.states) do
		if id == state.id then
			return state
		end
	end
end

function MinigamePrototype:AddState(state)
	state.key = state.key or state.name
	state.id = self.states[state.key] and self.states[state.key].id or (table.Count(self.states) + 1)
	self.states[state.key] = state
end