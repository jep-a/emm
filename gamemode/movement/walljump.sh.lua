WalljumpService = WalljumpService or {}
WalljumpService.BUTTONS = bit.bor(IN_JUMP, IN_FORWARD, IN_MOVELEFT, IN_MOVERIGHT)


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

function WalljumpService.PressedWalljumpButton(buttons, old_buttons)
	local walljump_buttons_down = bit.band(buttons, WalljumpService.BUTTONS)
	return bit.band(walljump_buttons_down, old_buttons) < walljump_buttons_down
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

function WalljumpService.Walljump(ply, mv, dir)
	local trace = WalljumpService.Trace(ply, dir)
	
	if trace.Hit and (ply.can_walljump_sky or not trace.HitSky) then
		mv:SetVelocity(mv:GetVelocity() + WalljumpService.Velocity(ply, dir))
		WalljumpService.Effect(ply, trace)
		if IsFirstTimePredicted then ply.last_walljump_time = CurTime() end
		
		if SERVER then
			ply:EmitSound(ply.walljump_sound..math.random(1, 6)..".wav")
		end
	end
end

if SERVER then
	function WalljumpService.IsCooledDown(ply)
		return CurTime() > (ply.last_walljump_time + ply.walljump_delay)
	end
end

function WalljumpService.SetupWalljump(ply, mv, ucmd)
	if
		ply:Alive() and
		ply.can_walljump and
		not ply.wallsliding and
		mv:KeyDown(IN_JUMP) and
		WalljumpService.PressedWalljumpButton(mv:GetButtons(), mv:GetOldButtons()) and
		WalljumpService.IsCooledDown(ply)
	then
		local fwd = mv:GetAngles():Forward()
		fwd.z = 0
		fwd:Normalize()
		local right = Vector(fwd.y, -fwd.x)
		
		if mv:KeyDown(IN_MOVELEFT) then
			WalljumpService.Walljump(ply, mv, -right)
		end
		
		if mv:KeyDown(IN_MOVERIGHT) then
			WalljumpService.Walljump(ply, mv, right)
		end
		
		if mv:KeyDown(IN_FORWARD) then
			WalljumpService.Walljump(ply, mv, fwd)
		end
		
		if mv:KeyDown(IN_BACK) then
			WalljumpService.Walljump(ply, mv, -fwd)
		end
	end
end
hook.Add("SetupMove", "WalljumpService.SetupWalljump", WalljumpService.SetupWalljump)