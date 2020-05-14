ChatNetService = ChatNetService or {}

-- Request Handlers
--- Handle request to create a voice channel
---@param creator Player | "Creator of the channel"
---@param private bool | "Should the server be private?"
function ChatNetService.ReqCreateVoiceChannel(creator, private)
    -- Check that the creator doesn't have a channel open already
    local has_channel = false
    local current_channel = {}
    -- TODO: Find better way to do this
    for channel_id, channel in pairs(ChatService.channels) do
        if channel:HasPlayer(creator) then
            current_channel = channel
        end
        if channel.host == creator and channel:InstanceOf(VoiceChannel) then
            has_channel = true
        end
    end

    if not has_channel then
        ChatService.RemovePlayer(current_channel, creator)
        ChatService.CreateVoiceChannel(creator, private)
    end
end
NetService.Receive("ReqCreateVoiceChannel", ChatNetService.ReqCreateVoiceChannel)

--- Handle request to create a text channel
---@param creator Player | "Creator of the channel"
---@param private bool | "Is the channel private?"
function ChatNetService.ReqCreateTextChannel(creator, private)
    -- Check that the creator doesn't have a channel open already
    local has_channel = false
    local current_channel = {}
    -- TODO: Find better way to do this
    for channel_id, channel in pairs(ChatService.channels) do
        if channel:HasPlayer(creator) then
            current_channel = channel
        end
        if channel.host == creator and channel:InstanceOf(TextChannel) then
            has_channel = true
        end
    end

    if not has_channel then
        ChatService.CreateTextChannel(creator, private)
    end
end
NetService.Receive("ReqCreateTextChannel", ChatNetService.ReqCreateTextChannel)

--- Handle request to join a channel
---@param ply Player | "Player requesting to join channel"
---@param channel ChatChannel | "Channel to put the player into"
function ChatNetService.ReqJoinChannel(ply, channel)
    -- Check if the target channel is private or the player is banned
    if channel.private or channel:CheckBan(ply) then return end
    if channel:HasPlayer(ply) then return end
    local current_channel = {}
    if channel:InstanceOf(VoiceChannel) then
        for channel_id, current_channel in pairs(ChatService.channels) do
            if current_channel:HasPlayer(ply) and current_channel:InstanceOf(VoiceChannel) then
                ChatService.RemovePlayer(current_channel, ply)
                break
            end
        end
    end

    channel:AddPlayer(ply)
    NetService.Broadcast("PlayerJoinChannel", channel, ply)
end
NetService.Receive("ReqJoinChannel", ChatNetService.ReqJoinChannel)

--- Handle request to invite a player to a channel
---@param ply Player | "Player requesting to invite"
---@param channel ChatChannel | "Chat channel the player is requesting to invite to"
---@param recipient Player | "Recipient of the invite"
function ChatNetService.ReqChannelInvite(ply, channel, recipient)
    if channel.flags[ply] & ChatChannel.OPERATOR then
        NetService.Send("ChatChannelInvite", recipient, channel, recipient)
        NetService.Send("ChatChannelInvite", channel.players, channel, recipient)
    end
end
NetService.Receive("ReqChannelInvite", ChatNetService.ReqChannelInvite)

--- Handle request to leave a channel
---@param ply Player | "Player requesting to leave"
---@param channel ChatChannel | "Channel the player is leaving"
function ChatNetService.ReqLeaveChannel(ply, channel)
    if channel.id > 2 then
        ChatService.RemovePlayer(channel, ply)
        ChatService.AddPlayer(ChatService.channels[2], ply)
    end
end
NetService.Receive("ReqLeaveChannel", ChatNetService.ReqLeaveChannel)

--- Handle request to accept invite to chat channel
---@param recipient Player | "Player that accepted the invite"
---@param channel ChatChannel | "Chat channel to join"
function ChatNetService.ReqAcceptChatInvite(recipient, channel)
    if channel:InstanceOf(VoiceChannel) then
        for channel_id, current_channel in pairs(ChatService.channels) do
            if current_channel:HasPlayer(recipient) and current_channel:InstanceOf(VoiceChannel) then
                ChatService.RemovePlayer(current_channel, recipient)
                break
            end
        end
    end
    channel:AddPlayer(recipient)
    NetService.Broadcast("PlayerJoinChannel", channel, recipient)
end
NetService.Receive("ReqAcceptChatInvite", ChatNetService.ReqAcceptChatInvite)

--- Handle request to sync lobbies to a player
---@param ply Player | "Player to send the lobbies to"
function ChatNetService.ReqSyncLobbies(ply)
    NetService.Send("SyncLobbyData",ply, ChatService.ChannelsToPacket())
end
NetService.Receive("ReqSyncLobbies", ChatNetService.ReqSyncLobbies)