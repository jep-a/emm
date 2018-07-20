SlideService = SlideService or {}
SlideService.TraceHullMins = Vector(-16, -16, 0)
SlideService.TraceHullMaxs = Vector(16, 16, 0)


-- # Properties

function SlideService.InitPlayerProperties(ply)
	ply.slide_minimum = 0.71
	ply.slide_hover_height = 1
	ply.can_slide_ramp = false
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"SlideService.InitPlayerProperties",
	SlideService.InitPlayerProperties
)


-- # Utility

function SlideService.Clip(velocity, plane)
	return velocity - (plane * velocity:Dot(plane))
end

function SlideService.GetGroundTrace(position, distance)
	return util.TraceHull{
		start = position,
		endpos = Vector(position.x, position.y, position.z - distance),
		mins = SlideService.TraceHullMins,
		maxs = SlideService.TraceHullMaxs,
		mask = MASK_PLAYERSOLID_BRUSHONLY
	}
end

function SlideService.ShouldSlide(velocity, trace, surf_min, can_slide_ramp)
	local should_slide

	if not trace.HitWorld then
		should_slide = false
	elseif trace.HitNormal.z <= surf_min then
		should_slide = true
	else 
		should_slide = velocity.z > 130 or (can_slide_ramp and -130 > velocity.z)
	end

	return should_slide
end


-- # Sliding

function SlideService.HandleRampDamage(ply) 
	local trace = SlideService.GetGroundTrace(ply:GetLocalPos(), 10)

	if SlideService.ShouldSlide(SlideService.Clip(ply:GetVelocity(), trace.HitNormal), trace, ply.slide_minimum, ply.can_slide_ramp) then
		ply:SetGroundEntity(NULL)
	end
end
hook.Add("OnPlayerHitGround", "SlideService.HandleRampDamage", SlideService.HandleRampDamage)

function SlideService.SetupRamp(ply, move)
	local pos = move:GetOrigin()
	local trace = SlideService.GetGroundTrace(pos, ply.slide_hover_height)
	local velocity = SlideService.Clip(move:GetVelocity(), trace.HitNormal)

	if SlideService.ShouldSlide(velocity, trace, ply.slide_minimum, ply.can_slide_ramp) then
		pos.z = trace.HitPos.z + ply.slide_hover_height
		move:SetVelocity(velocity)
		move:SetOrigin(pos)
		ply:SetGroundEntity(NULL)
	end
end
hook.Add("SetupMove", "SlideService.SetupRamp", SlideService.SetupRamp)