WallslideService = WallslideService or {}


-- # Prediction handling

function WallslideService.HasStamina(ply)
	return ply.stamina.wallslide:HasStamina()
end