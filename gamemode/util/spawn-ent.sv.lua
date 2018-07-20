SpawnEntityService = SpawnEntityService or {}

util.AddNetworkString "SpawnEntityService.RequestSpawn"

function SpawnEntityService.SpawnProp( s_class, t_keyvalues )
    --Spawn a prop from a request
    local ent = ents.Create( s_class )
    for key, value in pairs( t_keyvalues ) do
        ent:KeyValue( key, value )
    end
end
net.Receive( "SpawnEntityService.RequestSpawn", function( len, ply )
    SpawnEntityService.SpawnProp( net.ReadString(), net.ReadTable() )
end)