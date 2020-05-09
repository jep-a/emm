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

    if host ~= nil then
        self:AddPlayer(host)
        self.flags[host] = ChatChannel.OPERATOR
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
        self.flags[ply] = self.flags[ply] & (~ChatChannel.MUTE)
    end
end

function ChatChannel:CheckMute(ply)
    return self.flags[ply] & ChatChannel.MUTE
end

function ChatChannel:PlyCount()
    table.Count(self.players)
end

