AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

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
--    PrintTable(local_vertices)
    self:PhysicsInitMultiConvex({local_vertices})
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:EnableCustomCollisions(true)
    phys_obj = self:GetPhysicsObject()
    phys_obj:EnableMotion(false)
    phys_obj:SetMass(50000)
    phys_obj:SetContents(CONTENTS_SOLID)
    phys_obj:Wake()
end
