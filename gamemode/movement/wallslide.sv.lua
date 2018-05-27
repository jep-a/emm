WallslideService = WallslideService or {}


-- # Prediction handling

function WallslideService.HasStamina(ply)
	return ply.stamina.wallslide:HasStamina()
end

function WallslideService.Wallsliding(ply)
	return ply.wallsliding
end

function WallslideService.StartedWallslide(ply)
	return false
end

function WallslideService.FinishedWallslide(ply)
	return false
end

function WallslideService.LastWallslideTime(ply)
	return ply.last_wallslide_time
end

function WallslideService.WallslideVelocity(ply)
	return ply.wallslide_velocity
end