function MinigameSettingsService.Save(lobby, settings)
	MinigameSettingsService.SortChanges(lobby.original_settings, lobby.changed_settings, settings)
	MinigameSettingsService.Adjust(lobby, settings)
	hook.Run("LobbySettingsChange", lobby, settings)

	if lobby:IsLocal() then
		hook.Run("LocalLobbySettingsChange", lobby, settings)
	end
end

NetService.Receive("LobbySettings", MinigameSettingsService.Save)