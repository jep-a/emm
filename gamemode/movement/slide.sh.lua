SlideService = SlideService or {}


-- # Properties

function SlideService.InitPlayerProperties(ply)
	ply.can_slide = false
	ply.slide_minimum = 0.71
	ply.slide_hover_height = 4
	ply.slide_onground = false
	ply.sliding = false
	ply.surfing = false
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"SlideService.InitPlayerProperties",
	SlideService.InitPlayerProperties
)

SLIDE_MAX_TRACES = 4


-- # Util

function SlideService.GetNormalDir(vector)
	return Vector(math.ceil(vector.x) + math.floor(vector.x), math.ceil(vector.y) + math.floor(vector.y), math.ceil(vector.z) + math.floor(vector.z))
end

function SlideService.Clip(vel, plane)
	return vel - (plane * vel:Dot(plane))
end

function SlideService.MovingTowardsPlane(vel, plane)
	return (0 > Vector(vel.x, vel.y):Dot(Vector(plane.x, plane.y)) and true) or false
end

function SlideService.GetGroundTrace(pos, end_pos, ply)
	return util.TraceHull {
		start = pos,
		endpos = end_pos,
		mins = ply:OBBMins(),
		maxs = ply:OBBMaxs() + Vector(0,0,2),
		mask = MASK_PLAYERSOLID_BRUSHONLY
	}
end

function SlideService.Trace(ply, vel, pos, move)
	local pred_vel = vel * FrameTime()
	local hover_height = Vector(0, 0, ply.slide_hover_height)
	local slide = ply.surfing or ply.sliding
	local trace
	local offset = (ply:OnGround() and Vector(0, 0, 1)) or Vector(0, 0, 0)
	local area_trace = util.TraceHull {
		start = pos,
		endpos = pos + (pred_vel * 3) - hover_height*5,
		mins = ply:OBBMins() - offset,
		maxs = ply:OBBMaxs() + offset + Vector(0, 0, 2),
		mask = MASK_PLAYERSOLID_BRUSHONLY
	}
	local ramp_normal = (area_trace and ((slide and slide.HitNormal) or area_trace.HitNormal)) or Vector()
	local slide_pos = pos - (ramp_normal * (hover_height.z)) 

	if slide then
		trace = SlideService.GetGroundTrace(pos, slide_pos - hover_height * 2, ply)

		if slide.is_init then
			trace.HitPos.z = slide.HitPos.z
			slide.is_init = false
		end
	else
		if 0 > vel.z and not ply:OnGround() then
			if SlideService.MovingTowardsPlane(vel, ramp_normal) or ramp_normal:LengthSqr() == 0 then
				slide_pos = pos + pred_vel - hover_height
			else
				slide_pos = pos + Vector(0, 0, pred_vel.z) - hover_height
			end

			trace = SlideService.GetGroundTrace(pos, slide_pos, ply)
			trace.is_init = true
		else
			trace = SlideService.GetGroundTrace(pos, slide_pos - hover_height, ply)
			trace.is_init = true
		end
	end

	if trace.HitNormal:LengthSqr() ~= 0 then
		local trace_distance = 3
		local corr_trace_pos = (SlideService.Clip(vel, trace.HitNormal):GetNormalized()) * trace_distance
		local crease_trace

		if 0 > vel.z then
			ramp_normal.x = ramp_normal.y
			ramp_normal.y = ramp_normal.x
		end

		corr_trace_pos = Vector(corr_trace_pos.x * math.abs(ramp_normal.y), corr_trace_pos.y * math.abs(ramp_normal.x), corr_trace_pos.z) * trace_distance
		corr_trace = SlideService.GetGroundTrace(pos, pos - (hover_height * trace_distance) + corr_trace_pos + (ramp_normal * Vector(1,1)), ply)

		if corr_trace.HitNormal ~= trace.HitNormal and corr_trace.HitNormal.z > 0 and 1 > corr_trace.HitNormal.z then
			trace.HitNormal = (corr_trace.HitNormal + trace.HitNormal)/2
		end
		return trace
	end
	return false
end

