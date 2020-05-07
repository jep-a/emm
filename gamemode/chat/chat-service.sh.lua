ChatService = ChatService or {}
ChatService.channels = ChatService.channels or {}

--- Remove channel from the channel list
---@param channel_id uint8
function ChatService.DestroyChannel(channel_id)
    if(ChatService.channels[channel_id]) then
        ChatService.channels[channel_id] = nil
    end
end