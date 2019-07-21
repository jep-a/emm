TrailService = TrailService or {}

function TrailService.SetupTrail(ent)
	if IsValid(ent.trail) then
		ent.trail:StartRemove()
	end

	local trail = ents.Create "emm_trail"
	trail:SetOwner(ent)
	trail:SetPos(ent:GetPos())
	trail:SetParent(ent)
	trail:Spawn()

	ent.trail = trail
end
hook.Add("PlayerSpawn", "TrailService.SetupTrail", TrailService.SetupTrail)

function TrailService.RemoveTrail(ent)
	ent.trail:StartRemove()
end
hook.Add("DoPlayerDeath", "TrailService.RemoveTrail", TrailService.RemoveTrail)