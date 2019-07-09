-- # Properties

ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "ID")
	self:NetworkVar("Int", 1, "Lobby")
	self:NetworkVar("String", 2, "Type")
	self:NetworkVar("Float", 3, "Width")
	self:NetworkVar("Float", 4, "Height")
	self:NetworkVar("Float", 5, "Depth")
	self:NetworkVar("Vector", 6, "Normal")
end


-- # Utils

function ENT:GetShape()
	if self:GetHeight() == 0 and self:GetDepth() == 0 and self:GetWidth() > 0 then
		return "sphere"
	end
	
	return "box"
end

function ENT:GetCollision()
	local shape = self:GetShape()
	
	if shape == "box" then
		local height = Vector(0, 0, self:GetHeight())
		local angle = self:GetNormal()
		local width = angle * self:GetWidth()
		local depth = self:GetDepth()

		angle:Rotate(Angle(0, -90, 0))
		depth = angle * depth
		
		return {
			Vector(0,0,0),
			width,
			width + depth,
			depth,
			depth + height,
			height,
			Vector(0,0,0),
			depth,
			depth + height,
			depth + width + height,
			depth + width,
			depth + width + height,
			width + height,
			width,
			Vector(0,0,0),
			height,
			height + width,
			height + width + depth,
			height + depth,
		}
	end
end

function ENT:GetBounds()
	if self:GetShape() == "box" then
		local mins, maxs = Vector(0,0,0), Vector(0,0,0)
		local height = Vector(0, 0, self:GetHeight())
		local angle = self:GetNormal()
		local width = angle * self:GetWidth()
		local depth = self:GetDepth()
		local bounds
		
		angle:Rotate(Angle(0, -90, 0))
		depth = angle * depth
		bounds = {
			Vector(0,0,0),
			width,
			width + depth,
			depth,
			Vector(0,0,0) + height,
			width + height,
			width + depth + height,
			depth + height
		}
		
		for _, corner in ipairs(bounds) do
			for i = 1, 3 do
				mins[i] = math.min(mins[i], corner[i])
				maxs[i] = math.max(maxs[i], corner[i])
			end
		end
		
		return mins, maxs
	elseif self:GetShape() == "sphere" then
		local radius = self:GetWidth()
		local bounds = Vector(radius, radius, radius)
		
		return -bounds, bounds
	end
end

function ENT:PlayerInLobby(ply)
	local ent_lobby = self:GetLobby()

	if ply.lobby and ent_lobby > 0 then
		if ply.lobby.id == ent_lobby then
			return true
		end
	elseif not ply.lobby and ent_lobby == 0 then
		return true
	end

	return false
end

function ENT:Finish()
	if IsValid(self) then
		self:Remove()
	end
end


-- # Touch

function ENT:StartTouch(ply)
	if IsValid(ply) and ply:IsPlayer() and ply:Team() != TEAM_SPECTATOR and self:PlayerInLobby(ply) then
		hook.Call("Emm_Trigger_StartTouch", nil, ply, self)
	end
end

function ENT:EndTouch(ply)
	if IsValid(ply) and ply:IsPlayer() and ply:Team() != TEAM_SPECTATOR and self:PlayerInLobby(ply) then
		hook.Call("Emm_Trigger_EndTouch", nil, ply, self)
	end
end