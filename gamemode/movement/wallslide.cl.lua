WallslideService = WallslideService or {}


-- # Prediction handling

player_has_stamina = player_has_stamina or TimeAssociatedMapService.CreateMap(2, function() return LocalPlayer().stamina.wallslide:HasStamina() end)

function WallslideService.HasStamina(ply)
	return player_has_stamina:Value()
end