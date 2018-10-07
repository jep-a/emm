function MinigameSettingsService.Save(ply, lobby, settings)
	MinigameSettingsService.SortChanges(lobby.original_settings, lobby.changed_settings, settings)

	if lobby.host == ply then
		MinigameSettingsService.Adjust(lobby, settings)
		NetService.Send("LobbySettings", lobby, settings)
	end

	hook.Run("LobbySettingsChange", lobby, settings)
	MinigameService.CallHook(lobby, "SettingsChange", settings)
end

NetService.Receive("LobbySettings", MinigameSettingsService.Save)