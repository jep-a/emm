ChatChannel = ChatChannel or Class.New({__tostring = function(channel)
	return channel.host:Name().."'s ".."chat channel: "..channel.name
end})

ChatChannel.MUTED = 1   --0b0001
ChatChannel.OPERATOR = 1<<1   --0b0010

function ChatChannel:Init(id, host, name, private)
    self.id = id or 0
		self.name = name or nil
    self.host = host or nil
    self.private = private or nil
    self.players = {}
    self.flags = {}
    self.bans = {}
    self.invites = {}

    if host ~= nil then
        self:AddPlayer(host)
        self:AddOperator(host)
    end
end

function ChatChannel:GetPlayers()
    return self.players
end

function ChatChannel:HasPlayer(ply)
    return self.flags[ply] ~= nil
end

function ChatChannel:AddPlayer(ply, flags)
    table.insert(self.players, ply)
    self.flags[ply] = flags or 0
		ChatService.CallHook(self, "OnPlayerJoin", ply)
end

function ChatChannel:RemovePlayer(ply)
    table.remove(self.flags, ply)
    self.flags[ply] = nil

		ChatService.CallHook(self, "OnPlayerLeave", ply)
end

function ChatChannel:AddOperator(ply)
    self.flags[ply] = self.flags[ply] | ChatChannel.OPERATOR
		ChatService.CallHook(self, "OnPlayerPromote", ply)
end

function ChatChannel:RemoveOperator(ply)
    self.flags[ply] = self.flags[ply] & ~ChatChannel.OPERATOR
		ChatService.CallHook(self, "OnPlayerDemote", ply)
end

function ChatChannel:CheckOperator(ply)
    if self.flags[ply] ~= nil then return false end
    
    return self.flags[ply] & ChatChannel.MUTE
end

function ChatChannel:Ban(ply)
    self:RemovePlayer(ply)
		self:RemoveInvite(ply)
    self.bans[ply] = true
		ChatService.CallHook(self, "OnPlayerBan", ply)
end

function ChatChannel:RemoveBan(ply)
    self.bans[ply] = nil
		ChatService.CallHook(self, "OnPlayerUnban", ply)
end

function ChatChannel:CheckBan(ply)
    return self.bans[ply] ~= nil
end

function ChatChannel:Mute(ply)
    if ChatChannel.HasPlayer(self, ply) then
        self.flags[ply] = self.flags[ply] | ChatChannel.MUTE
    end
		ChatService.CallHook(self, "OnPlayerMute", ply)
end

function ChatChannel:RemoveMute(ply)
    if ChatChannel.HasPlayer(self, ply) then
        self.flags[ply] = self.flags[ply] & ~ChatChannel.MUTE
    end
		ChatService.CallHook(self, "OnPlayerUnmute", ply)
end


function ChatChannel:CheckMute(ply)
    if self.flags[ply] ~= nil then return false end

    return self.flags[ply] & ChatChannel.MUTE
end

function ChatChannel:PlyCount()
    table.Count(self.players)
end

function ChatChannel:AddInvite(ply, timeout)
    self.invites[ply] = true
    if timeout and timeout > 0 then 
			timer.Create(self:GetInviteID(), timeout, 1, function()
				self.invites[ply] = nil 
				ChatService.CallHook(self, "OnPlayerInviteExpire", ply)
			end)
    end
		ChatService.CallHook(self, "OnPlayerInvite", ply, timeout)
end


function ChatChannel:RemoveInvite(ply)
  local timer_id = self:GetInviteID(ply)
  if not timer.Exists(timer_id) then
		return
  end
	timer.Remove(timer_id)
  self.invites[ply] = nil
	ChatService.CallHook(self, "OnPlayerInviteRemove", ply)
end

function ChatChannel:HasInvite(ply)
  return self.invites[ply] == true
end

function ChatChannel:SetName(name)
	self.name = name
end

function ChatChannel:GetName()
	return self.name
end

function ChatChannel:GetInviteID(ply)
	return "invite_ch_"..self.id.."_pl_"..ply.UserID()
end

function ChatChannel:SetPlayerFlags(ply, flags)
	self.flags[ply] = flags
end
	
