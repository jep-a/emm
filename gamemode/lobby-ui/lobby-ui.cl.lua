LobbyUIService = LobbyUIService or {}


-- # Util

function LobbyUIService.SmallScreen()
	return 1600 > ScrW()
end

function LobbyUIService.HellaSmallScreen()
	return 800 > ScrW()
end

function LobbyUIService.SetLobbyListHeaderText(count)
	local text

	if count > 0 then
		text = count.." open "..(count == 1 and "lobby" or "lobbies")
	else
		text = "No open lobbies"
	end

	LobbyUIService.lobby_section.header:SetText(text)
end

function LobbyUIService.LobbyHostText(ply)
	local text

	if IsLocalPlayer(ply) then
		text = "Your lobby"
	else
		text = ply:GetName().."'s lobby"
	end

	return text
end


-- # Init

function LobbyUIService.Init()
	LobbyUIService.container = LobbyUIService.CreateContainer()
	LobbyUIService.new_lobby_section = LobbyUIService.container:AddInner(LobbyUIService.CreateNewLobbySection())
	LobbyUIService.prototype_list = LobbyUIService.new_lobby_section:Add(LobbyUIService.CreatePrototypeList())
	LobbyUIService.lobby_section = LobbyUIService.container:AddInner(LobbyUIService.CreateLobbySection())
	LobbyUIService.lobby_list = LobbyUIService.lobby_section:Add(LobbyUIService.CreateLobbyList())
	LobbyUIService.lobby_card_section = LobbyUIService.container:AddInner(LobbyUIService.CreateLobbyCardSection())
	LobbyUIService.viewing_settings = false

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
	hook.Run "OnLobbyUIOpen"
end

function LobbyUIService.Close()
	RememberCursorPosition()

	if not LobbyUIService.focused then
		LobbyUIService.open = false

		gui.EnableScreenClicker(false)
		LobbyUIService.container.panel:SetMouseInputEnabled(false)
		LobbyUIService.container.panel:MoveToBack()
		LobbyUIService.container:AnimateAttribute("alpha", 0)

		if ListSelector.focused and ListSelector.focused:HasParent(LobbyUIService.container) then
			ListSelector.focused:FinishList()
		end
	
		hook.Run "OnLobbyUIClose"
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

		chat.AddText(lobby.prototype.color, lobby.host:GetName(), " has made a ", lobby.prototype.name, " lobby")
	end
end
hook.Add("LobbyInit", "LobbyUIService.AddLobby", LobbyUIService.AddLobby)

function LobbyUIService.FinishLobby(lobby)
	if LobbyUIService.container then
		if lobby.bar_element then
			lobby.bar_element:Finish()
		end

		if lobby == LobbyUIService.selected_lobby then
			LobbyUIService.UnSelectLobby()
		end

		local lobby_count = table.Count(MinigameService.lobbies)

		LobbyUIService.SetLobbyListHeaderText(lobby_count)

		if lobby_count == 0 then
			LobbyUIService.lobby_list:RevertState()
		end
	end
end
hook.Add("LobbyFinish", "LobbyUIService.FinishLobby", LobbyUIService.FinishLobby)

function LobbyUIService.SetLobbyHost(lobby, ply)
	if lobby.bar_element then
		lobby.bar_element.host:SetText(ProperPlayerName(ply))
	end

	if lobby == LobbyUIService.selected_lobby then
		lobby.card_element.header:SetText(string.upper(LobbyUIService.LobbyHostText(ply)))

		local settings = LobbyUIService.lobby_card_container.settings

		if IsLocalPlayer(ply) then
			lobby.card_element:AddHostActions()
			settings:Enable()
		else
			lobby.card_element:FinishHostActions()
			settings:Disable()
		end
	end

	if lobby:IsLocal() then
		chat.AddText(lobby.prototype.color, ply:GetName(), " has inherited host")
	end
end
hook.Add("LobbyHostChange", "LobbyUIService.SetLobbyHost", LobbyUIService.SetLobbyHost)

function LobbyUIService.RefreshSettings(lobby, settings)
	if lobby == LobbyUIService.selected_lobby then
		LobbyUIService.lobby_card_container.settings:Refresh(settings)
	end
end
hook.Add("LobbySettingsChange", "LobbyUIService.RefreshSettings", LobbyUIService.RefreshSettings)

