ChatNetService = ChatNetService or ChatService or {}

function ChatNetService.CreateVoiceChannel(channel_id, creator, is_private)
    ChatService.channels[channel_id] = VoiceChannel:New(channel_id, creator, is_private)
end
NetService.Receive("CreateVoiceChannel", ChatNetService.CreateVoiceChannel)

function ChatNetService.CreateTextChannel(channel_id, creator, is_private)
    ChatService.channels[channel_id] = TextChannel:New(channel_id, creator, is_private)
end
NetService.Receive("CreateTextChannel", ChatNetService.CreateTextChannel)


function ChatNetService.DestroyChannel(channel)
end
NetService.Receive("DestroyChannel", ChatNetService.DestroyChannel)

-- TODO: Add timeout for invites
--- Handle invite from a channel
---@param channel ChatChannel | "Channel the player is invite to"
---@param ply Player | "Player being invited to the channel"
function ChatNetService.ChatChannelInvite(channel, ply)
    if LocalPlayer() == ply then
        NetService.Broadcast(channel)
    else
        --- Print that the player was invited to the channel
    end
end
NetService.Receive("ChatChannelInvite", ChatNetService.ChatChannelInvite)

--- Handle player joining a channel
---@param channel any
---@param ply any
function ChatNetService.PlayerJoinChannel(channel, ply)
    channel:AddPlayer(ply)
end
NetService.Receive("PlayerJoinChannel", ChatNetService.PlayerJoinChannel)

--- Handle player leaving a channel
---@param channel ChatChannel
---@param ply Player
function ChatNetService.PlayerLeaveChannel(channel, ply)
    channel:RemovePlayer(ply)
end
NetService.Receive("PlayerLeaveChannel", ChatNetService.PlayerLeaveChannel)

-- ChannelBannedPlayer: {ChannelID: obj_id, Who: player}
function ChatNetService.ChannelBannedPlayer(channel, ply)
    channel:Ban(ply)
end
NetService.Receive("ChannelBannedPlayer", ChatNetService.ChannelBannedPlayer)

-- ChannelUnbannedPlayer: {ChannelID: obj_id, Who: player}
function ChatNetService.ChannelUnbannedPlayer(channel, ply)
    channel:RemoveBan(ply)
end
NetService.Receive("ChannelUnbannedPlayer", ChatNetService.ChannelUnbannedPlayer)

-- ChannelMutedPlayer: {ChannelID: obj_id, Who: player}
function ChatNetService.ChannelMutedPlayer(channel, ply)
    channel:Mute(ply)
end
NetService.Receive("ChannelMutedPlayer", ChatNetService.ChannelMutedPlayer)

-- ChannelUnmutedPlayer: {ChannelID: obj_id, Who: player}
function ChatNetService.ChannelUnmutedPlayer(channel, ply)
    channel:RemoveMute(ply)
end
NetService.Receive("ChannelUnmutedPlayer", ChatNetService.ChannelUnmutedPlayer)

-- ChannelSetOP: {ChannelID: obj_id, Who: player}
function ChatNetService.ChannelSetOP(channel, ply)
    channel:OP(ply)
end
NetService.Receive("ChannelSetOP", ChatNetService.ChannelSetOP)

-- ChannelUnsetOP: {ChannelID: obj_id, Who: player}
function ChatNetService.ChannelUnsetOP(channel, ply)
    channel:RemoveOP(ply)
end
NetService.Receive("ChannelUnsetOP", ChatNetService.ChannelUnsetOP)

--- Handle lobby data syncing
---@param data String | "Data to be synced"
function ChatNetService.SyncLobbyData(data)
    ChatService.PacketToChannels(data)
end
NetService.Receive("SyncLobbyData", ChatNetService.SyncLobbyData)