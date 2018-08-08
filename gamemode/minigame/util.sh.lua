function MinigameService.IsSharingLobby(a, b)
	local sharing
	local lobby_a
	local lobby_b

	if isentity(a) then
		lobby_a = a.lobby
	else
		lobby_a = a
	end

	if isentity(b) then
		lobby_b = b.lobby
	else
		lobby_b = b
	end

	if lobby_a and lobby_b and lobby_a == lobby_b then
		sharing = true
	else
		sharing = false
	end

	return sharing
end
