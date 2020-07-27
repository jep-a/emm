EMM = EMM or {}

EMM.server_includes = {}

gamemode_name = engine.ActiveGamemode()
gamemode_lua_directory = gamemode_name.."/gamemode/"

AddCSLuaFile "cl_init.lua"
AddCSLuaFile(gamemode_name..".lua")

function IsSharedFile(file)
	return string.match(file, "sh.lua$")
end

function IsServerFile(file)
	return string.match(file, "sv.lua$")
end

function IsClientFile(file)
	return string.match(file, "cl.lua$")
end

function EMM.RequireClientsideLuaDirectory(dir)
	dir = dir and string.TrimLeft(dir, "/") or ""

	local files, child_dirs = file.Find(gamemode_lua_directory..dir.."/*", "LUA")

	for _, file in pairs(files) do
		if IsSharedFile(file) or IsClientFile(file) then
			MsgN("requiring client-side include "..dir.."/"..file)
			AddCSLuaFile(gamemode_lua_directory..dir.."/"..file)
		end
	end

	for _, child_dir in pairs(child_dirs) do
		EMM.RequireClientsideLuaDirectory(dir.."/"..child_dir)
	end
end
EMM.RequireClientsideLuaDirectory()

function EMM.Include(inc, inc_func)
	inc_func = inc_func or include

	if istable(inc) then
		for _, _inc in pairs(inc) do
			EMM.Include(_inc)
		end
	elseif isstring(inc) then
		local inc_path = gamemode_lua_directory..inc
		local inc_file = file.Find(inc_path, "LUA")[1]
		local sh_inc_file = file.Find(inc_path..".sh.lua", "LUA")[1]
		local sv_inc_file = file.Find(inc_path..".sv.lua", "LUA")[1]

		if inc_file or sh_inc_file or sv_inc_file then
			MsgN("including "..inc)
		else
			return
		end

		if inc_file and (IsSharedFile(inc_file) or IsServerFile(inc_file)) then
			inc_func(inc_path)
		end

		if sh_inc_file then
			inc_func(inc_path..".sh.lua")
		end

		if sv_inc_file then
			inc_func(inc_path..".sv.lua")
		end

		EMM.server_includes[inc] = true
	end
end

function EMM.AddResourceDirectory(dir)
	local files, child_dirs = file.Find(dir.."/*", "THIRDPARTY")

	for _, file in pairs(files) do
		resource.AddFile(dir.."/"..file)
	end

	for _, child_dir in pairs(child_dirs) do
		EMM.AddResourceDirectory(dir.."/"..child_dir)
	end
end

EMM.AddResourceDirectory "models/emm2"
EMM.AddResourceDirectory "materials/emm2"
EMM.AddResourceDirectory "materials/models/emm2"
EMM.AddResourceDirectory "resource/fonts"
include(gamemode_name..".lua")