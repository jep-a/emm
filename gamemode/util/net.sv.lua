function NetService.CreateSchema(name, schema)
	util.AddNetworkString(name)
	NetService.CreateWriter(name, schema)
end

function NetService.CreateUpstreamSchema(name, schema)
	util.AddNetworkString(name)
	NetService.CreateReader(name, schema)
end

function NetService.CreateReader(name, schema)
	schema = schema or {}

	local receiver = function (len, ply)
		local read = {}

		for i = 1, #schema do
			table.insert(read, NetService.type_readers[schema[i]]())
		end

		NetService.hooks[name](ply, unpack(read))
	end

	net.Receive(name, receiver)

	return receiver
end

function NetService.Send(name, ...)
	NetService.writers[name](...)
	net.Broadcast()
end

function NetService.SendCustom(name, sender, ...)
	NetService.writers[name](...)
	sender()
end