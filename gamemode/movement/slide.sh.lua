SlideService = SlideService or {}
SlideService.TraceHullMins = Vector(-16, -16, 0)
SlideService.TraceHullMaxs = Vector(16, 16, 0)


-- # Properties

function SlideService.InitPlayerProperties(ply)
	ply.slide_surf_minimum = 0.71
	ply.slide_hover_height = 2
	ply.slide_down_ramps = false
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"SlideService.InitPlayerProperties",
	SlideService.InitPlayerProperties
)


-- # Utility

function SlideService.Clip(velocity, plane)
	return velocity - plane * velocity:Dot(plane)
end

function SlideService.GetGroundTrace(position, distance)
	local endPos = Vector(position.x, position.y, position.z - distance)
	return util.TraceHull{
		start = position,
		endpos = endPos,
		mins = SlideService.TraceHullMins,
		maxs = SlideService.TraceHullMaxs,
		mask = MASK_PLAYERSOLID_BRUSHONLY,
	}
end

function SlideService.ShouldSlide(velocity, tr, slide_surf_minimum, surf_down_ramps)
	if not tr.HitWorld then
		return false
	elseif tr.HitNormal.z <= slide_surf_minimum then
		return true
	else 
		return velocity.z > 130 or (surf_down_ramps and velocity.z < -130)
	end
end


-- # Sliding

function SlideService.RampFallDamageFix(ply) 
	local tr = SlideService.GetGroundTrace(ply:GetLocalPos(), 10)
	if SlideService.ShouldSlide(SlideService.Clip(ply:GetVelocity(), tr.HitNormal), tr, ply.slide_surf_minimum, ply.surf_down_ramps) then
		ply:SetGroundEntity(NULL)
	end
end
hook.Add("OnPlayerHitGround", "SlideService.RampFallDamageFix", SlideService.RampFallDamageFix)

function SlideService.RampFix(ply, mv)
	local pos = mv:GetOrigin()
	local tr = SlideService.GetGroundTrace(pos, ply.slide_hover_height)
	local velocity = SlideService.Clip(mv:GetVelocity(), tr.HitNormal)
	if (SlideService.ShouldSlide(velocity, tr, ply.slide_surf_minimum, ply.surf_down_ramps)) then
		pos.z = tr.HitPos.z + ply.slide_hover_height
		mv:SetVelocity(velocity)
		mv:SetOrigin(pos)
		ply:SetGroundEntity(NULL)
	end
end
hook.Add("SetupMove", "SlideService.RampFix", SlideService.RampFix)