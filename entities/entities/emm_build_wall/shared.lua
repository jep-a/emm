ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.host = 0 --EntID of the host

-- # I'm gonna use net messages instead
-- function ENT:SetupDataTables()
--     self:NetworkVar("string", 0, "VertexData")
-- end
-- 
-- function ENT:SetVertices( t_vertices)
--     self:SetVertexData( util.TableToJSON( t_vertices ) )
-- end
-- 
-- function ENT:GetVertices()
--     self:GetVertexData( )
-- end

function ENT:BuildPhysics( t_vertexdata )
    --Builds a physics object from vertices created by the player
    self:PhysicsInitConvex( t_vertexdata )

    self:SetMoveType( MOVETYPE_NONE )
    self:SetSolid( SOLID_VPHYSICS )
end