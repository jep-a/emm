JSUI = JSUI or {}


-- # Util

function JSUI.Test()
	JSUI.html:Call [[
		for (i = 0; i < 1000; i++) {
			setTimeout(function () {
				console.info(i);

				window.app.store.removeLobby(1);
				window.app.store.lobbies.add({
					id: 1,
					prototype: 2,
					host: 1,
					players: [1]
				});
			}, i * 100);
		};
	]]
end

function JSUI.Reload()
	if IsValid(JSUI.container) then
		JSUI.container:Remove()
	end

	JSUI.Init()

	local ply = LocalPlayer()
	if ply.lobby then
		JSUI.html:Call([[
			window.app.store.lobbies.setCurrent(]]..ply.lobby.id..[[);
		]])
	end
end

function JSUI.SanitizedPlayers()
	local sanitized_plys = {}

	for _, ply in pairs(player.GetAll()) do
		sanitized_plys[tostring(ply:EntIndex())] = ply:GetSanitized()
	end

	return sanitized_plys
end

function JSUI.SanitizedPrototypes()
	local sanitized_protos = {}

	for _, proto in pairs(MinigameService.prototypes) do
		if proto.display then
			local sanitized_proto = {}

			sanitized_proto.id = math.Round(proto.id)
			sanitized_proto.key = string.lower(proto.key)
			sanitized_proto.name = proto.name
			sanitized_proto.color = string.format([[#%02x%02x%02x]], proto.color.r, proto.color.g, proto.color.b)
			sanitized_proto.modifiables = proto.modifiable_vars

			sanitized_proto.playerClasses = {}

			for k, ply_class in pairs(proto.player_classes) do
				table.insert(sanitized_proto.playerClasses, {ply_class.name, {color = ply_class.color}})
			end

			sanitized_protos[tostring(proto.id)] = sanitized_proto
		end
	end

	return sanitized_protos
end

function JSUI.SanitizedLobbies()
	local sanitized_lobbies = {}

	for k, lobby in pairs(MinigameService.lobbies) do
		sanitized_lobbies[tostring(k)] = lobby:GetSanitized()
	end

	return sanitized_lobbies
end


-- # Init

function JSUI.InitJavaScript()
	JSUI.html:AddFunction("console", "info", print)
	JSUI.html:AddFunction("console", "debug", print)
	JSUI.html:AddFunction("console", "error", print)
	JSUI.html:AddFunction("console", "warn", print)
	JSUI.html:AddFunction("EMM", "togglePanel", function (bool)
		JSUI.html:SetAlpha(bool and 255 or 0)
		JSUI.html:SetPos(0, bool and 0 or -ScrH())
	end)
	JSUI.html:AddFunction("EMM", "createLobby", function (id)
		MinigameService.RequestCreateLobby(MinigameService.Prototype(id))
	end)
	JSUI.html:AddFunction("EMM", "joinLobby", function (id)
		MinigameService.RequestJoinLobby(MinigameService.lobbies[id])
	end)
	JSUI.html:AddFunction("EMM", "leaveLobby", function ()
		MinigameService.RequestLeaveLobby()
	end)
	JSUI.html:AddFunction("EMM", "switchLobby", function (id)
		if id == LocalPlayer().lobby.id then
			MinigameService.RequestLeaveLobby()
		else
			MinigameService.RequestJoinLobby(MinigameService.lobbies[id])
		end
	end)
	JSUI.html:RunJavascript([[
		window.emmStore = {
			clientID: ]]..LocalPlayer():EntIndex()..[[,
			players: ]]..util.TableToJSON(JSUI.SanitizedPlayers())..[[,
			prototypes: ]]..util.TableToJSON(JSUI.SanitizedPrototypes())..[[,
			lobbies: ]]..util.TableToJSON(JSUI.SanitizedLobbies())..[[
		}
	]])
end

function JSUI.Init()
	JSUI.container = vgui.Create "EditablePanel"
	JSUI.container:SetMouseInputEnabled(true)
	JSUI.container:SetSize(ScrW(), ScrH())

	JSUI.html = vgui.Create("DHTML", JSUI.container)
	JSUI.html:SetScrollbars(false)
	JSUI.html:SetSize(ScrW(), ScrH())
	JSUI.html:SetPos(0, -ScrH())
	JSUI.html:SetAlpha(255)

	JSUI.InitJavaScript()
	JSUI.html:OpenURL "http://emm-jsui.jep.sh/lobby-settings"
end
hook.Add("ReceiveLobbies", "JSUI.Init", JSUI.Init)


-- # Players

function JSUI.AddPlayer(data)
	if JSUI.html then
		JSUI.html:Call([[
			window.app.store.players.add({
				id: ]]..(data.index + 1)..[[,
				steamID: ']]..util.SteamIDTo64(data.networkid)..[[',
				name: ']]..string.JavascriptSafe(data.name)..[['
			})
		]])
	end
end
gameevent.Listen "player_info"
hook.Add("player_info", "JSUI.AddPlayer", JSUI.AddPlayer)

function JSUI.SetPlayerName(data)
	JSUI.html:Call([[window.app.store.players.setName(]]..Player(data.userid):EntIndex()..[[, ']]..string.JavascriptSafe(data.newname)..[[')]])
end
gameevent.Listen "player_changename"
hook.Add("player_changename", "JSUI.SetPlayerName", JSUI.SetPlayerName)

function JSUI.RemovePlayer(ply)
	JSUI.html:Call([[window.app.store.players.remove(]]..ply:EntIndex()..[[)]])
end
hook.Add("PlayerDisconnected", "JSUI.RemoveDisconnectedPlayer", function (ply)
	JSUI.RemovePlayer(ply)
end)


-- # Minigames

function JSUI.AddLobby(lobby)
	if JSUI.html then
		JSUI.html:Call([[window.app.store.lobbies.add(]]..util.TableToJSON(lobby:GetSanitized())..[[)]])
	end
end
hook.Add("CreateLobby", "JSUI.AddLobby", JSUI.AddLobby)

function JSUI.RemoveLobby(lobby)
	if JSUI.html then
		JSUI.html:Call([[window.app.store.lobbies.remove(]]..lobby.id..[[)]])
	end
end
hook.Add("RemoveLobby", "JSUI.RemoveLobby", JSUI.RemoveLobby)

function JSUI.SetLobbyHost(lobby, ply)
	if JSUI.html then
		JSUI.html:Call([[window.app.store.lobbies.setHost(]]..lobby.id..[[, ]]..ply:EntIndex()..[[)]])
	end
end
hook.Add("LobbySetHost", "JSUI.SetLobbyHost", JSUI.SetLobbyHost)

function JSUI.AddLobbyPlayer(lobby, ply)
	if JSUI.html then
		JSUI.html:Call([[window.app.store.lobbies.addPlayer(]]..lobby.id..[[, ]]..ply:EntIndex()..[[)]])
	end
end
hook.Add("LobbyAddPlayer", "JSUI.AddLobbyPlayer", JSUI.AddLobbyPlayer)

function JSUI.RemoveLobbyPlayer(lobby, ply)
	if JSUI.html then
		JSUI.html:Call([[window.app.store.lobbies.removePlayer(]]..lobby.id..[[, ]]..ply:EntIndex()..[[)]])
	end
end
hook.Add("LobbyRemovePlayer", "JSUI.RemoveLobbyPlayer", JSUI.RemoveLobbyPlayer)


-- # Toggling

function JSUI.Open()
	RestoreCursorPosition()
	gui.EnableScreenClicker(true)
	JSUI.container:MoveToFront()
	JSUI.html:Call [[window.app.show()]]
	return true
end
-- hook.Add("OnSpawnMenuOpen", JSUI.Open)

function JSUI.Close()
	RememberCursorPosition()
	gui.EnableScreenClicker(false)
	JSUI.container:MoveToBack()
	JSUI.html:Call [[window.app.hide()]]
	return true
end
-- hook.Add("OnSpawnMenuOpen", JSUI.Close)

function GM:OnSpawnMenuOpen()
	JSUI.Open()
end

function GM:OnSpawnMenuClose()
	JSUI.Close()
end
