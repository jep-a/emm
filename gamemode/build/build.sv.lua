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
