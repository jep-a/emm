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
    --- TODO: Update this statement when the voice channel class is complete
    ChatService.channels[new_id] = VoiceChannelClass.New(is_private)
    return ChatService.channels[new_id]
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