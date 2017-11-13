WallslideService = WallslideService or {}


-- # Prediction handling

player_has_stamina = player_has_stamina or TimeAssociatedMapService.CreateMap(2, function() return LocalPlayer().stamina.wallslide:HasStamina() end)
player_is_wallsliding = player_is_wallsliding or TimeAssociatedMapService.CreateMap(2, function() return LocalPlayer().wallsliding end)
started_wallsliding = started_wallsliding or TimeAssociatedMapService.CreateMap(2, function() return false end)

function WallslideService.HasStamina(ply)
	return player_has_stamina:Value()
end

function WallslideService.IsWallsliding(ply)
	return player_is_wallsliding:Value()
end

function WallslideService.StartedWallslide(ply)
	return started_wallsliding:HasChecked() or started_wallsliding:Value()
end