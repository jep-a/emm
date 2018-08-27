function MinigameStateService.StartStateTimer(lobby)
	timer.Create("MinigameStateService."..lobby.id, lobby.state.time, 1, function ()
		lobby:NextState()
	end)
end

function MinigameStateService.EndStateTimer(lobby)
	timer.Remove("MinigameStateService."..lobby.id)
end

function MinigameLobby:SetState(state)
	local old_state = self.state

	if old_state and old_state.time then
		MinigameStateService.EndStateTimer(self)
	end

	self.state = state
	self.last_state_start = CurTime()

	if state.time then
		MinigameStateService.StartStateTimer(self)
	end

	MinigameService.CallHook(self, "StartState"..state.name, old_state, state)
	hook.Run("LobbyStateChange", lobby, old_state, state)
	MinigameNetworkService.SendLobbyState(self)
end

function MinigameLobby:NextState()
	self:SetState(self.states[self.state.next])
end