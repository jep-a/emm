MinigameLobby = MinigameLobby or {}

function MinigameLobby:SetState(state)
	self.state = state
	MinigameService.CallHook(self, "StartState"..state.name, state)
	hook.Run("LobbySetState", lobby, state)

	if self:IsLocal() then
		hook.Run("LocalLobbySetState", self, state)
	end
end