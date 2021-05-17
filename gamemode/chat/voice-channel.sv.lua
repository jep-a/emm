

function VoiceChannel:RemovePlayer(ply)
    VoiceChannel.super.RemovePlayer(self, ply)

    self:Silence(ply)
    for _, lst in pairs(self.players) do
       ply.can_hear[lst] = false
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

--Internal functions
function VoiceChannel:Silence(ply, enable)
    for _,listener in pairs(self.players) do
        listener.can_hear[ply] = enable and not enable or false
    end
end
