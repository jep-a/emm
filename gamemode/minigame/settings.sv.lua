function MinigameSettingsService.Save(ply, lobby, settings)
	if lobby.host == ply then
		MinigameSettingsService.SortChanges(lobby.original_settings, lobby.changed_settings, settings)
		MinigameSettingsService.Adjust(lobby, settings)
		NetService.Broadcast("LobbySettings", lobby, settings)
		hook.Run("LobbySettingsChange", lobby, settings)
		MinigameService.CallHook(lobby, "SettingsChange", settings)
	end
end

NetService.Receive("LobbySettings", MinigameSettingsService.Save)