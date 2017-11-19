RampFixService = RampFixService or {}


-- # Prediction handling

player_last_velocity = player_last_velocity or TimeAssociatedMapService.CreateMap(2, function() return LocalPlayer().last_velocity end) 
player_last_ramp = player_last_ramp or TimeAssociatedMapService.CreateMap(2, function() return LocalPlayer().last_ramp end) 
player_on_ramp = player_on_ramp or TimeAssociatedMapService.CreateMap(2, function() return LocalPlayer().on_ramp end) 

function RampFixService.LastRampVelocity(ply)
    return player_last_velocity:Value()
end

function RampFixService.LastRamp(ply)
    return player_last_ramp:Value()
end

function RampFixService.OnRamp(ply)
    return player_on_ramp:Value()
end