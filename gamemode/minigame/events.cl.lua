MinigameEventService.receivers = {}

local type_readers = {
	boolean = net.ReadBool,

	id = function (id)
		return net.ReadUInt(8, id)
	end,

	float = net.ReadFloat,
	string = net.ReadString,
	entity = net.ReadEntity,
	vector = net.ReadVector
}

function MinigameEventService.Create(name, struct)
	net.Receive(name, function (_, ...)
		local lobby_id = net.ReadUInt(8)
		local read = {}

		for i = 1, #struct do
			table.insert(read, type_readers[struct[i]](select(i, ...)))
		end

		MinigameEventService.Call(MinigameService.lobbies[lobby_id], name, unpack(read))
	end)
end

function MinigameEventService.Call(lobby, name, ...)
	local global_hooks = lobby.event_hooks[name]
	local proto_hooks = lobby.event_hooks[lobby.key.."."..name]

	local local_lobby = lobby:IsLocal()
	local involves_local_ply = table.HasValue({...}, LocalPlayer())

	if global_hooks then
		for _, hk in pairs(global_hooks) do
			hk(lobby, local_lobby, involves_local_ply, ...)
		end
	end

	if proto_hooks then
		for _, hk in pairs(proto_hooks) do
			hk(lobby, local_lobby, involves_local_ply, ...)
		end
	end
end

function MinigamePrototype:AddEventHook(event_name, hk_id, func)
	local proto_event_name = self.key.."."..event_name

	self.event_hooks[proto_event_name] = self.event_hooks[proto_event_name] or {}
	self.event_hooks[proto_event_name][hk_id] = func
end

function MinigamePrototype:RemoveEventHook(event_name, hk_id)
	self.state_hooks[self.key.."."..event_name][hk_id] = nil
end