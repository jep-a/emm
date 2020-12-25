LobbyCardContainer = LobbyCardContainer or Class.New(Element)

function LobbyCardContainer:Init(lobby)
	LobbyCardContainer.super.Init(self, {
		layout = false,
		fit = true,
		child_margin = MARGIN * 4,
		alpha = 0
	})

	self.lobby = lobby
	self.lobby_card = self:Add(LobbyCard.New(lobby))
	self.settings = self:Add(LobbySettings.New(lobby))

	self:AnimateAttribute("alpha", 255, ANIMATION_DURATION * 2)
end

function LobbyCardContainer:Finish()
	self:AnimateFinish {
		duration = ANIMATION_DURATION * 2,
		alpha = 0
	}

	self.lobby_card:FinishLobby()
end

LobbyCard = LobbyCard or Class.New(Element)

local lobby_join_request_cooldown = 5
local last_request_lobby_join_time = 0

function LobbyCard:Init(lobby)
	LobbyCard.super.Init(self, {
		layout_direction = DIRECTION_COLUMN,
		fit_y = true,
		width = COLUMN_WIDTH,
		child_margin = MARGIN * 4,
		header = LobbyUIService.CreateHeader(LobbyUIService.LobbyHostText(lobby.host))
	})

	self.lobby = lobby
	lobby.card_element = self

	self.prototype = self:Add(Element.New {
		layout_justification_y = JUSTIFY_CENTER,
		fit_y = true,
		width_percent = 1,
		height = 64,
		background_color = COLOR_GRAY,

		Element.New {
			layout_justification_x = JUSTIFY_CENTER,
			layout_justification_y = JUSTIFY_CENTER,
			width = LARGE_BUTTON_ICON_SIZE,
			height = LARGE_BUTTON_ICON_SIZE,
			padding = 2,
			inherit_color = false,
			background_color = lobby.prototype.color,
			color = COLOR_BACKGROUND,

			Element.New {
				width_percent = 1,
				height_percent = 1,
				material = PNGMaterial("emm2/minigames/"..lobby.prototype.key.."-2x.png"),
				color = COLOR_RED
			}
		},

		Element.New {
			fit = true,
			crop_top = 0.2,
			crop_bottom = 0.15,
			padding_left = 32,
			font = "ButtonBar",
			text_justification = 4,
			text = string.upper(lobby.prototype.name)
		}
	})

	self.players = self:Add(Element.New {
		fit_y = true,
		width_percent = 1,
		background_color = COLOR_GRAY,
		LobbyUIService.CreateLabels {"Players"}
	})

	for _, ply in pairs(lobby.players) do
	    if (ply:IsValid()) then
		    ply.lobby_card_element = self.players:Add(PlayerBar.New(ply))
		end
	end

	self.actions = self:Add(Element.New {
		fit_y = true,
		width_percent = 1
	})

	self.switch = self.actions:Add(Element.New {
		fit_y = true,
		width_percent = 1,
		crop_bottom = 0.5,
		crop_margin = false
	})

	self.switch:AddState("leave", {
		crop_top = 0.5,
		crop_bottom = 0
	})

	if lobby:IsLocal() then
		self.switch:SetState "leave"
	end

	self.join = self.switch:Add(ButtonBar.New {
		material = PNGMaterial "emm2/ui/join.png",
		text = "Join",
		fill_color = true,
		color = lobby.prototype.color,

		on_click = function ()
			local cur_time = CurTime()

			if cur_time > (last_request_lobby_join_time + lobby_join_request_cooldown) then
				NetService.SendToServer("RequestLobbyJoin", lobby)
				last_request_lobby_join_time = CurTime()
			else
				chat.AddText(COLOR_RED, "Please wait ", tostring(-math.Round(cur_time - (last_request_lobby_join_time + lobby_join_request_cooldown))), " seconds before joining a new lobby")
			end
		end
	})

	self.leave = self.switch:Add(ButtonBar.New {
		material = PNGMaterial "emm2/ui/leave.png",
		text = "Leave",
		fill_color = true,
		color = lobby.prototype.color,

		on_click = function ()
			NetService.SendToServer "RequestLobbyLeave"
		end
	})

	if IsLocalPlayer(lobby.host) then
		self:AddHostActions()
	end
end

function LobbyCard:AddRestartAction()
	self.restart = self.actions:Add(ButtonBar.New {
		crop_bottom = 1,
		background_color = COLOR_GRAY,
		color = self.lobby.prototype.color,
		material = PNGMaterial "emm2/ui/restart.png",
		text = "Restart",

		on_click = function ()
			NetService.SendToServer "RequestLobbyRestart"
		end
	})

	self.restart:SetAttributes {
		crop_bottom = 1,
		alpha = 0
	}

	self.restart:AnimateAttribute("crop_bottom", 0, ANIMATION_DURATION * 2)
	self.restart:AnimateAttribute("alpha", 255, ANIMATION_DURATION * 2)
end

function LobbyCard:FinishRestartAction()
	self.restart:AnimateFinish {
		duration = ANIMATION_DURATION * 2,
		crop_bottom = 1,
		alpha = 0
	}

	self.restart = nil
end

function LobbyCard:AddHostActions()
	if self.lobby:CanRestart() then
		self:AddRestartAction()
	end
end

function LobbyCard:FinishHostActions()
	if self.restart then
		self:FinishRestartAction()
	end
end

function LobbyCard.AdjustStateHostActions(lobby, old_state, state)
	if UIService.Active "Lobbies" and IsLocalPlayer(lobby.host) and lobby == LobbyUIService.selected_lobby then
		local can_restart = lobby:CanRestart()

		if lobby.card_element.restart and not can_restart then
			lobby.card_element:FinishRestartAction()
		elseif not lobby.card_element.restart and can_restart then
			lobby.card_element:AddRestartAction()
		end
	end
end
hook.Add("LocalLobbySetState", "LobbyCard.AdjustStateHostActions", LobbyCard.AdjustStateHostActions)

function LobbyCard:FinishLobby()
	if self == self.lobby.card_element then
		self.lobby.card_element = nil
	end

	for _, ply in pairs(self.lobby.players) do
		if IsValid(ply) then
			ply.lobby_card_element = nil
		end
	end

	self.lobby = nil
end
