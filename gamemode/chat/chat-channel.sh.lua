ChatChannel = ChatChannel or Class.New()
ChatChannel.MUTED = 1   --0b0001
ChatChannel.OP = 1<<1   --0b0010

function ChatChannel:Init(id, host, private)
    self.id = id
    self.host = host
    self.private = private
    self.players = {}
    self.bans = {}
end

function ChatChannel:GetPlayers()
    return self.players
end

function ChatChannel:HasPlayer(ply)
    return this.players[ply] ~= nil
end

function ChatChannel:AddPlayer(ply, flags)
    self.players[ply] = flags or 0
end

function ChatChannel:RemovePlayer(ply)
    self.players[ply] = nil
end

function ChatChannel:Ban(ply)
    self.bans[ply] = true
end

function ChatChannel:RemoveBan(ply)
    self.bans[ply] = nil
end

function ChatChannel:CheckBan(ply)
    return self.bans[ply] ~= nil
end

function ChatChannel:Mute(ply)
    if self:HasPlayer(ply) then
        self.players[ply] = self.players[ply] | ChatChannel.MUTE
    end
end

function ChatChannel:RemoveMute(ply)
    if self:HasPlayer(ply) then
        self.players[ply] = self.players[ply] & (~ChatChannel.MUTE)
    end
end

function ChatChannel:CheckMute(ply)
    return self.players[ply] & ChatChannel.MUTE
end

function ChatChannel:PlyCount()
    table.Count(self)
end

