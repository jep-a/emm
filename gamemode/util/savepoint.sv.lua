SavepointService = SavepointService or {}


-- # Properties

function SavepointService.InitPlayerProperties(ply)
	ply.can_savepoint = true
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"SavepointService.InitPlayerProperties",
	SavepointService.InitPlayerProperties
)

-- # Util
function SavepointService.CreateSavepoint(ply)
	local savepoint = {}
	savepoint.position = ply:GetPos()
	savepoint.velocity = ply:GetVelocity()
	savepoint.angle = ply:EyeAngles()
	return savepoint
end

function SavepointService.LoadSavepoint(ply, savepoint)
	ply:SetPos(savepoint.position)
	ply:SetVelocity(-ply:GetVelocity() + savepoint.velocity)
	ply:SetEyeAngles(savepoint.angle)
end


-- # Savepoint

function SavepointService.Savepoint(ply, cmd, args)
	if ply.can_savepoint then
		ply:ChatPrint("Savepoint created!")
		ply.savepoint = SavepointService.CreateSavepoint(ply)
	end
end
concommand.Add("emm_savepoint", SavepointService.Savepoint)

function SavepointService.Loadpoint(ply, cmd, args)
	if ply.can_savepoint and ply.savepoint then
		ply:ChatPrint("Savepoint loaded!")
		SavepointService.LoadSavepoint(ply, ply.savepoint)
	end
end
concommand.Add("emm_loadsavepoint", SavepointService.Loadpoint)