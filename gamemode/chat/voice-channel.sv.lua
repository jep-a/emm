function VoiceChannel:AddPlayer(ply, flags) 
    self.super.AddPlayer(self, ply, flags)

    for _, lst in pairs(self.players) do
       lst.canHear[ply] = flags ~= nil and not (flags & self.MUTE) or true
       ply.canHear[lst] = self.flags[lst] ~= nil and not (self.flags[lst] & self.MUTE) or true
    end
end

function VoiceChannel:RemovePlayer(ply, flags) 
    self.super.RemovePlayer(self, ply, flags)

    for _, lst in pairs(self.players) do
       lst.canHear[ply] = false
       ply.canHear[lst] = false
    end
end

function VoiceChannel:Mute(ply)
    self.super.Mute(self, ply)

    self.flags[ply] = self.flags[ply] | self.MUTE
    for _, lst in pairs(self.players) do
        lst.canHear[ply] = false
    end
end

function VoiceChannel:RemoveMute(ply)
    self.super.Mute(self, ply)

    self.flags[ply] = self.flags[ply] & ~self.MUTE
    for _, lst in pairs(self.players) do
        lst.canHear[ply] = false
    end
end