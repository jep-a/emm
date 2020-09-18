SavepointService = SavepointService or {}


-- # Properties

function SavepointService.InitPlayerProperties(ply)
	ply.can_savepoint = false
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"SavepointService.InitPlayerProperties",
	SavepointService.InitPlayerProperties
)


-- # Saving/loading

function SavepointService.CreateSavepoint(ply, options)
	options = options or {}

	local savepoint = {}

	savepoint.position = ply:GetPos()
	savepoint.velocity = ply:GetVelocity()
	savepoint.angle = ply:EyeAngles()

	if options.health then
		savepoint.health = ply:Health()
	end

	return savepoint
end

function SavepointService.LoadSavepoint(ply, savepoint, options)
	options = options or {}

	local pos = options.position or savepoint.position

	ply:SetPos(pos)
	ply:SetVelocity(options.velocity or -ply:GetVelocity() + savepoint.velocity)
	ply:SetEyeAngles(options.angle or savepoint.angle)

	if options.angle or savepoint.health then
		ply:SetHealth(options.angle or savepoint.health)
	end

	timer.Simple(SAFE_FRAME * 1, function ()
		if not UnstuckService.CheckHull(ply, pos) then
			UnstuckService.Queue(ply)
		end
	end)
end

function SavepointService.RequestSavepoint(ply, cmd, args)
	if ply.can_savepoint then
		ply:ChatPrint "Savepoint created!"
		ply.savepoint = SavepointService.CreateSavepoint(ply)
	end
end
concommand.Add("emm_savepoint", SavepointService.RequestSavepoint)

function SavepointService.RequestLoadSavepoint(ply, cmd, args)
	if ply.can_savepoint and ply.savepoint then
		ply:ChatPrint "Savepoint loaded!"
		SavepointService.LoadSavepoint(ply, ply.savepoint)
	end
end
concommand.Add("emm_load_savepoint", SavepointService.RequestLoadSavepoint)