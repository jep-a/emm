WallslideService = WallslideService or {}


-- # Time Mapped Variables

player_has_wallslide_stamina = player_has_wallslide_stamina or TimeAssociatedMapService.CreateMap(2, function() return LocalPlayer().stamina.wallslide:HasStamina() end)
player_is_wallsliding = player_is_wallsliding or TimeAssociatedMapService.CreateMap(2, function() return LocalPlayer().wallsliding end)
player_last_wallslide_time = player_last_wallslide_time or TimeAssociatedMapService.CreateMap(2, function() return LocalPlayer().last_wallslide_time end)
player_wallslide_velocity = player_wallslide_velocity or TimeAssociatedMapService.CreateMap(2, function() return LocalPlayer().wallslide_velocity end)
started_wallsliding = started_wallsliding or TimeAssociatedMapService.CreateMap(2, function() return false end)
finished_wallsliding = finished_wallsliding or TimeAssociatedMapService.CreateMap(2, function() return false end)


-- # Client Functions

function WallslideService.HasStamina(ply)
	return player_has_wallslide_stamina:Value()
end

function WallslideService.IsWallsliding(ply)
	return player_is_wallsliding:Value()
end

function WallslideService.UpdateWallsliding(ply)
	return player_is_wallsliding:Update()
end

function WallslideService.StartedWallslide(ply)
	return started_wallsliding:HasChecked() or started_wallsliding:Value()
end

function WallslideService.FinishedWallslide(ply)
	return finished_wallsliding:HasChecked() or finished_wallsliding:Value()
end

function WallslideService.LastWallslideTime(ply)
	return player_last_wallslide_time:Value()
end

function WallslideService.WallslideVelocity(ply)
	return player_wallslide_velocity:Value()
end