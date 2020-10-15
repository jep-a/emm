LobbyUIService = LobbyUIService or {}


-- # Util

function LobbyUIService.SmallScreen()
	return 1600 > ScrW()
end

function LobbyUIService.HellaSmallScreen()
	return 1152 > ScrW()
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
		LobbyUIService.AddLobby(lobby, false)
	end

	LobbyUIService.SetLobbyListHeaderText(table.Count(MinigameService.lobbies))

	if LobbyUIService.selected_lobby then
		LobbyUIService.SelectLobby(LobbyUIService.selected_lobby, true)
	end
end

UIService.Register("Lobbies", LobbyUIService, {
	open_hook = "OnSpawnMenuOpen",
	close_hook = "OnSpawnMenuClose",
})


-- # Hooks

function LobbyUIService.AddLobby(lobby, notify)
	notify = Default(notify, true)

	if UIService.Active "Lobbies" then
		local lobby_bar = LobbyBar.New(lobby)

		LobbyUIService.lobby_list:Add(lobby_bar)

		if notify and lobby:IsLocal() then
			LobbyUIService.SelectLobby(lobby)
		end

		local lobby_count = (table.Count(MinigameService.lobbies) + 1)

		LobbyUIService.SetLobbyListHeaderText(lobby_count)

		if lobby_count > 0 then
			LobbyUIService.lobby_list:AnimateState "contains_children"
		end

		if notify then
			lobby_bar:AnimateStart()
		end
	end

	if notify then
		chat.AddText(lobby.prototype.color, lobby.host:GetName(), " has made a ", lobby.prototype.name, " lobby")
	end
end
hook.Add("LobbyCreate", "LobbyUIService.AddLobby", LobbyUIService.AddLobby)

function LobbyUIService.FinishLobby(lobby)
	if UIService.Active "Lobbies" then
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
	elseif lobby == LobbyUIService.selected_lobby then
		LobbyUIService.selected_lobby = nil
	end
end
hook.Add("LobbyFinish", "LobbyUIService.FinishLobby", LobbyUIService.FinishLobby)

function LobbyUIService.SetLobbyHost(lobby, ply)
	if UIService.Active "Lobbies" then
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
	end

	if lobby:IsLocal() then
		chat.AddText(lobby.prototype.color, ply:GetName(), " has inherited host")
	end
end
hook.Add("LobbyHostChange", "LobbyUIService.SetLobbyHost", LobbyUIService.SetLobbyHost)

function LobbyUIService.RefreshSettings(lobby, settings)
	if UIService.Active "Lobbies" and lobby == LobbyUIService.selected_lobby then
		LobbyUIService.lobby_card_container.settings:Refresh(settings)
	end
end
hook.Add("LobbySettingsChange", "LobbyUIService.RefreshSettings", LobbyUIService.RefreshSettings)

function LobbyUIService.AddLobbyPlayer(lobby, ply)
	if UIService.Active "Lobbies" then
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
	end

	chat.AddText(lobby.prototype.color, ply:GetName(), " has joined ", lobby.host:GetName(), "'s lobby")
end
hook.Add("LobbyPlayerJoin", "LobbyUIService.AddLobbyPlayer", LobbyUIService.AddLobbyPlayer)

function LobbyUIService.RemoveLobbyPlayer(lobby, ply)
	if UIService.Active "Lobbies" then
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
end
hook.Add("LobbyPlayerLeave", "LobbyUIService.RemoveLobbyPlayer", LobbyUIService.RemoveLobbyPlayer)

function LobbyUIService.SelectLobby(lobby, no_notify)
	if lobby and not lobby.card_element then
		local small_screen = LobbyUIService.SmallScreen()

		if lobby ~= LobbyUIService.selected_lobby then
			LobbyUIService.UnSelectLobby()
		end

		if small_screen then
			LobbyUIService.container.inner_container:AnimateAttribute("offset_x", 168, ANIMATION_DURATION * 4)
		end

		if no_notify then
			LobbyUIService.lobby_card_section:SetAttribute("layout_crop_x", 0)
		else
			LobbyUIService.lobby_card_section:AnimateAttribute("layout_crop_x", 0, ANIMATION_DURATION * 4)
		end

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

		if lobby == LobbyUIService.selected_lobby and LobbyUIService.lobby_card_container then
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

function LobbyUIService.MousePressed(panel)
	if UIService.Active "Lobbies" then
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
end
hook.Add("VGUIMousePressed", "LobbyUIService.MousePressed", LobbyUIService.MousePressed)