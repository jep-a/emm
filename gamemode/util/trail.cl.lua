TrailService = TrailService or {}

function TrailService.SetupOwner(ent)
	if ent:GetClass() == "emm_trail" then
		ent:GetOwner().trail = ent
	end
end
hook.Add("OnEntityCreated", "TrailService.SetupOwner", TrailService.SetupOwner)