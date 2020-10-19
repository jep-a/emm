function MinigameStateService.StartStateTimer(lobby)
	timer.Create("MinigameStateService."..lobby.id, lobby.state.time, 1, function ()
		MinigameService.CallNetHook(lobby, "StateExpired")
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
		MinigameService.CallHook(self, "EndState", old_state, state)
		MinigameService.CallHook(self, "EndState"..state.name, old_state, state)
	end

	self.state = state
	self.last_state_start = CurTime()

	if state.time then
		MinigameStateService.StartStateTimer(self)
	end

	MinigameService.CallHook(self, "StartState", old_state, state)
	MinigameService.CallHook(self, "StartState"..state.name, old_state, state)
	hook.Run("LobbyStateChange", lobby, old_state, state)
	NetService.Broadcast("LobbyState", self, state.id, self.last_state_start)
end

function MinigameLobby:NextState()
	self:SetState(self.states[self.state.next])
end