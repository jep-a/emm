function MinigameLobby:SetState(state, last_state_start)
	local old_state = self.state

	self.state = state
	self.last_state_start = last_state_start or CurTime()
	MinigameService.CallHook(self, "StartState", old_state, state)
	MinigameService.CallHook(self, "StartState"..state.name, old_state, state)
	hook.Run("LobbySetState", lobby, old_state, state)

	if self:IsLocal() then
		hook.Run("LocalLobbySetState", self, old_state, state)
	end
end