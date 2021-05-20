-- Type write for the chat channel
NetService.type_writers.chat_channel = NetService.type_writers.obj_id

--- Type reader for chat channel
NetService.type_readers.chat_channel = function()
    return CommService.channels[NetService.ReadID()]
end

-- Signal name: {Schema Description}

-- Server -> Client
-- CreateVoiceChannel: {ChannelID: obj_id, Creator: player, isPrivate: bool}
NetService.CreateSchema("CreateVoiceChannel", {"id", "entity", "bool"})
-- CreateTextChannel: {ChannelID: obj_id, Creator: player, isPrivate: bool}
NetService.CreateSchema("CreateTextChannel", {"id", "entity", "bool"})

-- DestroyChannel: {ChannelID: obj_id}
NetService.CreateSchema("DestroyChannel", {"chat_channel"})
-- ChatChannelInvite: {ChannelID: obj_id, Who: player}
NetService.CreateSchema("ChatChannelInvite", {"chat_channel", "entity", "integer"})
-- PlayerJoinChannel: {ChannelID: obj_id, Who: player}
NetService.CreateSchema("PlayerJoinChannel", {"chat_channel", "entity"})
-- PlayerLeaveChannel: {ChannelID: obj_id, Who: player}
NetService.CreateSchema("PlayerLeaveChannel", {"chat_channel", "entity"})
-- ChannelBannedPlayer: {ChannelID: obj_id, Who: player}
NetService.CreateSchema("ChannelBannedPlayer", {"chat_channel", "entity"})
-- ChannelUnbannedPlayer: {ChannelID: obj_id, Who: player}
NetService.CreateSchema("ChannelUnbannedPlayer", {"chat_channel", "entity"})
-- ChannelMutedPlayer: {ChannelID: obj_id, Who: player}
NetService.CreateSchema("ChannelMutedPlayer", {"chat_channel", "entity"})
-- ChannelUnmutedPlayer: {ChannelID: obj_id, Who: player}
NetService.CreateSchema("ChannelUnmutedPlayer", {"chat_channel", "entity"})
-- ChannelSetOP: {ChannelID: obj_id, Who: player}
NetService.CreateSchema("ChannelSetOP", {"chat_channel", "entity"})
-- ChannelUnsetOP: {ChannelID: obj_id, Who: player}
NetService.CreateSchema("ChannelUnsetOP", {"chat_channel", "entity"})
-- SyncLobbyData: {data: String}
NetService.CreateSchema("SyncLobbyData", {"string"})

-- Client -> Server
-- ReqCreateVoiceChannel: {isPrivate: bool}
NetService.CreateUpstreamSchema("ReqCreateVoiceChannel", {"bool"})
-- ReqCreateTextChannel: {isPrivate: bool}
NetService.CreateUpstreamSchema("ReqCreateTextChannel", {"bool"})
-- ReqJoinChannel: {ChannelID: obj_id}
NetService.CreateUpstreamSchema("ReqJoinChannel", {"chat_channel"})
-- ReqChannelInvite: {ChannelID: obj_id, Who: entity}
NetService.CreateUpstreamSchema("ReqChannelInvite", {"chat_channel", "entity", "integer"})
-- ReqLeaveChannel: {ChannelID: obj_id}
NetService.CreateUpstreamSchema("ReqLeaveChannel", {"chat_channel"})
-- ReqChannelBanPlayer: {ChannelID: obj_id, Who: entity}
NetService.CreateUpstreamSchema("ReqChannelBanPlayer", {"chat_channel", "entity"})
-- ReqChannelSetOP: {ChannelID: obj_id, Who: entity}
NetService.CreateUpstreamSchema("ReqChannelSetOP", {"chat_channel", "entity"})
-- ReqChannelSetMute: {ChannelID: obj_id, Who: entity}
NetService.CreateUpstreamSchema("ReqChannelSetMute", {"chat_channel", "entity"})
-- ReqChannelUnbanPlayer: {ChannelID: obj_id, Who: entity}
NetService.CreateUpstreamSchema("ReqChannelUnbanPlayer", {"chat_channel", "entity"})
-- ReqChannelUnsetOP: {ChannelID: obj_id, Who: entity}
NetService.CreateUpstreamSchema("ReqChannelUnsetOP", {"chat_channel", "entity"})
-- ReqChannelUnsetMute: {ChannelID: obj_id, Who: entity}
NetService.CreateUpstreamSchema("ReqChannelUnsetMute", {"chat_channel", "entity"})
-- ReqAcceptChatInvite: {ChannelID: obj_id}
NetService.CreateUpstreamSchema("ReqAcceptChatInvite", {"chat_channel"})
-- ReqSyncLobbies
NetService.CreateUpstreamSchema "ReqSyncLobbies"
-- ReqClChatMute: {ChannelID: obj_id}
NetService.CreateUpstreamSchema("ReqClChatMute", {"entity"})
