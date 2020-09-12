SlopeService = SlopeService or {}


-- # Properties

function SlopeService.InitPlayerProperties(ply)
	ply.bounce_height = 12
	ply.slope_onground = false
	ply.last_vel = Vector()
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"SlopeService.InitPlayerProperties",
	SlopeService.InitPlayerProperties
)


-- # Slope Boost

function SlopeService.AddSpeed(normal, ply, move)
	if 1 > normal.z and ply:OnGround() and not ply.slope_onground and 0 >= ply.last_vel.z then
		local last_vel = ply.last_vel
		local dot, vel
		
		last_vel.z = last_vel.z - (ply.gravity * FrameTime() * 0.5)
		vel = last_vel - (normal * last_vel:Dot(normal))
		dot = vel:Dot(normal)

		if 0 > dot then
			vel = vel - (normal * dot)
		end

		vel.z = 0
		last_vel.z = 0

		if vel:LengthSqr() > last_vel:LengthSqr() then
			move:SetVelocity(vel)
		end
	end
end


-- # Ledge Bounce

function SlopeService.LedgeBounce(ply, move)
	local pos = move:GetOrigin()
	local vel = move:GetVelocity()
	local bounce_height = Vector(0, 0, ply.bounce_height)
	local pred_vel = (vel * FrameTime() * 4)
	local ledge_trace = util.TraceHull {
		start = pos,
		endpos = pos + pred_vel,
		mins = ply:OBBMins(),
		maxs = Vector(ply:OBBMaxs().x, ply:OBBMaxs().y) + bounce_height,
		mask = MASK_PLAYERSOLID_BRUSHONLY
	}
	local wall_trace = util.TraceHull {
		start = pos + bounce_height,
		endpos = pos + bounce_height + pred_vel,
		mins = ply:OBBMins(),
		maxs = ply:OBBMaxs() - bounce_height,
		mask = MASK_PLAYERSOLID_BRUSHONLY
	
	}
	
	if 
		ledge_trace.HitWorld and
		1 > ledge_trace.Fraction and 
		ledge_trace.Fraction > 0 and 
		ledge_trace.HitNormal.z == 0 and 
		not wall_trace.HitWorld and 
		vel.z > -50 and 
		vel:Length2D() > 500 and 
		ledge_trace.HitNormal:Dot(AiraccelService.WishDir(ply, move):GetNormalized()) < 0.5
	then
		return ledge_trace.HitNormal
	end
	
	return false
end

function SlopeService.SetupSlope(ply, move)
	local ledge_normal = SlopeService.LedgeBounce(ply, move) 
	
	if ply:OnGround() then
		ply.slope_onground = true
	else
		ply.slope_onground = false
	end
	
	if ledge_normal then
		local normal = ledge_normal:Angle()

		normal.x = 315
		normal = normal:Forward()
		ply:SetGroundEntity(NULL)
		move:SetVelocity(SlideService.Clip(move:GetVelocity(), normal))
	end

	ply.last_vel = move:GetVelocity()
end
hook.Add("Move", "SlopeService.SetupSlope", SlopeService.SetupSlope)