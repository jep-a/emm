TrailService = TrailService or {}

function TrailService.SetupTrail(ent)
	local trail = ents.Create("emm_trail")
	trail:SetOwner(ent)
	trail:SetPos(ent:GetPos())
	trail:SetParent(ent)
	trail:Spawn()

	ent.trail = trail
end

function TrailService.RemoveTrail(ent)
	ent.trail:StartRemove()
end