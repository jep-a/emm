ChatNetService = ChatNetService or {}

--[[ TODO
    Both CreateVoiceChannel and CreateTextChannel have the first parameter
    as a type reader for chat_channel. This makes the assumption that the
    channel is somehow already on the client. 
    
    Need to change the type reader to id.
]]
--- Voice channel created
---@param channel_id uint8 | "New channel ID"
---@param creator Player | "Creator of the channel"
---@param is_private bool | "Is the channel private?"
function ChatNetService.CreateVoiceChannel(channel_id, creator, is_private)
    -- Update UI with a new voice channel
end
NetService.Receive("CreateVoiceChannel", ChatNetService.CreateVoiceChannel)

--- Text channel created
---@param channel_id uint8 | "New channel ID"
---@param creator any
---@param is_private any
function ChatNetService.CreateTextChannel(channel_id, creator, is_private)
    -- Update UI with a new text channel
end
NetService.Receive("CreateTextChannel", ChatNetService.CreateTextChannel)

--- Channel destroyed
---@param channel ChatChannel | "New channel"
function ChatNetService.DestroyChannel(channel)
    -- Remove channel from the UI
end
NetService.Receive("DestroyChannel", ChatNetService.DestroyChannel)

--[[
    I send information about the player being invited so that this message
    can also be sent to people in the lobby. This is so everyone in the lobby
    can know whose been invited.
]]
--- Channel invite received
---@param channel ChatChannel | "Channel to join"
---@param who Player | "Who the invite is being sent to"
function ChatNetService.ChatChannelInvite(channel, who)
    -- Emphasize channel in UI 
end
NetService.Receive("ChatChannelInvite", ChatNetService.ChatChannelInvite)

--- Player joined the channel
---@param channel ChatChannel
---@param who Player | "Player joining the channel"
function ChatNetService.PlayerJoinChannel(channel, who)
    -- Update channel UI element
end
NetService.Receive("PlayerJoinChannel", ChatNetService.PlayerJoinChannel)

--- Player left the channel
---@param channel ChatChannel
---@param who Player | "Player who left the channel" 
function ChatNetService.PlayerLeaveChannel(channel, who)
    -- Update channel UI element
end
NetService.Receive("PlayerLeaveChannel", ChatNetService.PlayerLeaveChannel)