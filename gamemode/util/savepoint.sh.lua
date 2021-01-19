SavepointService = SavepointService or {}

SavepointService.savepoints = SavepointService.savepoints or {}
SavepointService.savepoint_map = SavepointService.savepoint_map or {}

NetService.CreateSchema("Savepoint", {"id", "entity", "vector", "vector", "angle", "boolean", "float"})
NetService.CreateSchema("LoadSavepoint", {"entity", "id"})
NetService.CreateSchema("FinishSavepoint", {"id"})
NetService.CreateUpstreamSchema "RequestSavepoints"

function SavepointService.InitPlayerProperties(ply)
	ply.can_savepoint = false
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"SavepointService.InitPlayerProperties",
	SavepointService.InitPlayerProperties
)