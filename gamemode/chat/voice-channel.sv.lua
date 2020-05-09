function VoiceChannel:AddPlayer(ply, flags)
    VoiceChannel.super.AddPlayer(self, ply, flags)

    for _, lst in pairs(self.players) do
       lst.canHear[ply] = flags ~= nil and not (flags & self.MUTE) or true
       ply.canHear[lst] = self.flags[lst] ~= nil and not (self.flags[lst] & self.MUTE) or true
    end
end

function VoiceChannel:RemovePlayer(ply)
    VoiceChannel.super.RemovePlayer(self, ply)

    self:Silence(ply)
    for _, lst in pairs(self.players) do
       ply.canHear[lst] = false
    end
end

function VoiceChannel:Mute(ply)
    VoiceChannel.super.Mute(self, ply)

    self.flags[ply] = self.flags[ply] | self.MUTE
    self:Silence(ply)
end

function VoiceChannel:RemoveMute(ply)
    VoiceChannel.super.RemoveMute(self, ply)

    self.flags[ply] = self.flags[ply] & ~self.MUTE
    if self:HasPlayer(ply) then
        self:Silence(ply, false)
    end
end

--Internal function
function VoiceChannel:Silence(ply, enable)
    for _,lst in pairs(self.players) do
        lst.can_hear[ply] = enable and not enable or false
    end
end
