ChatChannel = ChatChannel or Class.New()

function ChatChannel:Init()
    self.id = 0
    self.voice = false
    self.host = nil
    self.private = false
    -- We can search through flags 
    -- to find out which players are
    -- in a lobby
    -- self.players = {}
    self.flags = {}
end

function ChatChannel:GetPlayers()
    return self.players
end

function ChatChannel:AddPlayer(ply)
    table.insert(self.players, ply)
end

function ChatChannel:RemovePlayer(ply)
    table.RemoveByValue(self.players, ply)
end

function ChatChannel:AddBan(ply)
    table.insert(self.bans, ply)
end

function ChatChannel:RemoveBan(ply)
    table.RemoveByValue(self.bans, ply)
end

function ChatChannel:AddMute(ply, time)
    table.insert(self.mute, ply)
end

function ChatChannel:RemoveMute(ply)
    table.RemoveByValue(self.mute, ply)
end