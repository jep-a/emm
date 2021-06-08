SlopeService = SlopeService or {}


-- # Properties

function SlopeService.InitPlayerProperties(ply)
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