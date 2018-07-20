BuildService = BuildService or {}

-- # Properties

function BuildService.InitPlayerProperties(ply)
	ply.can_build = false
	ply.max_objects = false
	ply.in_build = false
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"BuildService.InitPlayerProperties",
	BuildService.InitPlayerProperties
)

