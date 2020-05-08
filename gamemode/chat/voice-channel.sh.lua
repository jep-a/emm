VoiceChannel = VoiceChannel or Class.New(ChatChannel)

function VoiceChannel:Init(id, host, private)  
    self.super.Init(self, id, host, private)
end