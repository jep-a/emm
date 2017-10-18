EMM = EMM or {}

EMM.client_includes = {}

EMM_GAMEMODE_DIRECTORY = "emm/gamemode/"

function EMM.Include(inc)
	if istable(inc) then
		for _, _inc in pairs(inc) do
			EMM.Include(_inc)
		end
	elseif isstring(inc) then
		local inc_path = EMM_GAMEMODE_DIRECTORY..inc
		local cl_inc_file = file.Find(inc_path..".cl.lua", "LUA")[1]
		local sh_inc_file = file.Find(inc_path..".sh.lua", "LUA")[1]

		if cl_inc_file then
			include(inc_path..".cl.lua")
		end

		if sh_inc_file then
			include(inc_path..".sh.lua")
		end

		EMM.client_includes[inc] = true
	end
end

include "emm.lua"
