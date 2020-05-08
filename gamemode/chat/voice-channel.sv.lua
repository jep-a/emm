function VoiceChannel:AddPlayer(ply, flags) 
    self.super.AddPlayer(self, ply, flags)

    for _, lst in pairs(self.players) do
       lst.canHear[ply] = flags ~= nil and not (flags & self.MUTE) or true
       ply.canHear[lst] = self.flags[lst] ~= nil and not (self.flags[lst] & self.MUTE) or true
    end
end

function VoiceChannel:RemovePlayer(ply)
    self.super.RemovePlayer(self, ply)

    self:Silence(ply)
    for _, lst in pairs(self.players) do
       ply.canHear[lst] = false
    end
end

function VoiceChannel:Mute(ply)
    self.super.Mute(self, ply)

    self:Silence(ply)
    self.flags[ply] = self.flags[ply] | self.MUTE
end

function VoiceChannel:RemoveMute(ply)
    self.super.Mute(self, ply)

    self:Silence(ply)
    self.flags[ply] = self.flags[ply] & ~self.MUTE
end

function VoiceChannel:Ban(ply)
    self.super.Ban(self, ply)

    self:RemovePlayer(ply)
end

--Internal fucntion
function VoiceChannel:Silence(ply, enable)
    for _,lst in pairs(self.players) do
        lst.canHear[ply] = enable and not enable or false
    end
end