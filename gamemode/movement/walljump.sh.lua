WalljumpService = WalljumpService or {}


-- # Properties

function WalljumpService.InitPlayerProperties(ply, ply_class)
	ply.can_walljump = true
	ply.can_walljump_sky = false

	if not ply_class then
		ply.last_wallslide_time = 0
		ply.last_wallslide_effect_time = 0
		ply.walljump_delay = 0.2
		ply.walljump_distance = 30
		ply.walljump_velocity_multiplier = 260
		ply.walljump_up_velocity = 200
		ply.walljump_sound = "npc/footsteps/hardboot_generic"
		ply.last_walljump_time = 0
	end
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"WalljumpService.InitPlayerProperties",
	WalljumpService.InitPlayerProperties
)
hook.Add(
	"InitPlayerClassProperties",
	"WalljumpService.InitPlayerClassProperties",
	WalljumpService.InitPlayerProperties
)


-- # Effects

function WalljumpService.EffectTrace(ply, dir)
	local ply_pos = ply:GetPos()
	local trace = util.TraceLine {
		start = ply_pos,
		endpos = ply_pos - (dir * ply.walljump_distance * 2),
		filter = ply
	}

	return trace
end

function WalljumpService.EffectOrigin(trace)
	local trace_norm_right = trace.HitNormal:Angle():Right()
	return trace.HitPos - (trace_norm_right:Dot(trace.HitPos - trace.StartPos) * trace_norm_right)
end

function WalljumpService.EffectData(ply, trace)
	local effect_data = EffectData()
	effect_data:SetOrigin(WalljumpService.EffectOrigin(trace))
	effect_data:SetNormal(trace.HitNormal)
	effect_data:SetEntity(ply)

	return effect_data
end

function WalljumpService.Effect(ply, trace)
	local effect_data = WalljumpService.EffectData(ply, trace)

	util.Effect("emm_ripple", effect_data, true, true)
	util.Effect("emm_spark", effect_data, true, true)
end


-- # Walljumping

local WALLJUMP_BUTTONS = bit.bor(IN_JUMP, IN_FORWARD, IN_MOVELEFT, IN_MOVERIGHT, IN_BACK)
function WalljumpService.PressedWalljumpButtons(buttons, old_buttons)
	local walljump_buttons_down = bit.band(buttons, WALLJUMP_BUTTONS)
	return walljump_buttons_down > bit.band(walljump_buttons_down, old_buttons)
end

function WalljumpService.GetAngle(dir, wall_normal)
	local angle = dir:Angle()
	local wall_ang = wall_normal:Angle()

	wall_ang:Normalize()
	angle:Normalize()

	angle:RotateAroundAxis(wall_normal, 90)
	wall_ang = wall_ang.y

	return math.abs(angle.p)
end

function WalljumpService.Trace(ply, dir)
	local ply_pos = ply:GetPos()
	local mins = ply:OBBMins()
	local maxs = ply:OBBMaxs()
	local walljump_distance = ply.walljump_distance - maxs.x
	local perimeter_pos = ply_pos - Vector(dir.x * 23, dir.y * 23, 0)
	local obb_trace = Vector(ply.walljump_distance/2, ply.walljump_distance/2, 0)

	perimeter_pos.x = math.Clamp(perimeter_pos.x, ply_pos.x + mins.x, ply_pos.x + maxs.x)
	perimeter_pos.y = math.Clamp(perimeter_pos.y, ply_pos.y + mins.y, ply_pos.y + maxs.y)

	if ply.sliding then
		ply_pos.z = ply_pos.z - (ply.slide_hover_height + 2)
	end

	local trace = util.TraceHull {
		start = ply_pos,
		endpos = perimeter_pos,
		mins = -obb_trace,
		maxs = obb_trace,
		mask = MASK_PLAYERSOLID_BRUSHONLY,
		filter = ply
	}

	return trace
end

function WalljumpService.Velocity(ply, dir)
	local new_self_vel = dir * ply.walljump_velocity_multiplier
	new_self_vel.z = ply.walljump_up_velocity

	return new_self_vel
end

function WalljumpService.Walljump(ply, move, dir)
	local did_walljump
	local trace = WalljumpService.Trace(ply, dir)

	if
		trace.Hit and
		(ply.can_walljump_sky or not trace.HitSky) and
		(58 > WalljumpService.GetAngle(dir, trace.HitNormal))
	then
		did_walljump = true

		if SERVER or SettingsService.Get "clientside_walljump" then
			move:SetVelocity(move:GetVelocity() + WalljumpService.Velocity(ply, dir))
		end

		if ply:OnGround() then
			ply:SetGroundEntity(NULL)
			move:SetOrigin(move:GetOrigin() + Vector(0, 0, 1))
			move:SetVelocity(move:GetVelocity() + Vector(0, 0, ply:GetJumpPower()))
		end

		if SERVER then
			WalljumpService.Effect(ply, WalljumpService.EffectTrace(ply, dir))
		end

		ply.last_walljump_time = CurTime()

		if not WalljumpService.PlayedSound(ply) then
			PredictedSoundService.PlaySound(ply, ply.walljump_sound..math.random(1, 6)..".wav")
		end
	else
		did_walljump = false
	end

	return did_walljump
end

function WalljumpService.SetupWalljump(ply, move)
	if
		ply:Alive() and
		ply.can_walljump and
		not WallslideService.Wallsliding(ply) and
		move:KeyDown(IN_JUMP) and
		WalljumpService.PressedWalljumpButtons(move:GetButtons(), move:GetOldButtons()) and
		WalljumpService.CooledDown(ply)
	then
		local did_walljump
		local fwd = move:GetAngles():Forward()
		fwd.z = 0
		fwd:Normalize()
		local right = Vector(fwd.y, -fwd.x)

		if move:KeyDown(IN_MOVERIGHT) then
			did_walljump = WalljumpService.Walljump(ply, move, right)
		end

		if move:KeyDown(IN_MOVELEFT) and not did_walljump then
			did_walljump = WalljumpService.Walljump(ply, move, -right)
		end

		if move:KeyDown(IN_FORWARD) and not did_walljump then
			did_walljump = WalljumpService.Walljump(ply, move, fwd)
		end

		if move:KeyDown(IN_BACK) and not did_walljump then
			did_walljump = WalljumpService.Walljump(ply, move, -fwd)
		end
	end
end
hook.Add("SetupMove", "WalljumpService.SetupWalljump", WalljumpService.SetupWalljump)