function LobbyUIService.AddLobbyPlayer(lobby, ply)
	local is_local_ply = IsLocalPlayer(ply)

	if lobby.bar_element then
		if is_local_ply then
			lobby.bar_element.pulse:AnimateAttribute("alpha", 255)
		end

		lobby.bar_element.players:SetText(#lobby.players)
	end

	if lobby == LobbyUIService.selected_lobby then
		ply.lobby_card_element = lobby.card_element.players:Add(PlayerBar.New(ply))
		ply.lobby_card_element:AnimateStart()

		if is_local_ply then
			lobby.card_element.switch:AnimateState("leave", ANIMATION_DURATION * 2)
		end
	end

	chat.AddText(lobby.prototype.color, ply:GetName(), " has joined ", lobby.host:GetName(), "'s lobby")
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

	if lobby == LobbyUIService.selected_lobby then
		if ply.lobby_card_element then
			ply.lobby_card_element:Finish()
		end

		if is_local_ply then
			lobby.card_element.switch:RevertState(ANIMATION_DURATION * 2)
		end
	end
end
hook.Add("LobbyPlayerLeave", "LobbyUIService.RemoveLobbyPlayer", LobbyUIService.RemoveLobbyPlayer)

function LobbyUIService.SelectLobby(lobby)
	if lobby and lobby ~= LobbyUIService.selected_lobby then
		local small_screen = LobbyUIService.SmallScreen()

		if LobbyUIService.selected_lobby then
			LobbyUIService.UnSelectLobby()
		end

		if small_screen then
			LobbyUIService.container.inner_container:AnimateAttribute("offset_x", 168, ANIMATION_DURATION * 4)
		end

		LobbyUIService.lobby_card_section:AnimateAttribute("layout_crop_x", 0, ANIMATION_DURATION * 4)
		
		if lobby.bar_element then
			lobby.bar_element:AnimateState "hover"
		end
		
		LobbyUIService.selected_lobby = lobby
		LobbyUIService.lobby_card_container = LobbyUIService.lobby_card_section:Add(LobbyCardContainer.New(lobby))

		if small_screen then
			LobbyUIService.lobby_card_container.settings:AnimateAttribute("alpha", HALF_ALPHA)
		end
	end
end

function LobbyUIService.UnSelectLobby()
	local lobby = LobbyUIService.selected_lobby

	if lobby then
		local small_screen = LobbyUIService.SmallScreen()
	
		if lobby.bar_element then
			lobby.bar_element:RevertState()
		end

		if small_screen then
			LobbyUIService.container.inner_container:AnimateAttribute("offset_x", 0, ANIMATION_DURATION * 4)
		end
	
		LobbyUIService.lobby_card_section:AnimateAttribute("layout_crop_x", 1, ANIMATION_DURATION * 4)

		if lobby == LobbyUIService.selected_lobby then
			LobbyUIService.lobby_card_container:Finish()
			LobbyUIService.lobby_card_container = nil
		end
	
		LobbyUIService.selected_lobby = nil
	end
end

function LobbyUIService.ViewSettings()
	LobbyUIService.viewing_settings = true
	LobbyUIService.container.inner_container:AnimateAttribute("offset_x", -168, ANIMATION_DURATION * 4)
	LobbyUIService.new_lobby_section:AnimateAttribute("alpha", QUARTER_ALPHA)
	LobbyUIService.lobby_section:AnimateAttribute("alpha", QUARTER_ALPHA)
	LobbyUIService.lobby_card_container.settings:AnimateAttribute("alpha", 255)
end

function LobbyUIService.HideSettings()
	LobbyUIService.viewing_settings = false
	LobbyUIService.container.inner_container:AnimateAttribute("offset_x", 168, ANIMATION_DURATION * 4)
	LobbyUIService.new_lobby_section:AnimateAttribute("alpha", 255)
	LobbyUIService.lobby_section:AnimateAttribute("alpha", 255)
	LobbyUIService.lobby_card_container.settings:AnimateAttribute("alpha", QUARTER_ALPHA)
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
	if element:HasParent(LobbyUIService.container) then
		LobbyUIService.Focus()
	end
end
hook.Add("TextEntryFocus", "LobbyUIService.FocusTextEntry", LobbyUIService.FocusTextEntry)

function LobbyUIService.UnFocusTextEntry(element)
	if LobbyUIService.focused then
		LobbyUIService.UnFocus()
	end
end
hook.Add("TextEntryUnFocus", "LobbyUIService.UnFocusTextEntry", LobbyUIService.UnFocusTextEntry)

function LobbyUIService.MousePressed(panel)
	if 
		not (LobbyUIService.SmallScreen() and LobbyUIService.viewing_settings) and
		not ListSelector.focused and (
			panel == LobbyUIService.container.panel or
			panel == LobbyUIService.container.inner_container.panel or
			panel == LobbyUIService.new_lobby_section.panel or
			panel == LobbyUIService.lobby_section.panel
		) and
		LobbyUIService.selected_lobby
	then
		if LobbyUIService.SmallScreen() then
			LobbyUIService.HideSettings()
		end

		LobbyUIService.UnSelectLobby()
	end
	
	if LobbyUIService.SmallScreen() and LobbyUIService.lobby_card_container then
		if not LobbyUIService.lobby_card_container.settings.panel:IsCursorOutBoundsX() then
			LobbyUIService.ViewSettings()
		elseif
			not LobbyUIService.new_lobby_section.panel:IsCursorOutBoundsX() or
			not LobbyUIService.lobby_section.panel:IsCursorOutBoundsX()
		then
			LobbyUIService.HideSettings()
		end
	end
end
hook.Add("VGUIMousePressed", "LobbyUIService.MousePressed", LobbyUIService.MousePressed)