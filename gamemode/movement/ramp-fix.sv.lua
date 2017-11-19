RampFixService = RampFixService or {}


-- # Prediction handling

function RampFixService.LastRampVelocity(ply)
    return ply.last_velocity
end

function RampFixService.LastRamp(ply)
    return ply.last_ramp
end

function RampFixService.OnRamp(ply)
    return ply.on_ramp
end