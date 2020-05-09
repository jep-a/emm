ChatNetService = ChatNetService or ChatService or {}
-- -- PlayerJoinChannel: {ChannelID: obj_id, Who: player}
-- NetService.CreateSchema("PlayerJoinChannel", {"chat_channel", "entity"})
-- -- PlayerLeaveChannel: {ChannelID: obj_id, Who: player}
-- NetService.CreateSchema("PlayerLeaveChannel", {"chat_channel", "entity"})
-- -- SyncLobbyData: {ChannelID: obj_id, data: String}
-- NetService.CreateSchema("SyncLobbyData", {"chat_channel", "entity"})

function ChatNetService.CreateVoiceChannel(channel_id, creator, is_private)
    ChatService.channels[channel_id] = VoiceChannel:New(channel_id, creator, is_private)
end

function ChatNetService.CreateTextChannel(channel_id, creator, is_private)
    ChatService.channels[channel_id] = TextChannel:New(channel_id, creator, is_private)
end

function ChatNetService.DestroyChannel(channel)
end

function ChatNetService.ChatChannelInvite(channel, who)
end

function ChatNetService.PlayerJoinChannel(channel, who)
end

function ChatNetService.PlayerLeaveChannel(channel, who)
end

function ChatNetService.SyncLobbyData(data)
end