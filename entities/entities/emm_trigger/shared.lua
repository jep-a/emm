EMM_TRIGGER_START_POINT = 0
EMM_TRIGGER_CHECKPOINT = 1
EMM_TRIGGER_END_POINT = 2
EMM_TRIGGER_CLOUD = 3

EMM_TRIGGER_SHAPE_SPHERE = 0
EMM_TRIGGER_SHAPE_BOX = 1

ENT.Base = "base_anim"

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "ID")
	self:NetworkVar("Int", 1, "Type")
	self:NetworkVar("Float", 0, "Radius")
	self:NetworkVar("Float", 1, "Width")
	self:NetworkVar("Float", 2, "Height")
	self:NetworkVar("Float", 3, "Depth")
	self:NetworkVar("Vector", 0, "Normal")
	self:NetworkVar("String", 0, "Name")
	self:NetworkVar("String", 1, "CanTagString")
	self:NetworkVar("Float", 4, "CanTagStringCRC")
	self:NetworkVar("Bool", 0, "OwnerTag")
	self:NetworkVar("Bool", 1, "LooksAtPlayers")
	self:NetworkVar("Bool", 2, "Floats")
end

function ENT:GetShape()
	local shape

	if self:GetRadius() > 0 then
		shape = EMM_TRIGGER_SHAPE_SPHERE
	else
		shape = EMM_TRIGGER_SHAPE_BOX
	end

	return shape
end

function ENT:SetCanTag(can_tag)
	local str = util.TableToJSON(can_tag)

	self:SetCanTagString(str)
	self:SetCanTagStringCRC(tonumber(util.CRC(str)))
end

function ENT:GetCanTag()
	local crc = self:GetCanTagStringCRC()
	local cached_tab = self.can_tag_tables[crc]

	if cached_tab then
		return cached_tab
	else
		local tab = util.JSONToTable(self:GetCanTagString())

		self.can_tag_tables[crc] = tab

		return tab
	end
end

function ENT:GetCollision()
	local shape = self:GetShape()

	if shape == EMM_TRIGGER_SHAPE_BOX then
		local height = Vector(0, 0, self:GetHeight())
		local depth = self:GetDepth()
		local norm = self:GetNormal()
		local width = norm * self:GetWidth()

		norm:Rotate(Angle(0, -90, 0))
		depth = norm * depth

		return {
			Vector(),
			width,
			width + depth,
			depth,
			depth + height,
			height,
			Vector(),
			depth,
			depth + height,
			depth + width + height,
			depth + width,
			depth + width + height,
			width + height,
			width,
			Vector(),
			height,
			height + width,
			height + width + depth,
			height + depth,
		}
	end
end

function ENT:GetBounds()
	if self:GetShape() == EMM_TRIGGER_SHAPE_SPHERE then
		local radius = self:GetRadius()
		local bounds = Vector(radius, radius, radius)

		return -bounds, bounds
	elseif self:GetShape() == EMM_TRIGGER_SHAPE_BOX then
		local min = Vector()
		local max = Vector()
		local height = Vector(0, 0, self:GetHeight())
		local depth = self:GetDepth()
		local norm = self:GetNormal()
		local width = norm * self:GetWidth()
		local bounds

		norm:Rotate(Angle(0, -90, 0))
		depth = norm * depth

		bounds = {
			Vector(),
			width,
			width + depth,
			depth,
			Vector() + height,
			width + height,
			width + depth + height,
			depth + height
		}

		for _, corner in pairs(bounds) do
			for i = 1, 3 do
				min[i] = math.min(min[i], corner[i])
				max[i] = math.max(max[i], corner[i])
			end
		end

		return min, max
	end
end

function ENT:CanTouchEntity(ent)
	return IsPlayer(ent) and MinigameService.IsSharingLobby(self, ent) and ent.player_class and self:GetCanTag()[ent.player_class.key]
end