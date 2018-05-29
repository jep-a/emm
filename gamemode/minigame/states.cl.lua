function MinigameLobby:SetState(state, last_state_start)
	self.state = state
	self.last_state_start = last_state_start or CurTime()
	MinigameService.CallHook(self, "StartState"..state.name, state)
	hook.Run("LobbySetState", lobby, state)

	if self:IsLocal() then
		hook.Run("LocalLobbySetState", self, state)
	end
end