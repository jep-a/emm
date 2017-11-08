EMM = EMM or {}

EMM.client_includes = {}

EMM_GAMEMODE_DIRECTORY = "emm/gamemode/"

function EMM.Include(inc, inc_func)
	inc_func = inc_func or include

	if istable(inc) then
		for _, _inc in pairs(inc) do
			EMM.Include(_inc)
		end
	elseif isstring(inc) then
		local inc_path = EMM_GAMEMODE_DIRECTORY..inc
		local sh_inc_file = file.Find(inc_path..".sh.lua", "LUA")[1]
		local cl_inc_file = file.Find(inc_path..".cl.lua", "LUA")[1]

		if sh_inc_file then
			inc_func(inc_path..".sh.lua")
		end

		if cl_inc_file then
			inc_func(inc_path..".cl.lua")
		end

		EMM.client_includes[inc] = true
	end
end

include "emm.lua"
