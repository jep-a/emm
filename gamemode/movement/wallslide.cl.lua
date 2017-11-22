WallslideService = WallslideService or {}


-- # Time Mapped Variables

WallslideService.has_stamina = WallslideService.has_stamina or TimeAssociatedMapService.CreateMap(2, function() return LocalPlayer().stamina.wallslide:HasStamina() end)
WallslideService.wallsliding = WallslideService.wallsliding or TimeAssociatedMapService.CreateMap(2, function() return LocalPlayer().wallsliding end)
WallslideService.last_wallslide_time = WallslideService.last_wallslide_time or TimeAssociatedMapService.CreateMap(2, function() return LocalPlayer().last_wallslide_time end)
WallslideService.wallslide_velocity = WallslideService.wallslide_velocity or TimeAssociatedMapService.CreateMap(2, function() return LocalPlayer().wallslide_velocity end)
WallslideService.started_wallsliding = WallslideService.started_wallsliding or TimeAssociatedMapService.CreateMap(2, function() return false end)
WallslideService.finished_wallsliding = WallslideService.finished_wallsliding or TimeAssociatedMapService.CreateMap(2, function() return false end)


-- # Client Functions

function WallslideService.HasStamina(ply)
	return WallslideService.has_stamina:Value()
end

function WallslideService.IsWallsliding(ply)
	return WallslideService.wallsliding:Value()
end

function WallslideService.UpdateWallsliding(ply)
	return WallslideService.wallsliding:Update()
end

function WallslideService.StartedWallslide(ply)
	return WallslideService.started_wallsliding:HasChecked() or WallslideService.started_wallsliding:Value()
end

function WallslideService.FinishedWallslide(ply)
	return WallslideService.finished_wallsliding:HasChecked() or WallslideService.finished_wallsliding:Value()
end

function WallslideService.LastWallslideTime(ply)
	return WallslideService.last_wallslide_time:Value()
end

function WallslideService.WallslideVelocity(ply)
	return WallslideService.wallslide_velocity:Value()
end