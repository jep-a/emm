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

--- Broadcast net message to all clients
---@param name string | "Signal name"
function NetService.Broadcast(name, ...)
	NetService.writers[name](...)
	net.Broadcast()
end

--- Send a net message to the specified player(s)
---@param name string | "Signal name"
---@param plys player|table | "Player or table of Players"
function NetService.Send(name, plys, ...)
	NetService.writers[name](...)
	net.Send(plys)
end

function NetService.SendCustom(name, sender, ...)
	NetService.writers[name](...)
	sender()
end

--return lsn.canHear[tlk]