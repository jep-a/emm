ChatService = ChatService or {}
ChatService.channels = ChatService.channels or {}

--- Remove channel from the channel list
---@param channel_id uint8
function ChatService:DestroyChannel(channel_id)
    if(self.channels[channel_id]) then
        self.channels[channel_id] = nil
    end
end