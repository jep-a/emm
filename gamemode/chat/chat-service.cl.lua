ChatService = ChatService or {}
ChatService.channels = ChatService.channels or {}

--- Add new voice channel
---@param channel_id uint8
---@param is_private boolean | "Is the channel private?"
function ChatService.CreateVoiceChannel(channel_id, is_private, host)
    --- TODO: Update this statement when the voice channel class is complete
    ChatService.channels[channel_id] = VoiceChannelClass:New(is_private)
end 

--- Add new text channel
---@param channel_id uint8
---@param is_private boolean | "Is the channel private?"
function ChatService.CreateTextChannel(channel_id, is_private, host)
    --- TODO: Update this statement when the text channel class is complete
    ChatService.channels[channel_id] = TextChannelClass:New(is_private)
end

--- Converts the packet to channels
---@param packet string | "Packet data to turn into channels"
function ChatService.PacketToChannels(packet)
    local channel_info = util.JSONToTable(util.Decompress(packet))
    for channel_id, channel_data in pairs(channel_info) do
			local new_channel = {}
			if channel_data.voice then
					new_channel = ChatService.CreateVoiceChannel(channel_id, channel_data.private, Player(channel_data.host))
			else
					new_channel = ChatService.CreateTextChannel(channel_id, channel_data.private, Player(channel_data.host))
			end

			for ply_id, flags in pairs(channel_tab.ply_flags) do
				new_channel:AddPlayer(Player(ply_id))
				new_channel:SetPlayerFlags(flags)
			end

			for _, invite in pairs(invites) do
				new_channel:AddInvite(unpack(invite))
			end

			for ply,_ in pairs(channel_data.bans) do
				new_channel:Ban(ply)
			end
		end	
end
