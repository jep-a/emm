Command = Command or Class.New()

function Command:Init()
	self.name = ""
	self.cmds = {}
	self.args = {}
	self.flags = {}
	self.callback = function() end
end

function Command:RemoveFlags(flags)
	if istable(flags) then
		for _, flag in ipairs(flags) do
			self.flags[flag] = false
		end
	else
		self.flags[flags] = false
	end
end

function Command:AddFlags(flags)
	if istable(flags) then
		for _, flag in ipairs(flags) do
			self.flags[flag] = true
		end
	else
		self.flags[flags] = true
	end
end

function Command:HasFlag(flag)
	return self.flags[flag]
end

function Command:SetCommand(...)
	self.cmds = table.concat({...}, " "):lower():Split(" ")
	self.name = self.cmds[1]

	for _, cmd in ipairs(CommandService.Commands) do
		if cmd.name:sub(1, 1) ~= self.name:sub(1, 1) then
			continue
		end

		return
	end

	table.insert(self.cmds, self.name:sub(1, 1))
end

function Command:SetCallback(args, callback)
	self.args = args
	self.callback = function(...)
		local args = self.args
		local command_args = {...}
		local sender = table.remove(command_args, 1)
		local player_table = false
		
		if #command_args > 0 then
			for k, arg in ipairs(args) do
				if isnumber(arg) and isnumber(command_args[k - 1]) then
					if isnumber(args[k + 1]) then
						command_args[k - 1] = math.min(command_args[k - 1], args[k + 1])
						table.remove(command_args, k + 1)
					end

					command_args[k - 1] = math.max(command_args[k - 1], arg)
					table.remove(command_args, k)
					continue
				end

				if command_args[k] then
					if CommandService.symbols[command_args[k]] then
						if table.HasValue(CommandService.symbols[command_args[k]].varargs, arg) then
							command_args[k] = CommandService.symbols[command_args[k]].callback(sender)
						end
					end

					command_args[k] = CommandService.object_types[arg](command_args[k])

					if arg == "players" and istable(command_args[k]) then
						player_table = {key = k, players = command_args[k]}
					end
				end
			end

			if player_table then
				for k, ply in ipairs(player_table.players) do
					local command_args_temp = table.Copy(command_args)

					command_args_temp[player_table.key] = ply
					callback(sender, unpack(command_args_temp))
				end
				return
			end

			callback(sender, unpack(command_args))
		else
			callback(sender)
		end
	end 
end

function Command:Execute(sender, ...)
	local cmd_hk

	sender = (sender != NULL and sender or "server")
	cmd_hk = hook.Call("OnCommand", GAMEMODE, sender, self, {...})

	if cmd_hk then
		return
	end

	self.callback(sender, ...)
end