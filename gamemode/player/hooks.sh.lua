hook.Add("PlayerProperties", "SetCollisionCheck", function (ply)
	ply:SetCustomCollisionCheck(true)
end)

hook.Add("ShouldCollide", "EMM.ShouldCollide", function (a, b)
	if a.lobby and b.lobby and a.lobby == b.lobby then
		return true
	else
		return false
	end
end)
