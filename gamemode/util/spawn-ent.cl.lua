SpawnEntityService = SpawnEntityService or {}

util.AddNetworkString "SpawnEntityService.RequestSpawn"

function SpawnEntityService.RequestSpawn( s_class, t_keyvalues )
    --Request for an entity to be spawned by the server

    net.start "SpawnEntityService.RequestSpawn"
        net.WriteString( s_class )
        net.WriteTable( t_keyvalues )
    net.SendToServer()
end