LobbyBar = LobbyBar or Class.New(Element)

function LobbyBar:Init(lobby)
	LobbyBar.super.Init(self, {
		layout_direction = DIRECTION_ROW,
		layout_justification_y = JUSTIFY_END,
		fit_y = true,
		width_percent = 1,
		crop_bottom = 1,
		padding_left = MARGIN * 8,
		padding_right = MARGIN * 6,
		padding_top = MARGIN,
		inherit_color = false,
		border = LINE_THICKNESS/2,
		border_color = lobby.prototype.color,
		border_alpha = 0,
		cursor = "hand",
		bubble_mouse = false,

		hover = {
			color = lobby.prototype.color,
			border_alpha = 255
		},

		press = {
			background_color = COLOR_GRAY_DARK,
			color = COLOR_BACKGROUND,
			border_color = COLOR_BACKGROUND
		},

		pulse = Element.New {
			overlay = true,
			layout = false,
			width_percent = 1,
			height_percent = 1,
			fill_color = true,
			inherit_color = false,

			color = function ()
				return ColorAlpha(COLOR_GRAY_LIGHT, ((math.sin(CurTime() * 4) + 1)/2) * 255)
			end,

			alpha = lobby:IsLocal() and 255 or 0
		}
	})

	self.lobby = lobby
	lobby.bar_element = self

	local left_section = self:Add(Element.New {
		layout_direction = DIRECTION_ROW,
		layout_justification_y = JUSTIFY_CENTER,
		fit_y = true,
		width_percent = 0.5,
		padding_bottom = MARGIN * 2,
		child_margin = MARGIN * 8,

		Element.New {
			width = BUTTON_ICON_SIZE,
			height = BUTTON_ICON_SIZE,
			crop_y = 0.1,
			material = Material("emm2/minigames/"..lobby.prototype.key..".png", "noclamp smooth")
		}
	})

	self.host = left_section:Add(Element.New {
		fit = true,
		font = "Info",
		text_justification = 4,
		text = LobbyUIService.ProperPlayerName(lobby.host)
	})

	local right_section = self:Add(Element.New {
		layout_direction = DIRECTION_ROW,
		layout_justification_x = JUSTIFY_END,
		layout_justification_y = JUSTIFY_CENTER,
		fit_y = true,	
		crop_bottom = 0.01,
		width_percent = 0.5,
		padding_bottom = MARGIN * 2,
		child_margin = MARGIN * 8
	})

	self.players = right_section:Add(Element.New {
		width = 25,
		height = 24,
		crop_right = 0.01,
		crop_bottom = 0.01,
		font = "NumberInfo",
		text_justification = 5,
		text = #lobby.players,
		border = LINE_THICKNESS/2
	})

	self:Add(Element.New {
		width_percent = 1,
		height = LINE_THICKNESS/2,
		fill_color = true,
	
		alpha = function ()
			return self.last and 0 or 255
		end
	})

	self:AnimateAttribute("crop_bottom", 0)
	self:Add(NotificationService.CreateFlash())
end

function LobbyBar:AnimateFinish()
	self:AnimateAttribute("crop_bottom", 1)

	self:AnimateAttribute("background_color", COLOR_BACKGROUND_LIGHT, {
		callback = function ()
			LobbyBar.super.Finish(self)
		end
	})
end

function LobbyBar:Finish()
	if self == self.lobby.bar_element then
		self.lobby.bar_element = nil
	end

	self.lobby = nil
	self:AnimateFinish()
end

function LobbyBar:OnMousePressed(mouse)
	LobbyBar.super.OnMousePressed(self, mouse)
	LobbyUIService.SelectLobby(self.lobby)
end

function LobbyBar:OnMouseExited()
	if not self.lobby.card_element then
		self:RevertState()
	end
end

PlayerBar = PlayerBar or Class.New(Element)

