function SavepointService.CreateSavepoint(id, ply, pos, vel, ang, has_health, health)
	local savepoint = {}

	savepoint.id = id
	savepoint.creator = ply
	savepoint.position = pos
	savepoint.velocity = vel
	savepoint.angle = ang

	if has_health then
		savepoint.health = health
	end

	ply.savepoint = savepoint

	table.insert(SavepointService.savepoints, savepoint)
	SavepointService.savepoint_map[savepoint.id] = savepoint
	hook.Run("Savepoint", savepoint)

	return savepoint
end
NetService.Receive("Savepoint", SavepointService.CreateSavepoint)

function SavepointService.LoadSavepoint(ply, id)
	local savepoint = SavepointService.savepoint_map[id]

	hook.Run("LoadSavepoint", ply, savepoint)
end
NetService.Receive("LoadSavepoint", SavepointService.LoadSavepoint)

function SavepointService.FinishSavepoint(id)
	hook.Run("FinishSavepoint", savepoint)
	table.RemoveByValue(SavepointService.savepoints, savepoint)
	SavepointService.savepoint_map[id] = nil

	local ply = Entity(id)

	if IsValid(ply) then
		ply.savepoint = nil
	end
end
NetService.Receive("FinishSavepoint", SavepointService.FinishSavepoint)

function SavepointService.RequestSavepoints()
	NetService.SendToServer "RequestSavepoints"
end
hook.Add("InitPostEntity", "SavepointService.RequestSavepoints", SavepointService.RequestSavepoints)

function SavepointService.ReceiveSavepoints(len)
	local savepoint_count = NetService.ReadID()

	for i = 1, savepoint_count do
		local id = NetService.ReadID()
		local ply = net.ReadEntity()
		local pos = net.ReadVector()
		local vel = net.ReadVector()
		local ang = net.ReadAngle()
		local has_health = net.ReadBool()
		local health = net.ReadFloat()

		SavepointService.CreateSavepoint(id, ply, pos, vel, ang, has_health, health)
	end

	SavepointService.received_savepoints = true
	hook.Run "ReceiveSavepoints"
end
net.Receive("Savepoints", SavepointService.ReceiveSavepoints)