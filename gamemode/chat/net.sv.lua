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
function ChatNetService.ReqJoinChannel(ply, channel)
    -- Check if the target channel is private
    -- ?? If it is send a join error ??
    -- Remove the player from their current channel
    -- Broadcast player left signal
    -- Add the player to the new channel
    -- Broadcast player joined signal
end
NetService.Receive("ReqJoinChannel", ChatService.ReqJoinChannel)

--- Handle request to invite a player to a channel
---@param ply Player | "Player requesting to invite"
---@param channel ChatChannel | "Chat channel the player is requesting to invite to"
---@param recipient Player | "Recipient of the invite"
function ChatNetService.ReqChannelInvite(ply, channel, recipient)
    -- Check if the ply has op flag
    -- Send SendChannelInvite -> recipient + everyone in the channel
end
NetService.Receive("ReqChannelInvite", ChatService.ReqChannelInvite)

--- Handle request to leave a channel
---@param ply Player | "Player requesting to leave"
---@param channel ChatChannel | "Channel the player is leaving"
function ChatService.ReqLeaveChannel(ply, channel)
end
NetService.Receive("ReqLeaveChannel", ChatService.ReqLeaveChannel)

--- Handle request to accept invite to chat channel
---@param recipient Player | "Player that accepted the invite"
---@param channel ChatChannel | "Chat channel to join"
function ChatNetService.ReqAcceptChatInvite(recipient, channel)
    -- Remove player from current channel
    -- Broadcast PlayerLeaveChannel
    -- Put player in new channel
    -- Broadcast PlayerJoinChannel
end
NetService.Receive("ReqAcceptChatInvite", ChatNetService.ReqAcceptChatInvite)

--- Handle request to sync lobbies to a player
---@param ply Player | "Player to send the lobbies to"
function ChatNetService.ReqSyncLobbies(ply) 
    -- Send lobby data
end
NetService.Receive("ReqSyncLobbies", ChatService.ReqSyncLobbies)


-- -- ?? All the player is doing is asking to be in the public ??
-- -- ?? channel so should we keep this request                ??
-- --- Handle request to leave a channel
-- ---@param ply Player | "Player requesting to leave"
-- ---@param channel ChatChannel | "Channel the player is leaving"
-- function ChatNetService.ReqLeaveChannel(ply, channel)
--     -- Remove player from current channel
--     -- Broadcast PlayerLeaveChannel
--     -- Put player in new channel
--     -- Broadcast PlayerJoinChannel
-- end
-- NetService.Receive("ReqLeaveChannel", ChatNetService.ReqLeaveChannel)
