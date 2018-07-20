ENT.RenderGroup = RENDERGROUP_OPAQUE

ENT.vertex_data = {} --Vertex data from the physics object

function ENT:PhysicsUpdate( phys_obj )
    self.vertex_data = phys_obj:GetMesh()
end