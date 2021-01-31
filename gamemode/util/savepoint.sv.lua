util.AddNetworkString "Savepoints"

function SavepointService.CreateSavepoint(ply, options)
	options = options or {}

	local savepoint = {}

	savepoint.id = ply:EntIndex()
	savepoint.creator = ply
	savepoint.position = ply:GetPos()
	savepoint.velocity = ply:GetVelocity()
	savepoint.angle = ply:EyeAngles()

	if options.health then
		savepoint.health = ply:Health()
	end

	ply.savepoint = savepoint
	table.insert(SavepointService.savepoints, savepoint)
	SavepointService.savepoint_map[savepoint.id] = savepoint
	hook.Run("Savepoint", savepoint)

	NetService.Broadcast(
		"Savepoint",
		savepoint.id,
		ply,
		savepoint.position,
		savepoint.velocity,
		savepoint.angle,
		options.health,
		savepoint.health or 0
	)

	return savepoint
end

function SavepointService.LoadSavepoint(ply, savepoint, options)
	options = options or {}

	local pos = options.position or savepoint.position

	ply:SetPos(pos)
	ply:SetVelocity(-ply:GetVelocity() + (options.velocity or savepoint.velocity))
	ply:SetEyeAngles(options.angle or savepoint.angle)

	if options.angle or savepoint.health then
		ply:SetHealth(options.angle or savepoint.health)
	end

	timer.Simple(SAFE_FRAME * 1, function ()
		if not UnstuckService.CheckHull(ply, pos) then
			UnstuckService.Queue(ply)
		end
	end)

	hook.Run("LoadSavepoint", ply, savepoint)
	NetService.Broadcast("LoadSavepoint", ply, savepoint.id)
end

function SavepointService.FinishSavepoint(savepoint)
	hook.Run("PlayerFinishSavepoint", savepoint)
	table.RemoveByValue(SavepointService.savepoints, savepoint)
	SavepointService.savepoint_map[savepoint.id] = nil
	NetService.Broadcast("FinishSavepoint", savepoint.id)

	if IsValid(savepoint.creator) then
		savepoint.creator.savepoint = nil
	end
end

function SavepointService.RequestSavepoint(ply, cmd, args)
	if ply.can_savepoint then
		ply:ChatPrint "Savepoint created!"

		SavepointService.CreateSavepoint(ply)
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

function SavepointService.SendSavepoints(ply)
	net.Start "Savepoints"
	net.WriteUInt(table.Count(SavepointService.savepoints), 8)

	for _, savepoint in pairs(SavepointService.savepoints) do
		NetService.WriteID(savepoint.id)
		net.WriteEntity(savepoint.creator)
		net.WriteVector(savepoint.position)
		net.WriteVector(savepoint.velocity)
		net.WriteAngle(savepoint.angle)
		net.WriteBool(not Nily(savepoint.health))
		net.WriteFloat(savepoint.health or 0)
	end

	net.Send(ply)

	ply.received_savepoints = true
end
NetService.Receive("RequestSavepoints", SavepointService.SendSavepoints)