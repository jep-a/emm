BuildService = BuildService or {}

local player_metatable = FindMetaTable("Player")

function player_metatable:StartBuildmode()
end

function player_metatable:StopBuildmode()
end

util.AddNetworkString "Buildmode"
net.Receive("Buildmode", function(len, ply)
    local shouldEnterBuild = net.ReadBool()

    if shouldEnterBuild then
        ply:StartBuildmode()
    else
        ply:StopBuildmode()
    end
end)

util.AddNetworkString "SpawnPrimitive"
util.AddNetworkString "BuildPrimPhysics"
net.Receive("SpawnPrimitive", function(len, ply)
    local world_vertices_json = net.ReadString()
    local world_vertices = util.JSONToTable(world_vertices_json)
    local primitive = ents.Create("emm_primitive")
    
    primitive:BuildPhysics(world_vertices)
--    timer.Simple(0.1, function()
--        net.Start("BuildPrimPhysics")
--        net.WriteEntity(primitive)
--        net.WriteString(world_vertices_json)
--        net.Broadcast()
--    end)
end)
