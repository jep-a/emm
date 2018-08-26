MinigameEventService.senders = MinigameEventService.senders or {}

local type_senders = {
	boolean = net.WriteBool,

	id = function (id)
		net.WriteUInt(id, 8)
	end,

	float = net.WriteFloat,
	string = net.WriteString,
	entity = net.WriteEntity,
	vector = net.WriteVector,

	entities = function (ents)
		net.WriteUInt(#ents, 8)

		for _, ent in pairs(ents) do
			net.WriteEntity(ent)
		end
	end,
}

function MinigameEventService.Create(name, struct)
	util.AddNetworkString(name)

	MinigameEventService.senders[name] = function (...)
		for i = 1, #struct do
			type_senders[struct[i]](select(i, ...))
		end
	end
end

function MinigameEventService.Call(lobby, name, ...)
	local proto_event_name = lobby.key.."."..name

	local proto_sender = MinigameEventService.senders[proto_event_name]
	local global_sender = MinigameEventService.senders[name]

	if proto_sender then
		net.Start(proto_event_name)
		net.WriteUInt(lobby.id, 8)
		proto_sender(...)
		net.Broadcast()
	elseif global_sender then
		net.Start(name)
		net.WriteUInt(lobby.id, 8)
		MinigameEventService.senders[name](...)
		net.Broadcast()
	end
end