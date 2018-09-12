LobbyUIService = LobbyUIService or {}


-- # Util

function LobbyUIService.SetLobbyListHeaderText(count)
	local text

	if count > 0 then
		text = count.." open "..(count == 1 and "lobby" or "lobbies")
	else
		text = "No open lobbies"
	end

	LobbyUIService.lobby_section.header:SetText(string.upper(text))
end

function LobbyUIService.LobbyHostText(ply)
	local text

	if IsLocalPlayer(ply) then
		text = "your lobby"
	else
		text = ply:GetName().."'s lobby"
	end

	return text
end


-- # Init

function LobbyUIService.Init()
	LobbyUIService.container = LobbyUIService.CreateContainer()
	LobbyUIService.new_lobby_section = LobbyUIService.container:Add(LobbyUIService.CreateNewLobbySection())
	LobbyUIService.prototype_list = LobbyUIService.new_lobby_section:Add(LobbyUIService.CreatePrototypeList())
	LobbyUIService.lobby_section = LobbyUIService.container:Add(LobbyUIService.CreateLobbySection())
	LobbyUIService.lobby_list = LobbyUIService.lobby_section:Add(LobbyUIService.CreateLobbyList())
	LobbyUIService.lobby_card_section = LobbyUIService.container:Add(LobbyUIService.CreateLobbyCardSection())

	for _, proto in pairs(MinigameService.prototypes) do
		LobbyUIService.prototype_list:Add(LobbyUIService.CreatePrototypeBar(proto))
	end

	for _, lobby in pairs(MinigameService.lobbies) do
		LobbyUIService.AddLobby(lobby)
	end

	LobbyUIService.SetLobbyListHeaderText(table.Count(MinigameService.lobbies))
end
hook.Add("ReceiveLobbies", "LobbyUIService.Init", LobbyUIService.Init)

function LobbyUIService.Reload()
	LobbyUIService.selected_lobby = nil
	LobbyUIService.container:Finish()
	LobbyUIService.Init()
end
hook.Add("OnReloaded", "LobbyUIService.Reload", LobbyUIService.Reload)

function LobbyUIService.Open()
	RememberCursorPosition()
	RestoreCursorPosition()

	if LobbyUIService.focused then
		LobbyUIService.UnFocus()
	end

	LobbyUIService.open = true

	gui.EnableScreenClicker(true)
	LobbyUIService.container.panel:SetMouseInputEnabled(true)
	LobbyUIService.container.panel:MoveToFront()
	LobbyUIService.container:AnimateAttribute("alpha", 255)
end

function LobbyUIService.Close()
	RememberCursorPosition()

	if not LobbyUIService.focused then
		LobbyUIService.open = false

		gui.EnableScreenClicker(false)
		LobbyUIService.container.panel:SetMouseInputEnabled(false)
		LobbyUIService.container.panel:MoveToBack()
		LobbyUIService.container:AnimateAttribute("alpha", 0)
	end
end

function GM:OnSpawnMenuOpen()
	LobbyUIService.Open()

	return true
end

function GM:OnSpawnMenuClose()
	LobbyUIService.Close()

	return true
end


-- # Hooks

function LobbyUIService.AddLobby(lobby)
	if LobbyUIService.container then
		LobbyUIService.lobby_list:Add(LobbyBar.New(lobby))

		if lobby:IsLocal() then
			LobbyUIService.SelectLobby(lobby)
		end

		local lobby_count = (table.Count(MinigameService.lobbies) + 1)

		LobbyUIService.SetLobbyListHeaderText(lobby_count)

		if lobby_count > 0 then
			LobbyUIService.lobby_list:AnimateState "contains_children"
		end
	end
end
hook.Add("LobbyInit", "LobbyUIService.AddLobby", LobbyUIService.AddLobby)

function LobbyUIService.FinishLobby(lobby)
	if LobbyUIService.container then
		if lobby.bar_element then
			lobby.bar_element:Finish()
		end

		if lobby.card_element then
			lobby.card_element:Finish()
		end

		local lobby_count = table.Count(MinigameService.lobbies)

		LobbyUIService.SetLobbyListHeaderText(lobby_count)

		if 1 > lobby_count then
			LobbyUIService.lobby_list:RevertState()
		end
	end
