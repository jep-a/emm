CommChannel = CommChannel or Class.New({__tostring = function(channel)
	return channel.host:Name().."'s ".."chat channel: "..channel.name
end})
CommChannel.MUTED = 1   --0b0001
CommChannel.OPERATOR = 1<<1   --0b0010

function CommChannel:Init(id, host, name, private)
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

function CommChannel:GetPlayers()
    return self.players
end

function CommChannel:HasPlayer(ply)
    return self.flags[ply] ~= nil
end

function CommChannel:AddPlayer(ply, flags)
    table.insert(self.players, ply)
    self.flags[ply] = flags or 0
		ChatService.CallHook(self, "OnPlayerJoin", ply)
end

function CommChannel:RemovePlayer(ply)
    table.remove(self.flags, ply)
    self.flags[ply] = nil

		ChatService.CallHook(self, "OnPlayerLeave", ply)
end

function CommChannel:AddOperator(ply)
    self.flags[ply] = self.flags[ply] | CommChannel.OPERATOR
		ChatService.CallHook(self, "OnPlayerPromote", ply)
end

function CommChannel:RemoveOperator(ply)
    self.flags[ply] = self.flags[ply] & ~CommChannel.OPERATOR
		ChatService.CallHook(self, "OnPlayerDemote", ply)
end

function CommChannel:CheckOperator(ply)
    if self.flags[ply] ~= nil then return false end
    
    return self.flags[ply] & CommChannel.MUTE
end

function CommChannel:Ban(ply)
    self:RemovePlayer(ply)
		self:RemoveInvite(ply)
    self.bans[ply] = true
		ChatService.CallHook(self, "OnPlayerBan", ply)
end

function CommChannel:RemoveBan(ply)
    self.bans[ply] = nil
		ChatService.CallHook(self, "OnPlayerUnban", ply)
end

function CommChannel:CheckBan(ply)
    return self.bans[ply] ~= nil
end

function CommChannel:Mute(ply)
    if CommChannel.HasPlayer(self, ply) then
        self.flags[ply] = self.flags[ply] | CommChannel.MUTE
    end
		ChatService.CallHook(self, "OnPlayerMute", ply)
end

function CommChannel:RemoveMute(ply)
    if CommChannel.HasPlayer(self, ply) then
        self.flags[ply] = self.flags[ply] & ~CommChannel.MUTE
    end
		ChatService.CallHook(self, "OnPlayerUnmute", ply)
end


function CommChannel:CheckMute(ply)
    if self.flags[ply] ~= nil then return false end

    return self.flags[ply] & CommChannel.MUTE
end

function CommChannel:PlyCount()
    table.Count(self.players)
end

function CommChannel:AddInvite(ply, timeout)
    self.invites[ply] = true
    if timeout and timeout > 0 then 
			timer.Create(self:GetInviteID(), timeout, 1, function()
				self.invites[ply] = nil 
				ChatService.CallHook(self, "OnPlayerInviteExpire", ply)
			end)
    end
		ChatService.CallHook(self, "OnPlayerInvite", ply, timeout)
end


function CommChannel:RemoveInvite(ply)
  local timer_id = self:GetInviteID(ply)
  if not timer.Exists(timer_id) then
		return
  end
	timer.Remove(timer_id)
  self.invites[ply] = nil
	ChatService.CallHook(self, "OnPlayerInviteRemove", ply)
end

function CommChannel:HasInvite(ply)
  return self.invites[ply] == true
end

function CommChannel:SetName(name)
	self.name = name
end

function CommChannel:GetName()
	return self.name
end

function CommChannel:GetInviteID(ply)
	return "invite_ch_"..self.id.."_pl_"..ply.UserID()
end

function CommChannel:SetPlayerFlags(ply, flags)
	self.flags[ply] = flags
end
	
