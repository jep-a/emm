-- Type write for the chat channel
NetService.type_writers.chat_channel = NetService.type_writers.obj_id

--- Type reader for chat channel
NetService.type_readers.chat_channel = function()
    return ChatService.channels[NetService.ReadID()]
end

-- Signal name - {Schema Description}

-- Server -> Client
-- CreateVoiceChannel: {ChannelID: obj_id, Creator: player, isPrivate: bool}
NetService.CreateSchema("CreateVoiceChannel", {"id", "entity", "bool"})
-- CreateTextChannel: {ChannelID: obj_id, Creator: player, isPrivate: bool}
NetService.CreateSchema("CreateTextChannel", {"id", "entity", "bool"})
-- -- SyncChannelPlayerList: {ChannelID: obj_id, Players: entities}
-- NetService.CreateSchema("SyncChannelPlayerList", {"chat_channel", "entities"})
-- -- SyncChannelMuteList: {ChannelID: obj_id, Players: entities}
-- NetService.CreateSchema("SyncChannelMuteList", {"chat_channel", "entities"})
-- -- SyncChannelBanList: {ChannelID: obj_id, Players: entities}
-- NetService.CreateSchema("SyncChannelBanList", {"chat_channel", "entities"})

-- DestroyChannel: {ChannelID: obj_id}
NetService.CreateSchema("DestroyChannel", {"chat_channel"})
-- ChatChannelInvite: {ChannelID: obj_id, Who: player}
NetService.CreateSchema("ChatChannelInvite", {"chat_channel", "entity"})
-- PlayerJoinChannel: {ChannelID: obj_id, Who: player}
NetService.CreateSchema("PlayerJoinChannel", {"chat_channel", "entity"})
-- PlayerLeaveChannel: {ChannelID: obj_id, Who: player}
NetService.CreateSchema("PlayerLeaveChannel", {"chat_channel", "entity"})
-- SyncLobbyData: {ChannelID: obj_id, data: String}
NetService.CreateSchema("SyncLobbyData", {"chat_channel", "entity"})

-- Client -> Server
-- ReqCreateVoiceChannel: {isPrivate: bool}
NetService.CreateUpstreamSchema("ReqCreateVoiceChannel", {"bool"})
-- ReqCreateTextChannel: {isPrivate: bool}
NetService.CreateUpstreamSchema("ReqCreateTextChannel", {"bool"})
-- ReqJoinChannel: {ChannelID: obj_id}
NetService.CreateUpstreamSchema("ReqJoinChannel", {"chat_channel"})
-- ReqChannelInvite: {ChannelID: obj_id, Who: entity}
NetService.CreateUpstreamSchema("ReqChannelInvite", {"chat_channel", "entity"})
-- ReqLeaveChannel: {ChannelID: obj_id}
NetService.CreateUpstreamSchema("ReqLeaveChannel", {"chat_channel"})
-- ReqChannelBanPlayer: {ChannelID: obj_id, Who: entity}
NetService.CreateUpstreamSchema("ReqChannelBanPlayer", {"chat_channel", "entity"})
-- ReqChannelSetFlags: {ChannelID: obj_id, Who: entity, Flag: uint8, Set: bool}
NetService.CreateUpstreamSchema("ReqChannelSetFlags", {"chat_channel", "entity", "id", "boolean"})
-- ReqAcceptChatInvite: {ChannelID: obj_id}
NetService.CreateUpstreamSchema("ReqAcceptChatInvite", {"chat_channel"})
-- ReqSyncLobbies
NetService.CreateUpstreamSchema "ReqSyncLobbies"
-- ReqClChatMute: {ChannelID: obj_id}
NetService.CreateUpstreamSchema("ReqClChatMute", {"entity"})
