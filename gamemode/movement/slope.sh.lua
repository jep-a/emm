SlopeService = SlopeService or {}


-- # Properties

function SlopeService.InitPlayerProperties(ply)
	ply.bounce_height = 12
	ply.on_slope = false
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"SlopeService.InitPlayerProperties",
	SlopeService.InitPlayerProperties
)


-- # Slope Boost

function SlopeService.AddSpeed(ply, normal, vel)
	if 1 > normal.z and ply:OnGround() and not ply.on_slope and 0 >= ply.old_velocity.z then
		local old_velocity = ply.old_velocity
		local dot
		
		old_velocity.z = old_velocity.z - (ply.gravity * FrameTime() * 0.5)
		vel = old_velocity - (normal * old_velocity:Dot(normal))
		dot = vel:Dot(normal)

		if 0 > dot then
			vel = vel - (normal * dot)
		end

		vel.z = 0
		old_velocity.z = 0

		if vel:LengthSqr() > old_velocity:LengthSqr() then
			return vel
		end
	end

	return vel
end

function SlopeService.SetupSlopeBoost(ply, move)
	local vel = move:GetVelocity()
	local slope_boost = SlideService.Trace(ply, vel, move:GetOrigin())

	if slope_boost and not slope_boost.StartSolid and slope_boost.HitNormal.z < 1 then
		move:SetVelocity(SlopeService.AddSpeed(ply, slope_boost.HitNormal, vel))
	end
end
hook.Add("SetupMove", "SlopeService.SetupSlopeBoost", SlopeService.SetupSlopeBoost)


-- # Ledge Bounce

function SlopeService.LedgeBounce(ply, vel, pos, wish_dir)
	local pred_vel = vel * FrameTime() * 4
	local bounce_height = Vector(0, 0, ply.bounce_height)
	local bottom_trace = util.TraceHull {
		start = pos,
		endpos = pos + pred_vel,
		mins = ply:OBBMins(),
		maxs = Vector(ply:OBBMaxs().x, ply:OBBMaxs().y) + bounce_height,
		mask = MASK_PLAYERSOLID_BRUSHONLY
	}
	
	if bottom_trace.HitWorld and bottom_trace.HitNormal.z == 0 and vel.z > -ply:GetJumpPower() and vel:Length2D() > 500 then
		local can_bounce = bottom_trace.HitNormal:Dot(wish_dir:GetNormalized())
		local top_trace = util.TraceHull {
			start = pos + bounce_height,
			endpos = pos + bounce_height + pred_vel,
			mins = ply:OBBMins(),
			maxs = ply:OBBMaxs() - bounce_height,
			mask = MASK_PLAYERSOLID_BRUSHONLY
		}

		if 
			1 > bottom_trace.Fraction and 
			bottom_trace.Fraction > 0 and 
			not top_trace.HitWorld and 
			can_bounce < 0.5 and
			can_bounce ~= 0
		then
			return bottom_trace.HitNormal
		end
	end
	
	return false
end

function SlopeService.SetupSlope(ply, move)
	local wish_dir = AiraccelService.WishDir(ply, move:GetMoveAngles():Forward(), move:GetForwardSpeed(), move:GetSideSpeed())
	local ledge_normal = SlopeService.LedgeBounce(ply, move:GetVelocity(), move:GetOrigin(), wish_dir) 
	local normal

	if ply:OnGround() then
		ply.on_slope = true
	else
		ply.on_slope = false
	end

	if ledge_normal then
		normal = ledge_normal:Angle()
		normal.x = 315
		normal = normal:Forward()
		ply:SetGroundEntity(NULL)
		move:SetVelocity(SlideService.Clip(move:GetVelocity(), normal))
	end

end
hook.Add("Move", "SlopeService.SetupSlope", SlopeService.SetupSlope)