ChatService = ChatService or {}
ChatService.channels = ChatService.channels or {}

--- Remove channel from the channel list
---@param channel_id uint8
function ChatService.DestroyChannel(channel_id)
    if(ChatService.channels[channel_id]) then
        ChatService.channels[channel_id] = nil
    end
end


-- Call channel specific hook
function ChatService.CallHook(channel, hk_name, ...)
	if channel[hk_name] then
		channel[hk_name](channel, ...)
	end

	channel.hooks[hk_name] = channel.hooks[hk_name] or {}
	for _, hk in pairs(channel.hooks[hk_name]) do
		hk(lobby, ...)
	end
end

function ChatService.AddHook(channel, hk_name, func)
	table.insert(channel.hooks[hk_name], func)
end

function ChatService.InviteI
