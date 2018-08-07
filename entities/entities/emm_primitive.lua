AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.host = 0

function ENT:Initialize()
    self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
end
function ENT:SetupDataTables()
    for i = 1, 8 do
        self:NetworkVar("Vector", i, tostring(i))
    end
end

if SERVER then util.AddNetworkString "BuildPhysics" end
function ENT:BuildPhysics()
    --Builds a physics object from vertices created by the player
    local world_vertices = {}
    
    local center = Vector(0)
    for i = 1,8 do
        world_vertices[i] = self:GetNWVector(tostring(i))
        center = center + world_vertices[i]
    end
    center = center/8

    --print(center)
    self:SetPos(center)
    local local_vertices = {}

    for _, vertex in pairs(world_vertices) do
        table.insert(local_vertices, self:WorldToLocal(vertex))
    end
    --PrintTable(local_vertices)
    self:PhysicsInitConvex(local_vertices)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_NONE)
    self:SetMoveType(MOVETYPE_NONE)
    self:EnableCustomCollisions(true)
    self:GetPhysicsObject():Wake()

    --if SERVER then
    --    net.Start("BuildPhysics")
    --    net.WriteEntity(self)
    --    net.Broadcast()
    --end
end