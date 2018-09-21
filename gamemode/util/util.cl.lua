local local_ply

function IsLocalPlayer(ply)
	local_ply = local_ply or LocalPlayer()

	return local_ply == ply
end

cached_png_materials = cached_png_materials or {}

function PNGMaterial(mat)
	if not cached_png_materials[mat] then
		cached_png_materials[mat] = Material(mat, "noclamp smooth")
	end

	return cached_png_materials[mat]
end