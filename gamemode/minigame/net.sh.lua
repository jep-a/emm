MinigameNetService = MinigameNetService or {}

NetService.type_readers.minigame_prototype = function ()
	return MinigameService.Prototype(NetService.ReadID())
end

NetService.type_readers.minigame_lobby = function ()
	return MinigameService.lobbies[NetService.ReadID()]
end

NetService.type_writers.minigame_prototype = function (proto)
	NetService.WriteID(proto.id)
end

NetService.type_writers.minigame_lobby = function (lobby)
	NetService.WriteID(lobby.id)
end

NetService.CreateSchema("Lobby", {"id", "minigame_prototype", "entity"})
NetService.CreateSchema("LobbyFinish", {"minigame_lobby"})
NetService.CreateSchema("LobbyHost", {"minigame_lobby", "entity"})
NetService.CreateSchema("LobbyState", {"minigame_lobby", "id", "float"})
NetService.CreateSchema("LobbyPlayer", {"minigame_lobby", "entity"})
NetService.CreateSchema("LobbyPlayerLeave", {"minigame_lobby", "entity"})
NetService.CreateSchema("LobbyEntity", {"minigame_lobby", "id"})
NetService.CreateSchema("LobbyEntityRemove", {"minigame_lobby", "entity"})
NetService.CreateSchema("LobbyHost", {"minigame_lobby", "entity"})
NetService.CreateUpstreamSchema "RequestLobbies"
NetService.CreateUpstreamSchema("RequestLobby", {"minigame_prototype"})
NetService.CreateUpstreamSchema "RequestLobbyRestart"
NetService.CreateUpstreamSchema "RequestLobbyFinish"
NetService.CreateUpstreamSchema("RequestLobbyJoin", {"minigame_lobby"})
NetService.CreateUpstreamSchema "RequestLobbyLeave"

hook.Add("LoadMinigamePrototypes", "CreateMinigameHookSchemas", function ()
	hook.Run "CreateMinigameHookSchemas"
end)