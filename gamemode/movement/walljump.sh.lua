WalljumpService = WalljumpService or {}
local WALLJUMP_BUTTONS = bit.bor(IN_JUMP, IN_FORWARD, IN_MOVELEFT, IN_MOVERIGHT, IN_BACK)


-- # Properties

function WalljumpService.InitPlayerProperties(ply)
	ply.can_walljump = true
	ply.can_walljump_sky = false
	ply.walljump_delay = 0.2
	ply.walljump_distance = 30
	ply.walljump_velocity_multiplier = 260
	ply.walljump_up_velocity = 200
	ply.walljump_sound = "npc/footsteps/hardboot_generic"
	ply.last_walljump_time = 0
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"WalljumpService.InitPlayerProperties",
	WalljumpService.InitPlayerProperties
)


-- # Effects

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

function WalljumpService.PressedWalljumpButtons(buttons, old_buttons)
	local walljump_buttons_down = bit.band(buttons, WALLJUMP_BUTTONS)
	return walljump_buttons_down > bit.band(walljump_buttons_down, old_buttons)
end

function WalljumpService.Trace(ply, dir)
	local ply_pos = ply:GetPos()
	local trace = util.TraceLine {
		start = ply_pos,
		endpos = ply_pos - (dir * ply.walljump_distance),
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
	local trace = WalljumpService.Trace(ply, dir)
	local did_walljump = false

	if trace.Hit and (ply.can_walljump_sky or not trace.HitSky) then
		move:SetVelocity(move:GetVelocity() + WalljumpService.Velocity(ply, dir))
		WalljumpService.Effect(ply, trace)
		ply.last_walljump_time = CurTime()
		did_walljump = true

		if not WalljumpService.PlayedSound(ply) then
			PredictedSoundService.PlaySound(ply, ply.walljump_sound.. math.random(1, 6) ..".wav")
		end
	end

	return did_walljump
end

function WalljumpService.SetupWalljump(ply, move)
	if
		ply:Alive() and
		ply.can_walljump and
		not ply.wallsliding and
		move:KeyDown(IN_JUMP) and
		WalljumpService.PressedWalljumpButtons(move:GetButtons(), move:GetOldButtons()) and
		WalljumpService.CooledDown(ply)
	then
		local fwd = move:GetAngles():Forward()
		fwd.z = 0
		fwd:Normalize()
		local right = Vector(fwd.y, -fwd.x)
		local did_walljump = false

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