function PlayerBar:Init(ply)
	PlayerBar.super.Init(self, {
		fit_y = true,
		width_percent = 1,
		padding_left = MARGIN * 8,
		padding_top = MARGIN * 4,
		padding_bottom = MARGIN * 4,
		text_justification = 4,
		font = "Info"
	})

	self.player = ply

	self.avatar = self.panel:Add(vgui.Create "AvatarImage")
	self.avatar:MoveToBefore(self.panel.text)
	self.avatar:SetAlpha(QUARTER_ALPHA)
	self.avatar:SetPlayer(ply, 184)

	self:SetText(LobbyUIService.ProperPlayerName(ply))

end

function PlayerBar:AnimateStart()
	self:SetAttribute("crop_bottom", 1)
	self:AnimateAttribute("crop_bottom", 0)
	self:Add(NotificationService.CreateFlash())
end

function PlayerBar:AnimateFinish()
	self:AnimateAttribute("crop_bottom", 1, {
		callback = function ()
			PlayerBar.super.Finish(self)
		end
	})
end

function PlayerBar:Finish()
	self.player = nil
	self:AnimateFinish()
end

function PlayerBar:Layout()
	PlayerBar.super.Layout(self)

	if self.avatar then
		local w = self:GetAttribute "width"
		local h = self:GetAttribute "height"

		self.avatar:SetSize(w, w)
		self.avatar:SetPos(0, (h/2) - (w/2))
	end
end

LobbyCard = LobbyCard or Class.New(Element)

function LobbyCard:Init(lobby)
	LobbyCard.super.Init(self, {
		layout = false,
		origin_position = true,
		layout_direction = DIRECTION_COLUMN,
		fit_y = true,
		width = 256,
		child_margin = MARGIN * 4,
		alpha = 0,
		header = LobbyUIService.CreateHeader(LobbyUIService.LobbyHostText(lobby.host))
	})

	self.lobby = lobby
	lobby.card_element = self

	self.prototype = self:Add(Element.New {
		layout_direction = DIRECTION_ROW,
		layout_justification_y = JUSTIFY_CENTER,
		fit_y = true,
		width_percent = 1,
		background_color = COLOR_GRAY,

		Element.New {
			layout_justification_x = JUSTIFY_CENTER,
			layout_justification_y = JUSTIFY_CENTER,
			width = LOBBY_CARD_PROTOTYPE_ICON_SIZE,
			height = LOBBY_CARD_PROTOTYPE_ICON_SIZE,
			padding = MARGIN/2,
			background_color = lobby.prototype.color,

			Element.New {
				width_percent = 1,
				height_percent = 1,
				material = Material("emm2/minigames/"..lobby.prototype.key.."-2x.png", "nocull smooth")
			}
		},

		Element.New {
			fit = true,
			crop_top = 0.2,
			crop_bottom = 0.15,
			padding_left = MARGIN * 8,
			padding_bottom = MARGIN - 1,
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
		ply.lobby_card_element = self.players:Add(PlayerBar.New(ply))
	end

	self.actions = self:Add(Element.New {
		fit_y = true,
		width_percent = 1,
		crop_bottom = 0.5,
	})

	self.actions:AddState("leave", {
		crop_top = 0.5,
		crop_bottom = 0
	})

	if lobby:IsLocal() then
		self.actions:SetState "leave"
	end

	self.join = self.actions:Add(ButtonBar.New {
		background_color = lobby.prototype.color,
		color = COLOR_WHITE,
		material = Material("emm2/ui/join.png", "nocull smooth"),
		text = "Join",

		on_click = function ()
			NetService.Send("RequestLobbyJoin", lobby)
		end
	})

	self.leave = self.actions:Add(ButtonBar.New {
		background_color = lobby.prototype.color,
		color = COLOR_WHITE,
		material = Material("emm2/ui/leave.png", "nocull smooth"),
		text = "Leave",

		on_click = function ()
			NetService.Send "RequestLobbyLeave"
		end
	})

	self:AnimateAttribute("alpha", 255)
end

function LobbyCard:AnimateFinish()
	self:AnimateAttribute("alpha", 0, {
		callback = function ()
			LobbyCard.super.Finish(self)
		end
	})
end

function LobbyCard:Finish()
	if self == self.lobby.card_element then
		self.lobby.card_element = nil
	end

	for _, ply in pairs(self.lobby.players) do
		ply.lobby_card_element = nil
	end

	self.lobby = nil
	self:AnimateFinish()
end