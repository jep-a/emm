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

function GetAnimatableEntityColor(ent)
	local color

	if IsValid(ent) and ent.animatable_color then
		color = ent.animatable_color.smooth
	else
		color = COLOR_WHITE_CLEAR
	end

	return color
end
