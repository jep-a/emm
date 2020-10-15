FrictionService = FrictionService or {}


-- # Properties

CreateConVar("emm_friction", 8, FCVAR_REPLICATED, "Player friction")

function FrictionService.GetDefaultFriction()
	return GetConVar "emm_friction":GetFloat()
end

function FrictionService.InitPlayerProperties(ply)
	ply.friction = FrictionService.GetDefaultFriction()
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"FrictionService.InitPlayerProperties",
	FrictionService.InitPlayerProperties
)
hook.Add(
	"InitPlayerClassProperties",
	"FrictionService.InitPlayerClassProperties",
	FrictionService.InitPlayerProperties
)


-- # Friction

function FrictionService.Velocity(friction, move)
	local vel = move:GetVelocity()
	local speed = vel:Length()
	local stop_speed = GetConVar "sv_stopspeed":GetFloat()
	local drop = 0

	local new_speed
	local control

	if stop_speed > speed then
		control = stop_speed
	else
		control = speed
	end

	drop = drop + (control * friction * FrameTime())
	new_speed = speed - drop

	if 0 > new_speed then
		new_speed = 0
	end

	if new_speed ~= speed then
		new_speed = new_speed/speed
		vel = vel * new_speed
	end

	return vel
end

function FrictionService.SetupFriction(ply, move)
	if not ply.lobby and ply.friction ~= FrictionService.GetDefaultFriction() then
		ply.friction = FrictionService.GetDefaultFriction()
	end

	if not (
		move:GetVelocity():Length() < 0.1 or
		ply:GetGroundEntity() == NULL or
		(move:KeyPressed(IN_JUMP) and not move:KeyWasDown(IN_JUMP)) or
		(ply.can_autojump and move:KeyDown(IN_JUMP))
	) then
		move:SetVelocity(FrictionService.Velocity(ply.friction, move))
	end
end
hook.Add("SetupMove", "FrictionService.SetupFriction", FrictionService.SetupFriction)
