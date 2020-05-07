ChatService = ChatService or {}

-- Request Handlers
--- Handle request to create a voice channel
---@param creator Player | "Creator of the channel"
---@param private bool | "Should the server be private?"
function ChatService.ReqCreateVoiceChannel(creator, private)
    -- Check that the creator doesn't have a channel open already
    -- Create new channel
    -- Set channel host to [creator]
    -- Set channel private to [private]
    -- Remove player from their current channel
    -- Add player to the new channel
    -- Broadcast new channel information
end
NetService.Receive("ReqCreateVoiceChannel", ChatService.ReqCreateVoiceChannel)

--- Handle request to create a text channel
---@param creator Player | "Creator of the channel"
---@param private bool | "Is the channel private?"
function ChatService.ReqCreateTextChannel(creator, private)
    -- Create new channel
    -- Set channel host to [creator]
    -- Set channel private to [private]
    -- Remove player from their current channel
    -- Add player to the new channel
    -- Broadcast new channel information
end
NetService.Receive("ReqCreateTextChannel", ChatService.ReqCreateTextChannel)

--- Handle request to join a channel
---@param ply Player | "Player requesting to join channel"
---@param channel ChatChannel | "Channel to put the player into"
function ChatService.ReqJoinChannel(ply, channel)
    -- 
end
NetService.Receive("ReqJoinChannel", ChatService.ReqJoinChannel)

--- Handle request to invite a player to a channel
---@param ply Player | "Player requesting to invite"
---@param channel ChatChannel | "Chat channel the player is requesting to invite to"
---@param recipient Player | "Recipient of the invite"
function ChatService.ReqChannelInvite(ply, channel, recipient)
end
NetService.Receive("ReqChannelInvite", ChatService.ReqChannelInvite)

--- Handle request to leave a channel
---@param ply Player | "Player requesting to leave"
---@param channel ChatChannel | "Channel the player is leaving"
function ChatService.ReqLeaveChannel(ply, channel)
end
NetService.Receive("ReqLeaveChannel", ChatService.ReqLeaveChannel)