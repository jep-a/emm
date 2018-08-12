AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
end

function ENT:SetupDataTables()
end

function ENT:PhysicsUpdate(phys)
    --print(phys)
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end