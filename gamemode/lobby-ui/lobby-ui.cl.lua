LobbyUIService = LobbyUIService or {}

function LobbyUIService.Init()
	LobbyUIService.container = Element.New {
		width_percent = 1,
		height_percent = 1,
		padding = 64,
		child_margin = MARGIN * 4,
		alpha = 0
	}

	LobbyUIService.new_lobby_section = LobbyUIService.container:Add(Element.New {
		layout_direction = DIRECTION_COLUMN,
		width = 256,
		height_percent = 1,
		child_margin = MARGIN * 4,
		LobbyUIService.CreateHeader "Make a new lobby"
	})

	LobbyUIService.prototype_list = LobbyUIService.new_lobby_section:Add(Element.New {
		layout_direction = DIRECTION_COLUMN,
		fit_y = true,
		width_percent = 1,
		background_color = COLOR_GRAY
	})

	LobbyUIService.lobby_section = LobbyUIService.container:Add(Element.New {
		width_percent = 0.25,
		height_percent = 1,
		child_margin = MARGIN * 4,
		header = LobbyUIService.CreateHeader("No open lobbies", true)
	})

	LobbyUIService.lobby_list = LobbyUIService.lobby_section:Add(LobbyUIService.CreateLobbyList())

	LobbyUIService.lobby_card_section = LobbyUIService.container:Add(Element.New {
		layout_direction = DIRECTION_COLUMN,
		width = 256,
		height_percent = 1,
		child_margin = MARGIN * 4
	})

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
	LobbyUIService.open = true

	RestoreCursorPosition()
	gui.EnableScreenClicker(true)
	LobbyUIService.container.panel:MoveToFront()
	LobbyUIService.container:AnimateAttribute("alpha", 255)

	return true
end

function LobbyUIService.Close()
	LobbyUIService.open = false

	RememberCursorPosition()
	gui.EnableScreenClicker(false)
	LobbyUIService.container.panel:MoveToBack()
	LobbyUIService.container:AnimateAttribute("alpha", 0)

	return true
end

function GM:OnSpawnMenuOpen()
	LobbyUIService.Open()
end

function GM:OnSpawnMenuClose()
	LobbyUIService.Close()
end

function LobbyUIService.SetLobbyListHeaderText(count)
	local text

	if count > 0 then
		text = count.." open "..(count == 1 and "lobby" or "lobbies")
	else
		text = "No open lobbies"
	end

	LobbyUIService.lobby_section.header:SetText(string.upper(text))
end

function LobbyUIService.ProperPlayerName(ply)
	local name

	if IsLocalPlayer(ply) then
		name = "you"
	else
		name = ply:GetName()
	end

	return name
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
		lobby.bar_element.host:SetText(LobbyUIService.ProperPlayerName(ply))
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

function LobbyUIService.Unfocus(panel)
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
hook.Add("VGUIMousePressed", "LobbyUIService.Unfocus", LobbyUIService.Unfocus)