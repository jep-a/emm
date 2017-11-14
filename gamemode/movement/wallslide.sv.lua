WallslideService = WallslideService or {}


-- # Prediction handling

function WallslideService.HasStamina(ply)
	return ply.stamina.wallslide:HasStamina()
end

function WallslideService.IsWallsliding(ply)
	return ply.wallsliding
end

function WallslideService.StartedWallslide(ply)
	return false
end

function WallslideService.FinishedWallslide(ply)
	return false
end