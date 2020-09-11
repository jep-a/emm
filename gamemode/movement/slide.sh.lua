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


-- # Util

function SlideService.Clip(vel, plane)
	return vel - (plane * vel:Dot(plane))
end

function SlideService.GetGroundTrace(pos, end_pos, ply)
	return util.TraceHull {
		start = pos,
		endpos = end_pos,
		mins = ply:OBBMins(),
		maxs = ply:OBBMaxs(),
		mask = MASK_PLAYERSOLID_BRUSHONLY
	}
end

function SlideService.Trace(ply, vel, pos)
	local pred_vel = vel * FrameTime()
	local hover_height = Vector(0, 0, ply.slide_hover_height)
	local trace

	if not ply.sliding and not ply.surfing then
		if 0 > vel.z and not ply:OnGround() then
			trace = SlideService.GetGroundTrace(pos, pos + pred_vel - hover_height, ply)
		else
			if ply:OnGround() then
				trace = SlideService.GetGroundTrace(pos, pos - hover_height, ply)
			else
				trace = SlideService.GetGroundTrace(pos, pos + Vector(pred_vel.x, pred_vel.y, -hover_height.z), ply)
			end
		end
	else
		local slide = ply.surfing or ply.sliding
		local slide_pos = pos - Vector(0, 0, hover_height.z - slide.HitNormal.z)
		
		trace = SlideService.GetGroundTrace(pos + slide.HitNormal, slide_pos, ply)
		
		if trace.HitNormal.z == 0 then
			trace = SlideService.GetGroundTrace(pos, slide_pos - Vector(0, 0, 1) , ply)
		end
	end

	if trace.HitNormal:LengthSqr() ~= 0 then
		return trace
	end

	return false
end

function SlideService.ShouldSlide(ply, normal, vel, slide_vel_z)
	if (0 > Vector(normal.x, normal.y):Dot(Vector(vel.x, vel.y):GetNormalized()) and
		1 > normal.z and
		normal.z > ply.slide_minimum and
		vel:Dot(vel) > 900 and
		((not ply.sliding and slide_vel_z > 150) or ply.sliding)) or
		(normal.z > 0 and ply.slide_minimum >= normal.z)
	then
		return true
	end

	return false
end


-- # Sliding

function SlideService.SlideStrafe(move, cmd, normal)
	local forward, right = move:GetMoveAngles():Forward(), move:GetMoveAngles():Right()
	local wish_dir

	forward.z = 0
	right.z = 0
	
	wish_dir = (forward:GetNormalized() * cmd:GetForwardMove()) + (right:GetNormalized() * cmd:GetSideMove())
	wish_dir.z = 0
	wish_dir:Normalize()

	if (normal:Dot(wish_dir) > 0 and move:GetVelocity():Dot(normal) > 0) then
		return true
	end

	return false
end

function SlideService.Slide(ply, move, trace, slide_vel)
	if not ((ply.sliding or ply.surfing) and 0 > (slide_vel.z - move:GetVelocity().z)) then
		if SlideService.ShouldSlide(ply, trace.HitNormal, slide_vel, slide_vel.z) then
			if trace.HitNormal.z > 0 and ply.slide_minimum >= trace.HitNormal.z then
				ply.surfing = trace
				ply.sliding = false
			else
				ply.surfing = false
				ply.sliding = trace
			end

			if (move:GetVelocity().z >= 0 and ply.sliding) or ply.surfing then
				local pos = move:GetOrigin() 
				
				pos.z = trace.HitPos.z + (ply.slide_hover_height - trace.HitNormal.z)
				ply:SetGroundEntity(NULL)
				move:SetVelocity(slide_vel)
				move:SetOrigin(pos)
			end
		end
	end
end

function SlideService.HandleSlideDamage(ply)
	local vel = ply:GetVelocity()
	local pos = ply:GetPos()
	local slide_trace = SlideService.GetGroundTrace(pos, pos + (vel * FrameTime()) - Vector(0, 0, 2), ply)
	local slide_vel = SlideService.Clip(vel, slide_trace.HitNormal)

	if SlideService.ShouldSlide(ply, slide_trace.HitNormal, vel, slide_vel.z) and (ply.surfing or ply.sliding) then
		pos.z = slide_trace.HitPos.z + (ply.slide_hover_height - slide_trace.HitNormal.z)
		ply.slide_onground = {[1] = slide_vel, [2] = pos}
		ply:SetGroundEntity(NULL)
	end
end
hook.Add("OnPlayerHitGround", "SlideService.HandleSlideDamage", SlideService.HandleSlideDamage)

function SlideService.SetupSlide(ply, move, cmd)
	local vel = move:GetVelocity()
	local pos = move:GetOrigin()
	local slide_trace = SlideService.Trace(ply, vel, pos)
	local slide_vel = Vector()
	local should_slide = false

	if slide_trace then
		slide_vel = SlideService.Clip(vel, slide_trace.HitNormal)
		should_slide = SlideService.ShouldSlide(ply, slide_trace.HitNormal, vel, slide_vel.z)

		if 1 > slide_trace.HitNormal.z and not slide_trace.StartSolid and should_slide then
			if SlideService.SlideStrafe(move, cmd, slide_trace.HitNormal) or ply:OnGround() then
				ply:SetGroundEntity(NULL)
			else
				SlideService.Slide(ply, move, slide_trace, slide_vel)
			end
		end
	end

	if ply.slide_onground then
		move:SetVelocity(ply.slide_onground[1])
		move:SetOrigin(ply.slide_onground[2])
		ply.slide_onground = false
	end

	if not should_slide then
		ply.sliding = false
		ply.surfing = false
	end
end
hook.Add("SetupMove", "SlideService.SetupSlide", SlideService.SetupSlide)