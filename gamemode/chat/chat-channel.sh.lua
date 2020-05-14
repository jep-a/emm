ChatChannel = ChatChannel or Class.New()
ChatChannel.MUTED = 1   --0b0001
ChatChannel.OPERATOR = 1<<1   --0b0010

function ChatChannel:Init(id, host, private)
    self.id = id or 0
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
    table.insert(self.players,ply)
    self.flags[ply] = flags or 0
end

function ChatChannel:RemovePlayer(ply)
    table.remove(self.flags, ply)
    self.flags[ply] = nil
end

function ChatChannel:AddOperator(ply)
    self.flags[ply] = self.flags[ply] | ChatChannel.OPERATOR
end

function ChatChannel:RemoveOperator(ply)
    self.flags[ply] = self.flags[ply] & ~ChatChannel.OPERATOR
end

function ChatChannel:CheckOperator(ply)
    if self.flags[ply] ~= nil then return false end
    
    return self.flags[ply] & ChatChannel.MUTE
end

function ChatChannel:Ban(ply)
    self:RemovePlayer(ply)
    self.bans[ply] = true
end

function ChatChannel:RemoveBan(ply)
    self.bans[ply] = nil
end

function ChatChannel:CheckBan(ply)
    return self.bans[ply] ~= nil
end

function ChatChannel:Mute(ply)
    if ChatChannel.HasPlayer(self, ply) then
        self.flags[ply] = self.flags[ply] | ChatChannel.MUTE
    end
end

function ChatChannel:RemoveMute(ply)
    if ChatChannel.HasPlayer(self, ply) then
        self.flags[ply] = self.flags[ply] & ~ChatChannel.MUTE
    end
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
    if(timeout) then 
        timer.Create("chatinvite_ch"..self.id.."_pl"..ply.UserID(), timeout, 1, function()
           self.invites[ply] = nil 
        end)
    end
end

function ChatChannel:RemoveInvite(ply)
    local timer_id = "chatinvite_ch"..self.id.."_pl"..ply.UserID()
    if timer.Exists(timer_id) then
        timer.Remove(timer_id)
    end
    self.invites[ply] = nil
end

function ChatChannel:HasInvite(ply)
    return self.invites[ply] == true
end