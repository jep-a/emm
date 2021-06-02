JumpService = JumpService or {}


-- # Properties

function JumpService.InitPlayerProperties(ply)
	ply.can_autojump = false
	ply.force_autojump = false
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"JumpService.InitPlayerProperties",
	JumpService.InitPlayerProperties
)


-- # Autojump

function JumpService.AutoJump(ply, move)
	if 	
		ply.can_autojump and
		(move:KeyDown(IN_JUMP) or ply.force_autojump) and
		ply:IsOnGround()
	then
		move:SetOldButtons(bit.band(move:GetOldButtons(), bit.bnot(IN_JUMP)))
		move:SetButtons(bit.bor(move:GetButtons(), IN_JUMP))
	end
end
hook.Add("SetupMove", "JumpService.AutoJump", JumpService.AutoJump)


-- # Unduck jump

function JumpService.DuckJump(ply, move)
	local mins, maxs = ply:GetHull()
	local duck_mins, duck_maxs = ply:GetHullDuck()
	local pos = move:GetOrigin()
	local trace_hull

	if ply:OnGround() and not move:KeyDown(IN_DUCK) and ply:Crouching() and 0 >= ply.old_velocity.z and ((ply:KeyPressed(IN_JUMP) or ply:KeyReleased(IN_JUMP)) or (ply.can_autojump and ply:KeyDown(IN_JUMP)) or ply.force_autojump) then
		trace_hull = util.TraceHull {
			start = pos,
			endpos = pos,
			mins = mins,
			maxs = maxs + Vector(0, 0, maxs.z/2),
			mask = MASK_PLAYERSOLID_BRUSHONLY
		}

		ply:SetGroundEntity(NULL)
		
		if trace_hull.HitWorld then
			if SERVER then
				ply:PlayStepSound(0.5)
			end

			move:SetVelocity(move:GetVelocity() + Vector(0, 0, ply:GetJumpPower()))
		else
			pos.z = trace_hull.HitPos.z + (maxs.z - duck_maxs.z)
			move:SetOrigin(pos)
		end
	end

end
hook.Add("PlayerTick", "JumpService.DuckJump", JumpService.DuckJump)