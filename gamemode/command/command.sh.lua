CommandService = CommandService or {}
CommandService.Commands = {}


-- # Object Types

CommandService.object_types = {
	bool = tobool,
	string = tostring,
	number = tonumber,
	table = function(tbl) return CommandService.ToType("table", "string.Explode(',', '"..tbl.."')") end,
	vector = function(vector) return CommandService.ToType("vector", "Vector(unpack(string.Explode(',', '"..vector.."')))") end,
	angle = function(ang) return CommandService.ToType("angle", "Angle(unpack(string.Explode(',', '"..ang.."')))") end,
	player = function(ply) return CommandService.FindTarget(ply)[1] end,	
	players = function(tbl) 
		local targets = CommandService.object_types.table(tbl)

		if #targets > 1 then
			return CommandService.FindTarget(targets)
		else
			return CommandService.FindTarget(targets)[1]
		end
	end,
}


-- # Symbols

CommandService.prefix = "!/"

CommandService.symbols = {
	["^"] = {varargs = {"player", "players"}, callback = function(sender) return sender:Nick() end},
	["*"] = {varargs = {"players"}, callback = function(sender) 
		local names = ""

		for _, ply in pairs(player.GetAll()) do
			names = names..","..ply:Nick()
		end

		return names:sub(2)
	end}
}


-- # Utils

function CommandService.FindTarget(target)
	local tbl = {}
	
	if istable(target) then
		for _, name in pairs(target) do
			if not IsEntity(name) then
				for _, ply in pairs(player.GetAll()) do
					if string.lower(ply:Nick()):find(name:lower()) and not table.HasValue(tbl, ply) then
						table.insert(tbl, ply)
						break
					end
				end
			else
				table.insert(tbl, target)
			end
		end
	else
		if not IsEntity(target) then
			for _, ply in pairs(player.GetAll()) do
				if string.lower(ply:Nick()):find(target:lower()) then
					table.insert(tbl, ply)
				end
			end
		else
			table.insert(tbl, target)
		end
	end

	if #tbl > 0 then
		return tbl
	else
		return {nil}
	end
end

function CommandService.FindCommand(str)
	local tbl = {}

	str = str:lower()

	for name, cmd in pairs(CommandService.Commands) do
		if name:find(str) and table.HasValue(cmd.cmds, str) then
			return cmd
		end
	end
	
	return nil
end

function CommandService.ExecuteCommand(cmd, sender, ...)
	cmd = CommandService.FindCommand(cmd)

	if cmd then
		cmd:Execute(sender, ...)
	end
end


function CommandService.AutoComplete(cmd, args)
	local auto_complete = {}
	local con_cmd = cmd.." "

	cmd = CommandService.Commands[cmd:sub(5)]

	if istable(cmd) then
		args = args:sub(2):Split(" ")
		
		if cmd.args[#args] == "player" then
			for _, ply in pairs(player.GetAll()) do
				if string.lower(" "..ply:Nick()):find(args[#args]:lower()) then
					table.insert(auto_complete, con_cmd..ply:Nick())
				end
			end

			return auto_complete
		elseif cmd.args[#args] == "number" then
			auto_complete = {con_cmd..args[#args]}

			if isnumber(cmd.args[#args + 1]) then
				auto_complete = {con_cmd.."[".. cmd.args[#args + 1].."]"}

				if isnumber(cmd.args[#args + 2]) then
					auto_complete = {con_cmd.."[".. cmd.args[#args + 1].." - "..cmd.args[#args + 2].."]"}
				end
			end

			return auto_complete
		end
	end
end

function CommandService.ToType(type, arg)
	local type_pass, arg = CompileString("return is"..type.."("..arg.."), "..arg, "CommandService.TypeCheck")()

	if type_pass then
		return arg
	else
		return nil
	end
end

function CommandService.AddCommand(props)
	assert(istable(props), "Properties is not a table")
	assert(props.name, "Command name not specified")

	local cmd = Command.New()

	if not props.callback then
		props.callback = function() end
	end

	if not props.varargs then
		props.varargs = {}
	end

	if props.flags then
		cmd:AddFlags(props.flags)
	end
	
	assert(istable(props.varargs), "Varargs is not a table")
	cmd:SetCommand(props.name)
	cmd:SetCallback(props.varargs, props.callback)
	CommandService.CreateConCommand(cmd)
	CommandService.Commands[cmd.name] = cmd
end