DuckService = AutoJumpSeDuckServicervice or {}


-- # Properties

function DuckService.InitPlayerProperties(ply)
	local mins, maxs = ply:GetHull()
	local duck_mins, duck_maxs = ply:GetHullDuck()
	
	ply.hull_mins = mins
	ply.hull_maxs = maxs
	ply.hull_duck_mins = duck_mins
	ply.hull_duck_maxs = duck_maxs
	ply.crouch_boost = false
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"DuckService.InitPlayerProperties",
	DuckService.InitPlayerProperties
)


-- # Utils

function DuckService.UnDuckTrace(pos, endpos, min, max)
	return util.TraceHull {
		start = pos,
		endpos = endpos,
		mins = min,
		maxs = max,
		mask = MASK_PLAYERSOLID_BRUSHONLY
	}
end


-- # Ducking

function DuckService.DuckMove(ply, move)
	local origin = move:GetOrigin()

	if 
		ply:OnGround() and 
		not move:KeyDown(IN_DUCK) and 
		ply:Crouching() and 
		(ply:KeyDown(IN_JUMP) or 
		ply:KeyReleased(IN_JUMP)) 
	then
		local trace_hull = DuckService.UnDuckTrace(origin, origin, ply.hull_mins, ply.hull_maxs)
		
		if not trace_hull.Hit then
			ply:RemoveFlags(FL_DUCKING)
			ply:RemoveFlags(FL_ANIMDUCKING)
			ply.crouch_boost = true
		end
	elseif ply.last_vel.z >= 0 then
		if ply.crouch_boost and not ply:IsFlagSet( FL_DUCKING ) then
			local trace_hull = DuckService.UnDuckTrace(origin, origin, ply.hull_mins, ply.hull_maxs)
			
			ply.crouch_boost = false
			ply:AddFlags(FL_DUCKING)
			move:SetOrigin(trace_hull.HitPos + Vector(0, 0, ply.hull_maxs.z/2 - (origin.z - trace_hull.HitPos.z)))
		end
	end
end
hook.Add("PlayerTick", "DuckService.DuckMove", DuckService.DuckMove)
