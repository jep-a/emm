local player_metatable = FindMetaTable "Player"

local ent_metatable =  FindMetaTable "Entity"
local ent_get_table = ent_metatable.GetTable

function player_metatable:__index(key)
	local tab = ent_get_table(self)

	if tab then
		local dynamic_ply_class = tab.dynamic_player_class

		if dynamic_ply_class then
			local dynamic_ply_class_val = dynamic_ply_class[key]

			if dynamic_ply_class_val ~= nil then
				return dynamic_ply_class_val
			end
		end

		local ply_class = tab.player_class

		if ply_class then
			local ply_class_val = ply_class[key]

			if ply_class_val ~= nil then
				return ply_class_val
			end
		end
	end

	local ply_mt_val = player_metatable[key]

	if ply_mt_val ~= nil then
		return ply_mt_val
	end

	local ent_mt_val = ent_metatable[key]

	if ent_mt_val ~= nil then
		return ent_mt_val
	end

	if tab then
		local tab_val = tab[key]

		if tab_val ~= nil then
			return tab_val
		end
	end

	return nil
end

function player_metatable:GetPlayerClass()
	return self.player_class
end

function player_metatable:HasPlayerClass()
	return self.player_class ~= nil
end

function player_metatable:SetupPlayerClass()
	self.dynamic_player_class = table.Copy(self.player_class.dynamic_properties) or {}
	self.player_class_objects = {}
	self:SetupCoreProperties()

	if self.StartPlayerClass then
		self:StartPlayerClass()
	end

	hook.Run("SetupPlayerClass", self)

	if CLIENT and IsLocalPlayer(self) then
		hook.Run("LocalPlayerProperties", self)
	end

	hook.Run("PlayerProperties", self)

	if SERVER then
		self:SetupLoadout()
	end
end

function player_metatable:FinishPlayerClass()
	if self.player_class_objects then
		for _, object in pairs(self.player_class_objects) do
			local instance = object.object or self[object.key]

			if instance then
				if object.callback then
					object.callback()
				end

				if instance.Finish then
					instance:Finish()
				elseif instance.Remove then
					instance:Remove()
				end

				if object.key then
					self[object.key] = nil
				end
			end
		end
	end

	self.dynamic_player_class = nil
	self.player_class_objects = nil
	self:SetupCoreProperties()

	if self.EndPlayerClass then
		self:EndPlayerClass()
	end

	hook.Run("FinishPlayerClass", self)
end