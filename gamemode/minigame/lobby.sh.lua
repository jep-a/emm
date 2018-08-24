MinigameLobby = MinigameLobby or Class.New()

function MinigameLobby:__index(key)
	local proto = rawget(self, "prototype")

	if proto then
		local proto_mt_val = rawget(proto, key)

		if proto_mt_val ~= nil then
			return proto_mt_val
		end
	end

	local lobby_mt_val = rawget(MinigameLobby, key)

	if lobby_mt_val ~= nil then
		return lobby_mt_val
	end
end
