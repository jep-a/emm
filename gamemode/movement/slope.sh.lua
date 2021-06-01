SlopeService = SlopeService or {}


-- # Properties

function SlopeService.InitPlayerProperties(ply)
	ply.bounce_height = 12
	ply.slope_left_ground = false
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"SlopeService.InitPlayerProperties",
	SlopeService.InitPlayerProperties
)


-- # Slope Boost

function SlopeService.AddSpeed(ply, normal, vel)
	if 1 > normal.z and ply:OnGround() and ply.slope_left_ground and 0 >= ply.old_velocity.z then
		local old_velocity = ply.old_velocity
		local dot
		
		old_velocity.z = old_velocity.z - (ply.gravity * FrameTime() * 0.5)
		vel = old_velocity - (normal * old_velocity:Dot(normal))
		dot = vel:Dot(normal)

		if 0 > dot then
			vel = vel - (normal * dot)
		end

		vel.z = 0
	end

	return vel
end

function SlopeService.SetupSlopeBoost(ply, move)
	local vel = move:GetVelocity()
	local slope_boost = SlideService.Trace(ply, vel, move:GetOrigin())

	if slope_boost and not slope_boost.StartSolid and 1 > slope_boost.HitNormal.z then
		move:SetVelocity(SlopeService.AddSpeed(ply, slope_boost.HitNormal, vel))
	end

	ply.slope_left_ground = not ply:OnGround() 
end
hook.Add("SetupMove", "SlopeService.SetupSlopeBoost", SlopeService.SetupSlopeBoost)


-- # Ledge Bounce

function SlopeService.LedgeBounce(ply, vel, pos, wish_dir)
	local pred_vel = vel * FrameTime() * 4
	local bounce_height = Vector(0, 0, ply.bounce_height)
	local ply_mins, ply_maxs = ply:OBBMins(), ply:OBBMaxs()
	local bottom_trace = util.TraceHull {
		start = pos,
		endpos = pos + pred_vel,
		mins = ply_mins,
		maxs = Vector(ply_maxs.x, ply_maxs.y) + bounce_height,
		mask = MASK_PLAYERSOLID_BRUSHONLY
	}
	
	if bottom_trace.HitWorld and bottom_trace.HitNormal.z == 0 and vel.z > -ply:GetJumpPower() and vel:Length2DSqr() > 250000 then
		local can_bounce = bottom_trace.HitNormal:Dot(wish_dir:GetNormalized())
		local top_trace = util.TraceHull {
			start = pos + bounce_height,
			endpos = pos + bounce_height + pred_vel,
			mins = ply_mins,
			maxs = ply_maxs - bounce_height,
			mask = MASK_PLAYERSOLID_BRUSHONLY
		}

		if 
			1 > bottom_trace.Fraction and 
			bottom_trace.Fraction > 0 and 
			not top_trace.HitWorld and 
			0.5 > can_bounce and
			can_bounce ~= 0
		then
			return bottom_trace.HitNormal
		end
	end
	
	return false
end

function SlopeService.SetupSlope(ply, move)
	local vel = move:GetVelocity()
	local ledge_normal = SlopeService.LedgeBounce(ply, vel, move:GetOrigin(), AiraccelService.WishDir(ply, move:GetMoveAngles():Forward(), move:GetForwardSpeed(), move:GetSideSpeed())) 

	if ledge_normal then
		local normal = ledge_normal:Angle()

		normal.x = 315
		normal = normal:Forward()
		ply:SetGroundEntity(NULL)
		move:SetVelocity(SlideService.Clip(move:GetVelocity(), normal))
	end

end
hook.Add("Move", "SlopeService.SetupSlope", SlopeService.SetupSlope)