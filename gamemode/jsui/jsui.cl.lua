JSUI = JSUI or {}


-- # Util

function JSUI.Test()
	JSUI.html:Call([[
		for (i = 0; i < 1000; i++) {
			setTimeout(function () {
				console.luaPrint(i);

				app.state.removeMinigameInstance(1);
				app.state.addMinigameInstance({
					id: 1,
					minigamePrototype: 1,
					host: 1,
					players: [1]
				});
			}, i * 100);
		};
	]])
end

function JSUI.Reload()
	if IsValid(JSUI.container) then
		JSUI.container:Remove()
	end

	JSUI.Init()

	local ply = LocalPlayer()
	if ply.minigame_lobby then
		JSUI.html:Call([[
			app.store.setCurrentMinigameInstance(]]..ply.minigame_lobby.id..[[);
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
		local sanitized_proto = {}
		sanitized_proto.id = proto.id
		sanitized_proto.key = string.lower(proto.key)
		sanitized_proto.name = proto.name
		sanitized_proto.color = string.format([[#%02x%02x%02x]], proto.color.r, proto.color.g, proto.color.b)
		sanitized_protos[tostring(proto.id)] = sanitized_proto
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
	JSUI.html:RunJavascript([[
		var XMM_ENV = true;
		var xmmLua = {};

		var currentPlayerId = ]]..LocalPlayer():EntIndex()..[[;
		var initialPlayersJson = ]]..util.TableToJSON(JSUI.SanitizedPlayers())..[[;
		var initialMinigamePrototypesJson = ]]..util.TableToJSON(JSUI.SanitizedPrototypes())..[[;
		var initialMinigameInstancesJson = ]]..util.TableToJSON(JSUI.SanitizedLobbies())..[[;
	]])
	JSUI.html:AddFunction("console", "luaPrint", print)
	JSUI.html:AddFunction("console", "debug", print)
	JSUI.html:AddFunction("console", "error", print)
	JSUI.html:AddFunction("console", "warn", print)
	JSUI.html:AddFunction("xmmLua", "showPanel", function (bool)
		JSUI.html:SetAlpha(bool and 255 or 0)
		JSUI.html:SetPos(0, bool and 0 or -ScrH())
	end)
	JSUI.html:AddFunction("xmmLua", "requestMinigameInstanceCreate", function (proto_id)
		MinigameService.RequestCreateLobby(MinigameService.Prototype(proto_id))
	end)
	JSUI.html:AddFunction("xmmLua", "requestMinigameInstanceJoin", function (lobby_id)
		MinigameService.RequestJoinLobby(MinigameService.lobbies[lobby_id])
	end)
	JSUI.html:AddFunction("xmmLua", "requestMinigameInstanceLeave", function (lobby_id)
		MinigameService.RequestLeaveLobby(MinigameService.lobbies[lobby_id])
	end)
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
	JSUI.html:OpenURL "http://spektre.me/xmm/ui"
end
hook.Add("ReceiveLobbies", "JSUI.Init", JSUI.Init)


-- # Players

function JSUI.AddPlayer(data)
	if JSUI.html then
		JSUI.html:Call([[
			app.store.addPlayer({
				id: ]]..(data.index + 1)..[[,
				steamId: ']]..util.SteamIDTo64(data.networkid)..[[',
				name: ']]..string.JavascriptSafe(data.name)..[['
			});
		]])
	end
end
gameevent.Listen "player_info"
hook.Add("player_info", "JSUI.AddPlayer", JSUI.AddPlayer)

function JSUI.SetPlayerName(data)
	JSUI.html:Call([[
		app.store.setPlayerName(]]..Player(data.userid):EntIndex()..[[, ']]..string.JavascriptSafe(data.newname)..[[');
	]])
end
gameevent.Listen("player_changename")
hook.Add("player_changename", "JSUI.SetPlayerName", JSUI.SetPlayerName)

function JSUI.RemovePlayer(ply)
	JSUI.html:Call([[
		app.store.removePlayer(]]..ply:EntIndex()..[[);
	]])
end


-- # Minigames

function JSUI.AddLobby(lobby)
	if JSUI.html then
		JSUI.html:Call([[
			app.store.addMinigameInstance(]]..util.TableToJSON(lobby:GetSanitized())..[[);
		]])

		if lobby.host == LocalPlayer() then
			JSUI.html:Call([[
				app.store.setCurrentMinigameInstance(]]..lobby.id..[[);
			]])
		end
	end
end

function JSUI.RemoveLobby(lobby)
	if JSUI.html then
		JSUI.html:Call([[
			app.store.removeMinigameInstance(]]..lobby.id..[[);
		]])
	end
end

function JSUI.SetLobbyHost(lobby, ply)
	if JSUI.html then
		JSUI.html:Call([[
			app.store.setMinigameInstanceHost(]]..lobby.id..[[, ]]..ply:EntIndex()..[[);
		]])
	end
end

function JSUI.AddLobbyPlayer(lobby, ply)
	if JSUI.html then
		JSUI.html:Call([[
			app.store.addMinigameInstancePlayer(]]..lobby.id..[[, ]]..ply:EntIndex()..[[);
		]])

		if ply == LocalPlayer() then
			JSUI.html:Call([[
				app.store.setCurrentMinigameInstance(]]..lobby.id..[[);
			]])
		end
	end
end

function JSUI.RemoveLobbyPlayer(lobby, ply)
	if JSUI.html then
		JSUI.html:Call([[
			app.store.removeMinigameInstancePlayer(]]..lobby.id..[[, ]]..ply:EntIndex()..[[);
		]])

		if ply == LocalPlayer() then
			JSUI.html:Call([[
				app.store.setCurrentMinigameInstance(undefined);
			]])
		end
	end
end


-- # Toggling

function JSUI.Open()
	RestoreCursorPosition()
	gui.EnableScreenClicker(true)

	JSUI.container:MoveToFront()
	JSUI.html:Call([[
		app.show();
	]])

	return true
end
-- hook.Add("OnSpawnMenuOpen", JSUI.Open)

function JSUI.Close()
	RememberCursorPosition()
	gui.EnableScreenClicker(false)

	JSUI.container:MoveToBack()
	JSUI.html:Call([[
		app.hide();
	]])

	return true
end
-- hook.Add("OnSpawnMenuOpen", JSUI.Close)

function GM:OnSpawnMenuOpen()
	JSUI.Open()
end

function GM:OnSpawnMenuClose()
	JSUI.Close()
end
