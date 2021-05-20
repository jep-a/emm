ChannelService = ChannelService or {}
ChannelService.channels = ChannelService.channels or {}

--- Get the next free channel id
local function NextFreeChannelID()
    return #ChannelService.channels + 1
end


--- Create new voice channel
---@param host Player | "Host of the new channel"
---@param is_private bool | "Is the channel private?"
function ChannelService.CreateVoiceChannel(host, is_private)
    local new_id = NextFreeChannelID()
    ChannelService.channels[new_id] = VoiceChannel.New(new_id, host, is_private)
    NetService.Broadcast("CreateVoiceChannel", ChannelService.channels[new_id], host, is_private)
end

--- Create new text channel
---@param host Player | "Host of the new channel"
---@param is_private bool | "Is the channel private?"
function ChannelService.CreateTextChannel(host, is_private)
    local new_id = NextFreeChannelID()
    --- TODO: Update this statement when the text channel class is complete
    ChannelService.channels[new_id] = TextChannel.New(new_id, host, is_private)
    NetService.Broadcast("CreateTextChannel", ChannelService.channels[new_id], host, is_private)
end

--- Return compressed string representing the channel info
function ChannelService.ChannelsToPacket()
    local channel_info = {}
    for _, channel in pairs(ChannelService.channels) do
				table.insert(channel_info, channel:GetSerializeable())
    end
		-- TODO: abstract serialization into member function so that
		--       child data members can also be serialized with polymorphism
    
    return util.Compress(util.TableToJSON(channel_info))
end

--- Add player to the channel and broadcast to all players
---@param channel | "Channel to add the player to" 
---@param ply | "Player to add to the channel"
function ChannelService.AddPlayer(channel, ply)
    channel:AddPlayer(ply)
    NetService.Broadcast("PlayerJoinChannel", channel, ply)
end

--- Remove player from the lobby and broadcast
---@param channel ChatChannel | "Channel to remove the player from"
---@param player Player | "Player to remove from the channel"
function ChannelService.RemovePlayer(channel, player)
    channel:RemovePlayer(player)
    NetService.Broadcast("PlayerLeaveChannel", channel, player)
    ChannelService.channels[channel.id] = nil
end
