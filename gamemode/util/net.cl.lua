function NetService.CreateSchema(name, schema)
	NetService.CreateReader(name, schema)
end

function NetService.CreateUpstreamSchema(name, schema)
	NetService.CreateWriter(name, schema)
end

function NetService.CreateReader(name, schema)
	schema = schema or {}

	local receiver = function ()
		local read = {}

		for i = 1, #schema do
			table.insert(read, NetService.type_readers[schema[i]]())
		end
	
		NetService.hooks[name](unpack(read))
	end

	net.Receive(name, receiver)

	return receiver
end

function NetService.Send(name, ...)
	NetService.writers[name](...)
	net.SendToServer()
end