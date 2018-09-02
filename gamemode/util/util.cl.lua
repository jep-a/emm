local local_ply

function IsLocalPlayer(ply)
	local_ply = local_ply or LocalPlayer()

	return local_ply == ply
end