function SlideService.ShouldSlide(ply, normal, vel)
	local slide_vel = SlideService.Clip(vel, normal)

	if 
		(SlideService.MovingTowardsPlane(vel, normal) and
		1 > normal.z and
		normal.z > ply.slide_minimum and
		vel:Dot(vel) > 900 and
		((not ply.sliding and 
		slide_vel.z and slide_vel.z > 150 or vel.z > 150) or 
		ply.sliding))
	then
		return true
	end

	return false
end


function SlideService.ShouldSurf(ply, normal, vel)
	if normal.z > 0 and ply.slide_minimum >= normal.z then
		return true
	end

	return false
end


-- # Sliding

function SlideService.SlideStrafe(move, normal)
	local wish_dir = AiraccelService.WishDir(ply, move:GetMoveAngles():Forward(), move:GetForwardSpeed(), move:GetSideSpeed())

	if normal:Dot(wish_dir:GetNormalized()) > 0 and move:GetVelocity():Dot(normal) > 0 then
		return true
	end

	return false
end

function SlideService.Slide(ply, move, trace, slide_vel)
	if not (ply.sliding or ply.surfing)  then
		ply.sliding = (SlideService.ShouldSlide(ply, trace.HitNormal, slide_vel) and trace) or false
		ply.surfing = (SlideService.ShouldSurf(ply, trace.HitNormal, slide_vel) and trace) or false
	end

	if ply.sliding or ply.surfing then
		local pos = move:GetOrigin()

		pos.z = trace.HitPos.z + ply.slide_hover_height
		ply:SetGroundEntity(NULL)
		move:SetVelocity(slide_vel)
		move:SetOrigin(pos)
	end
end

function SlideService.HandleSlideDamage(ply)
	local vel = ply:GetVelocity()
	local pos = ply:GetPos()
	local trace = SlideService.Trace(ply, vel, pos)

	if trace then
		if (SlideService.ShouldSlide(ply, trace.HitNormal, vel) or SlideService.ShouldSurf(ply, trace.HitNormal, vel)) then
			pos.z = trace.HitPos.z + ply.slide_hover_height
			ply.slide_onground = {SlideService.Clip(vel, trace.HitNormal), pos}
			ply:SetGroundEntity(NULL)
		end
	end
end
hook.Add("OnPlayerHitGround", "SlideService.HandleSlideDamage", SlideService.HandleSlideDamage)

function SlideService.SetupSlide(ply, move, cmd)
	local traces = {}
	local trace_count = 0

	if ply.slide_onground then
		move:SetVelocity(ply.slide_onground[1])
		move:SetOrigin(ply.slide_onground[2])
		ply.slide_onground = false
	end

	for i = 1, SLIDE_MAX_TRACES do
		local vel = move:GetVelocity()
		local pos = move:GetOrigin()
		local trace = SlideService.Trace(ply, vel, pos)

		if trace then
			trace.should_slide = SlideService.ShouldSlide(ply, trace.HitNormal, vel) or SlideService.ShouldSurf(ply, trace.HitNormal, vel)

			if trace_count >= 1 then
				local is_same_plane = false

				for j = 1, trace_count do
					if i > j then
						if traces[j].HitNormal == trace.HitNormal and trace.HitNormal.z > 0 and 1 > trace.HitNormal.z then
							is_same_plane = true
							break
						end
					end
				end

				if is_same_plane then
					break
				end
			end

			if 1 > trace.HitNormal.z and not trace.StartSolid and trace.should_slide then
				trace_count = trace_count + 1
				traces[trace_count] = trace

				if SlideService.SlideStrafe(move, trace.HitNormal) or ply:OnGround() then
					ply:SetGroundEntity(NULL)
					move:SetVelocity(vel)
					move:SetOrigin(pos)
					trace.should_slide = false
				else
					SlideService.Slide(ply, move, trace, SlideService.Clip(vel, trace.HitNormal))
				end
			end
		end

		if not trace or (trace and not trace.should_slide) then
			ply.sliding = false
			ply.surfing = false
		end
	end
end
hook.Add("PlayerTick", "SlideService.SetupSlide", SlideService.SetupSlide)