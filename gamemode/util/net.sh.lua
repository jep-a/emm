NetService = NetService or {}
NetService.hooks = NetService.hooks or {}
NetService.writers = NetService.writers or {}
NetService.readers = NetService.readers or {}

function NetService.ReadID()
	return net.ReadUInt(8)
end

function NetService.WriteID(id)
	net.WriteUInt(id or 0, 8)
end

NetService.type_readers = {
	boolean = net.ReadBool,

	id = function ()
		return NetService.ReadID()
	end,

	float = net.ReadFloat,
	string = net.ReadString,
	entity = net.ReadEntity,
	vector = net.ReadVector,

	entities = function ()
		local ents = {}
		local ent_count = NetService.ReadID()

		for i = 1, ent_count do
			table.insert(ents, net.ReadEntity())
		end

		return ents
	end,

	player_index = function ()
		return net.ReadUInt(16)
	end
}

NetService.type_writers = {
	boolean = net.WriteBool,

	id = function (id)
		NetService.WriteID(id)
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

	player_index = function (ply)
		net.WriteUInt(ply and ply:EntIndex() or 0, 16)
	end
}

function NetService.CreateWriter(name, schema)
	schema = schema or {}

	local sender = function (...)
		net.Start(name)
	
		for i = 1, #schema do
			NetService.type_writers[schema[i]](select(i, ...))
		end
	end

	NetService.writers[name] = sender

	return sender
end

function NetService.Receive(name, func)
	NetService.hooks[name] = func
end