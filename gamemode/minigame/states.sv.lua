MinigameLobby = MinigameLobby or {}

function MinigameLobby:SetState(state)
	self.state = state
	MinigameService.CallHook(self, "StartState"..state.name, state)
	hook.Run("LobbySetState", lobby, state)
	MinigameService.NetworkLobbySetState(self)
end

function MinigameLobby:NextState()
	self:SetState(self.states[self.state.next])
end