SavepointService = SavepointService or {}


-- # Properties

function SavepointService.InitPlayerProperties(ply)
	ply.savepoint = nil
	ply.can_savepoint = true
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"SavepointService.InitPlayerProperties",
	SavepointService.InitPlayerProperties
)


-- # Savepoint

function SavepointService.Savepoint(ply, cmd, args)
	if ply.can_savepoint then
		ply.savepoint = { }
		ply.savepoint.position = ply:GetPos()
		ply.savepoint.velocity = ply:GetVelocity()
		ply.savepoint.angles = ply:EyeAngles()
	end
end
concommand.Add("emm_savepoint", SavepointService.Savepoint)

function SavepointService.Loadpoint(ply, cmd, args)
	if ply.can_savepoint and ply.savepoint then
		ply:SetPos(ply.savepoint.position)
		ply:SetVelocity(-ply:GetVelocity() + ply.savepoint.velocity)
		ply:SetEyeAngles(ply.savepoint.angles)
	end
end
concommand.Add("emm_loadpoint", SavepointService.Loadpoint)