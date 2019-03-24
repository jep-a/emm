GravityService = GravityService or {}


-- # Properties

function GravityService.InitPlayerProperties(ply)
	ply.gravity = 300
  ply.axis = Vector(0,0,-1)
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"GravityService.InitPlayerProperties",
	GravityService.InitPlayerProperties
)


-- # Gravity

function GravityService.Velocity(ply, move)
  local gravity = Vector(1,1,1) * (ply.gravity * FrameTime())
  gravity = gravity * ply.axis
  return move:GetVelocity() + gravity
end

function GravityService.SetupGravity(ply, move)

  if GetConVar( "sv_gravity" ):GetFloat() != 0 then
    local mult = GetConVar( "sv_gravity" ):GetFloat()/(GetConVar( "sv_gravity" ):GetFloat()*200)
    ply:SetGravity( mult )
    move:SetVelocity(move:GetVelocity() + Vector(0, 0, GetConVar( "sv_gravity" ):GetFloat() * mult * FrameTime()))
  end
  if ply:WaterLevel() > 1 or ply.gravity == 0 then return end
  move:SetVelocity(GravityService.Velocity(ply, move))

end
hook.Add("SetupMove", "GravityService.SetupGravity", GravityService.SetupGravity)
