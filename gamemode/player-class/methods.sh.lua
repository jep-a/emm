local player_metatable = FindMetaTable("Player")

local ent_metatable =  FindMetaTable("Entity")
local ent_get_table = ent_metatable.GetTable

function player_metatable:__index(key)
	local tab = ent_get_table(self)

	if tab then
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
	self:SetupCoreProperties()

	if SERVER then
		self:SetupLoadout()
	end
end

function player_metatable:EndPlayerClass()
	--
end