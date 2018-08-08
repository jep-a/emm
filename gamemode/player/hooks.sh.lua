hook.Add("InitPlayerProperties", "InitPlayerColor", function (ply)
	ply.color = COLOR_WHITE
end)

hook.Add("PlayerProperties", "SetCollisionCheck", function (ply)
	ply:SetCustomCollisionCheck(true)
end)

hook.Add("ShouldCollide", "EMM.ShouldCollide", function (a, b)
	if MinigameService.IsSharingLobby(a, b) then
		return true
	else
		return false
	end
end)
