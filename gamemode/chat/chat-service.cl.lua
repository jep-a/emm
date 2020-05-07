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
end