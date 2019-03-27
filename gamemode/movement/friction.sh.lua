FrictionService = FrictionService or {}


-- # Properties

CreateConVar("emm_friction", 8, FCVAR_REPLICATED, "Player friction")

function FrictionService.GetDefaultFriction()
	return GetConVar("emm_friction"):GetFloat()
end

function FrictionService.InitPlayerProperties(ply)
	ply.friction = GetConVar("emm_friction"):GetFloat()
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"FrictionService.InitPlayerProperties",
	FrictionService.InitPlayerProperties
)


-- # Friction

function FrictionService.Velocity(friction, move)
	local vel = move:GetVelocity()
	local	speed = vel:Length()
	local	drop = 0
	local newspeed, control

	if (GetConVar("sv_stopspeed"):GetFloat() > speed) then
		control = GetConVar("sv_stopspeed"):GetFloat()
	else
		control = speed
	end

	drop = drop + (control * friction * FrameTime())
	newspeed = speed - drop

	if 0 > newspeed then
		newspeed = 0
	end

	if newspeed != speed then
		newspeed = newspeed/speed
		vel = vel * newspeed
	end

	return vel
end


function FrictionService.SetupFriction(ply, move)
	if not ply.lobby and ply.friction != FrictionService.GetDefaultFriction() then
		ply.friction = FrictionService.GetDefaultFriction()
	end

	if 0.1 > move:GetVelocity():Length() or ply:GetGroundEntity() == NULL or (move:KeyPressed(IN_JUMP) and not move:KeyWasDown(IN_JUMP)) then
		return
	end

	move:SetVelocity(FrictionService.Velocity(ply.friction, move))
end
hook.Add("SetupMove", "FrictionService.SetupFriction", FrictionService.SetupFriction)
