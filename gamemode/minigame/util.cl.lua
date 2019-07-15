function MinigameService.IsLocalLobby(ent_or_lobby)
	local is_local
	local lobby

	if isentity(ent_or_lobby) then
		lobby = ent_or_lobby.lobby
	else
		lobby = lobby
	end

	local local_lobby = LocalPlayer().lobby

	if lobby and local_lobby and lobby == local_lobby then
		is_local = true
	else
		is_local = false
	end

	return is_local
end
