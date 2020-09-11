SlopeService = SlopeService or {}


-- # Properties

function SlopeService.InitPlayerProperties(ply)
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


function SlopeService.SetupSlope(ply, move)
	if ply:OnGround() then
		ply.slope_onground = true
	else
		ply.slope_onground = false
	end

	ply.last_vel = move:GetVelocity()
end
hook.Add("Move", "SlopeService.SetupSlope", SlopeService.SetupSlope)