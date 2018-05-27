WallslideService = WallslideService or {}


-- # Time maps

local has_stamina = has_stamina or TimeAssociatedMapService.CreateMap(2, function()
	return LocalPlayer().stamina.wallslide:HasStamina()
end)

local wallsliding = wallsliding or TimeAssociatedMapService.CreateMap(2, function()
	return LocalPlayer().wallsliding
end)

local last_wallslide_time = last_wallslide_time or TimeAssociatedMapService.CreateMap(2, function()
	return LocalPlayer().last_wallslide_time
end)

local wallslide_velocity = wallslide_velocity or TimeAssociatedMapService.CreateMap(2, function() return
	LocalPlayer().wallslide_velocity
end)

local started_wallsliding = started_wallsliding or TimeAssociatedMapService.CreateMap(2, function()
	return false
end)

local finished_wallsliding = finished_wallsliding or TimeAssociatedMapService.CreateMap(2, function()
	return false
end)


-- # Client Functions

function WallslideService.HasStamina(ply)
	return has_stamina:Value()
end

function WallslideService.Wallsliding(ply)
	return wallsliding:Value()
end

function WallslideService.UpdateWallsliding(ply)
	return wallsliding:Update()
end

function WallslideService.StartedWallslide(ply)
	return started_wallsliding:HasChecked() or started_wallsliding:Value()
end

function WallslideService.FinishedWallslide(ply)
	return finished_wallsliding:HasChecked() or finished_wallsliding:Value()
end

function WallslideService.LastWallslideTime(ply)
	return last_wallslide_time:Value()
end

function WallslideService.WallslideVelocity(ply)
	return wallslide_velocity:Value()
end