function SequentialTableHasValue(tab, val)
	for i = 1, #tab do
		if val == tab[i] then
			return true
		end
	end

	return false
end

function IsColor(color)
	return istable(color) and color.r and color.g and color.b
end

local local_ply

function IsLocalPlayer(ply)
	local_ply = local_ply or LocalPlayer()

	return local_ply == ply
end