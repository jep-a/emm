function VoiceChannel:AddPlayer(ply, flags)
    VoiceChannel.super.AddPlayer(self, ply, flags)

    if ply.voice_channel then
        ply.voice_channel:RemovePlayer(ply)
    end

    ply.voice_channel = self
end