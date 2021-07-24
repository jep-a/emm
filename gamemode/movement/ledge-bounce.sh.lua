LedgeBounce = LedgeBounce or {}


-- # Properties

function LedgeBounce.InitPlayerProperties(ply)
	ply.bounce_height = 21
	ply.bounce_angle = 45
	ply.bounce_min_vel = 500^2
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"LedgeBounce.InitPlayerProperties",
	LedgeBounce.InitPlayerProperties
)


-- # Ledge Bounce

function LedgeBounce.DoBounce(ply, vel, pos, wish_dir)
	if vel.z > -ply:GetJumpPower() and vel:Length2DSqr() > ply.bounce_min_vel then
		local pred_vel = vel * FrameTime() * 4
		local bounce_height = Vector(0, 0, ply.bounce_height)
		local ply_mins = ply:OBBMins()
		local ply_maxs = ply:OBBMaxs()
		local bottom_trace = util.TraceHull {
			start = pos,
			endpos = pos + pred_vel,
			mins = ply_mins,
			maxs = Vector(ply_maxs.x, ply_maxs.y, ply.bounce_height),
			mask = MASK_PLAYERSOLID_BRUSHONLY
		}
		local can_bounce = bottom_trace.HitNormal:Dot(wish_dir:GetNormalized())

		if bottom_trace.HitWorld and 0.5 > can_bounce and can_bounce ~= 0 then
			local trace_pos = bottom_trace.HitPos + bottom_trace.HitNormal + pred_vel
			local top_trace = util.TraceHull {
				start = trace_pos + bounce_height,
				endpos = trace_pos,
				mins = ply_mins,
				maxs = ply_maxs - bounce_height,
				mask = MASK_PLAYERSOLID_BRUSHONLY
			}

			if 1 > bottom_trace.Fraction and bottom_trace.Fraction > 0 and top_trace.HitWorld and not top_trace.StartSolid and top_trace.HitNormal ~= bottom_trace.HitNormal then
				return bottom_trace.HitNormal
			end
		end
	end

	return false
end

function LedgeBounce.SetupBounce(ply, move)
	local vel = move:GetVelocity()
	local ledge_normal = LedgeBounce.DoBounce(ply, vel, move:GetOrigin(), AiraccelService.WishDir(ply, move:GetMoveAngles():Forward(), move:GetForwardSpeed(), move:GetSideSpeed())) 

	if ledge_normal then
		local normal = ledge_normal:Angle()

		normal.x = 360 - ply.bounce_angle
		normal = normal:Forward()
		ply:SetGroundEntity(NULL)
		move:SetVelocity(SlideService.Clip(vel, normal))
	end
end
hook.Add("Move", "LedgeBounce.SetupBounce", LedgeBounce.SetupBounce)