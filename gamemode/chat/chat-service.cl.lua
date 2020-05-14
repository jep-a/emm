ChatService = ChatService or {}
ChatService.channels = ChatService.channels or {}

--- Add new voice channel
---@param channel_id uint8
---@param is_private bool | "Is the channel private?"
function ChatService.CreateVoiceChannel(channel_id, is_private, host)
    --- TODO: Update this statement when the voice channel class is complete
    ChatService.channels[channel_id] = VoiceChannelClass:New(is_private)
end 

--- Add new text channel
---@param channel_id uint8
---@param is_private bool | "Is the channel private?"
function ChatService.CreateTextChannel(channel_id, is_private, host)
    --- TODO: Update this statement when the text channel class is complete
    ChatService.channels[channel_id] = TextChannelClass:New(is_private)
end

--- Converts the packet to channels
---@param packet String | "Packet data to turn into channels"
function ChatService.PacketToChannels(packet)
    local channel_info = util.JSONToTable(util.Decompress(packet))
    for channel_id, channel_data in pairs(channel_info) do
        local new_channel = {}
        if channel_data.voice then
            new_channel = ChatService.CreateVoiceChannel(channel_id, channel_data.private, Player(channel_data.host))
        else
            new_channel = ChatService.CreateTextChannel(channel_id, channel_data.private, Player(channel_data.host))
        end
        --What about bans?
        for ply_id, flags in pairs(channel_tab.ply_flags) do
            new_channel.players[Player(ply_id)] = flags
        end
    end
end