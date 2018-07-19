function StateService.StartStateTimer(lobby)
	timer.Create("StateService."..lobby.id, lobby.state.time, 1, function ()
		lobby:NextState()
	end)
end

function StateService.EndStateTimer(lobby)
	timer.Remove("StateService."..lobby.id)
end

function MinigameLobby:SetState(state)
	if self.state and self.state.time then
		StateService.EndStateTimer(self)
	end

	self.state = state
	self.last_state_start = CurTime()

	if state.time then
		StateService.StartStateTimer(self)
	end

	MinigameService.CallHook(self, "StartState"..state.name, state)
	hook.Run("LobbySetState", lobby, state)
	MinigameService.NetworkLobbySetState(self)
end

function MinigameLobby:NextState()
	self:SetState(self.states[self.state.next])
end