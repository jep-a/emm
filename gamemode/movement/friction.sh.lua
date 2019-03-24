FrictionService = FrictionService or {}


-- # Properties

function FrictionService.InitPlayerProperties(ply)
	ply.friction = 8
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"FrictionService.InitPlayerProperties",
	FrictionService.InitPlayerProperties
)


-- # Friction

function FrictionService.Velocity(ply, move)
  local vel = move:GetVelocity()
  local	speed = vel:Length()
  local	drop = 0
  local newspeed, control
  if (speed < GetConVar( "sv_stopspeed" ):GetFloat()) then
    control = GetConVar( "sv_stopspeed" ):GetFloat()
  else
    control = speed
  end
  drop = drop + (control * ply.friction * FrameTime())
  newspeed = speed - drop
  if newspeed < 0 then
  	newspeed = 0
  end
  if newspeed != speed then
  	newspeed = newspeed / speed
    vel = vel * newspeed
  end
  return vel
end


function FrictionService.SetupFriction(ply, move)
  if move:GetVelocity():Length() < 0.1 or ply:GetGroundEntity() == NULL or (move:KeyPressed(IN_JUMP) and not move:KeyWasDown(IN_JUMP)) then
    return
  end
  move:SetVelocity(FrictionService.Velocity(ply, move))
end

hook.Add("SetupMove", "FrictionService.SetupFriction", FrictionService.SetupFriction)