end
hook.Add("LobbyFinish", "LobbyUIService.FinishLobby", LobbyUIService.FinishLobby)

function LobbyUIService.SetLobbyHost(lobby, ply)
	if lobby.bar_element then
		lobby.bar_element.host:SetText(ProperPlayerName(ply))
	end

	if lobby.card_element then
		lobby.card_element.header:SetText(string.upper(LobbyUIService.LobbyHostText(ply)))
	end
end
hook.Add("LobbyHostChange", "LobbyUIService.SetLobbyHost", LobbyUIService.SetLobbyHost)

function LobbyUIService.AddLobbyPlayer(lobby, ply)
	local is_local_ply = IsLocalPlayer(ply)

	if lobby.bar_element then
		if is_local_ply then
			lobby.bar_element.pulse:AnimateAttribute("alpha", 255)
		end

		lobby.bar_element.players:SetText(#lobby.players)
	end

	if lobby.card_element then
		ply.lobby_card_element = lobby.card_element.players:Add(PlayerBar.New(ply))
		ply.lobby_card_element:AnimateStart()

		if is_local_ply then
			lobby.card_element.actions:AnimateState "leave"
		end
	end
end
hook.Add("LobbyPlayerJoin", "LobbyUIService.AddLobbyPlayer", LobbyUIService.AddLobbyPlayer)

function LobbyUIService.RemoveLobbyPlayer(lobby, ply)
	local is_local_ply = IsLocalPlayer(ply)

	if lobby.bar_element then
		if is_local_ply then
			lobby.bar_element.pulse:AnimateAttribute("alpha", 0)
		end

		lobby.bar_element.players:SetText(#lobby.players - 1)
	end

	if lobby.card_element then
		if ply.lobby_card_element then
			ply.lobby_card_element:Finish()
		end

		if is_local_ply then
			lobby.card_element.actions:RevertState()
		end
	end
end
hook.Add("LobbyPlayerLeave", "LobbyUIService.RemoveLobbyPlayer", LobbyUIService.RemoveLobbyPlayer)

function LobbyUIService.SelectLobby(lobby)
	if lobby ~= LobbyUIService.selected_lobby then
		if LobbyUIService.selected_lobby then
			LobbyUIService.UnSelectLobby()
		end

		if lobby.bar_element then
			lobby.bar_element:AnimateState "hover"
		end

		LobbyUIService.selected_lobby = lobby
		LobbyUIService.lobby_card_section:Add(LobbyCard.New(lobby))
	end
end

function LobbyUIService.UnSelectLobby()
	local lobby = LobbyUIService.selected_lobby

	if lobby.bar_element then
		lobby.bar_element:RevertState()
	end

	if lobby.card_element then
		lobby.card_element:Finish()
	end

	LobbyUIService.selected_lobby = nil
end

function LobbyUIService.Focus()
	LobbyUIService.focused = true
	LobbyUIService.container.panel:MakePopup()
end

function LobbyUIService.UnFocus()
	LobbyUIService.focused = false
	LobbyUIService.container.panel:SetKeyboardInputEnabled(false)
end

function LobbyUIService.FocusTextEntry(element)
	if element.panel:HasParent(LobbyUIService.container.panel) then
		LobbyUIService.Focus()
	end
end
hook.Add("TextEntryFocus", "LobbyUIService.FocusTextEntry", LobbyUIService.FocusTextEntry)

function LobbyUIService.UnFocusTextEntry(element)
	if element.panel:HasParent(LobbyUIService.container.panel) then
		LobbyUIService.UnFocus()
	end
end
hook.Add("TextEntryUnFocus", "LobbyUIService.UnFocusTextEntry", LobbyUIService.UnFocusTextEntry)

function LobbyUIService.MousePressed(panel)
	if 
		panel == LobbyUIService.container.panel or
		panel == LobbyUIService.new_lobby_section.panel or
		panel == LobbyUIService.lobby_section.panel or
		panel == LobbyUIService.lobby_card_section.panel
	then
		if LobbyUIService.selected_lobby then
			LobbyUIService.UnSelectLobby()
		end
	end
end
hook.Add("VGUIMousePressed", "LobbyUIService.MousePressed", LobbyUIService.MousePressed)