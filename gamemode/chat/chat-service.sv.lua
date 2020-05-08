ChatService = ChatService or {}
ChatService.channels = ChatService.channels or {}

--- Get the next free channel id
local function NextFreeChannelID()
    return #ChatService.channels + 1
end


--- Create new voice channel
---@param host Player | "Host of the new channel"
---@param is_private bool | "Is the channel private?"
function ChatService.CreateVoiceChannel(host, is_private)
    local new_id = NextFreeChannelID()
    ChatService.channels[new_id] = VoiceChannel.New(new_id, host, is_private)
    NetService.Broadcast("CreateVoiceChannel", ChatService.channels[new_id], host, is_private)
end

--- Create new text channel
---@param host Player | "Host of the new channel"
---@param is_private bool | "Is the channel private?"
function ChatService.CreateTextChannel(host, is_private)
    local new_id = NextFreeChannelID()
    --- TODO: Update this statement when the text channel class is complete
    ChatService.channels[new_id] = TextChannelClass.New(is_private)
    return ChatService.channels[new_id]
end

--- Return compressed string representing the channel info
function ChatService.ChannelsToPacket()
    local channel_info = {}
    for channel_id, channel_data in pairs(ChatService.channels) do
        local channel_tab = {}
        channel_tab.ply_flags = {}

        channel_tab.id = channel_id
        channel_tab.voice = Class.InstanceOf(channel_tab, VoiceChannel)
        channel_tab.host_id = channel_data.host:UserID()
        channel_tab.private = channel_data.private
        for ply, ply_flags in pairs(channel_data.flags) do
            channel_tab.ply_flags[ply:UserID()] = ply_flags
        end
        table.insert(channel_info, channel_tab)
    end
    
    return util.Compress(util.TableToJSON(channel_info))
end
