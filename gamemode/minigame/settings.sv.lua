function MinigameSettingsService.WriteSettings(lobby)
	local settings = {}

	for k, _ in pairs(lobby.changed_settings) do
		settings[k] = MinigameSettingsService.Setting(lobby, k)
	end

	net.WriteTable(settings)
end

function MinigameSettingsService.Save(ply, lobby, settings)
	MinigameSettingsService.SortChanges(lobby.original_settings, lobby.changed_settings, settings)

	if lobby.host == ply then
		MinigameSettingsService.Adjust(lobby, settings)
		NetService.Send("LobbySettings", lobby, settings)
	end

	hook.Run("LobbySettingsChange", lobby, settings)
end

NetService.Receive("LobbySettings", MinigameSettingsService.Save)