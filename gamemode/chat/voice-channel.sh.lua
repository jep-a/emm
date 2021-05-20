VoiceChannel = VoiceChannel or Class.New(CommChannel)

function VoiceChannel:Init(id, host, private)
    VoiceChannel.super.Init(self, id, host, private)
end

function VoiceChannel:AddPlayer(ply, flags)
  VoiceChannel.super.AddPlayer(self, ply, flags)

  if ply.voice_channel then
      ply.voice_channel:RemovePlayer(ply)
  end

	ply.voice_channel = self

	if SERVER then
		for _, lst in pairs(self.players) do
			lst.can_hear[ply] = flags ~= nil and not (flags & self.MUTE) or true
			ply.can_hear[lst] = self.flags[lst] ~= nil and not (self.flags[lst] & self.MUTE) or true
		end
	end
end

function VoiceChannel:GetSerializeable()
	local to_serialize = {}
	VoiceChannel.super.GetSerializeable(self, to_serialize)

	--somehow indicate voice channel here

end
