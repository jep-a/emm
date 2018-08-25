AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel( "models/props_c17/oildrum001.mdl" )
    self.lobby = 0
end

function ENT:SetupDataTables()
end

function ENT:PhysicsUpdate(phys)
    --print(phys)
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end