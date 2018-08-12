AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:Initialize()
    ENT.lobby = 0
end

function ENT:BuildPhysics(world_vertices)
    --Builds a physics object from vertices created by the player
    local center = Vector(0)
    for i = 1,8 do
        center = center + world_vertices[i]
    end
    center = center/8

    print(center)
    self:SetPos(center)
    local local_vertices = {}

    for _, vertex in pairs(world_vertices) do
        table.insert(local_vertices, self:WorldToLocal(vertex))
    end
    PrintTable(local_vertices)
    self:PhysicsInitConvex(local_vertices)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_NONE)
    self:SetMoveType(MOVETYPE_NOCLIP)
    self:EnableCustomCollisions(true)
    self:GetPhysicsObject():EnableMotion(false)
    self:GetPhysicsObject():Wake()
end
