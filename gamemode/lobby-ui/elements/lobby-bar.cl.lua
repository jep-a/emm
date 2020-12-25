LobbyBar = LobbyBar or Class.New(Element)

function LobbyBar:Init(lobby)
	LobbyBar.super.Init(self, {
		layout_justification_y = JUSTIFY_CENTER,
		width_percent = 1,
		height = 52,
		padding_x = 32,
		inherit_color = false,
		border = LINE_THICKNESS,
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

	self.type_container = self:Add(Element.New {
		layout_justification_y = JUSTIFY_CENTER,
		width = 64,
		height_percent = 1
	})

	self.type_container:Add(Element.New {
		width = BUTTON_ICON_SIZE,
		height = BUTTON_ICON_SIZE,
		crop = 0.1,
		material = PNGMaterial("emm2/minigames/"..lobby.prototype.key..".png")
	})

	self.host = self:Add(Element.New {
		fit = true,
		font = "Info",
		text_justification = 4,
		text = ProperPlayerName(lobby.host)
	})

	self.players = self:Add(Element.New {
		self_justification = JUSTIFY_END,
		width = 25,
		height = 24,
		crop_right = 0.01,
		crop_bottom = 0.01,
		font = "NumberInfo",
		text_justification = 5,
		text = #lobby.players,
		border = LINE_THICKNESS
	})

	self:Add(Element.New {
		layout = false,
		origin_position = true,
		origin_justification_x = JUSTIFY_CENTER,
		origin_justification_y = JUSTIFY_END,
		position_justification_x = JUSTIFY_CENTER,
		position_justification_y = JUSTIFY_END,
		width_percent = 1,
		height = LINE_THICKNESS,
		fill_color = true,

		alpha = function ()
			return self.last and 0 or 255
		end
	})
end

function LobbyBar:AnimateStart()
	self:SetAttribute("crop_bottom", 1)
	self:AnimateAttribute("crop_bottom", 0)
	self:Add(NotificationService.CreateFlash())
end

function LobbyBar:Finish()
	if not self.animating_finish then
		if self == self.lobby.bar_element then
			self.lobby.bar_element = nil
		end

		self.lobby = nil

		self:AnimateFinish {
			duration = ANIMATION_DURATION * 4,
			crop_bottom = 1,
			background_color = COLOR_BACKGROUND_LIGHT
		}
	end
end

function LobbyBar:OnMousePressed(mouse)
	LobbyBar.super.OnMousePressed(self, mouse)
	LobbyUIService.SelectLobby(self.lobby)
end

function LobbyBar:OnMouseExited()
	if self.lobby and not self.lobby.card_element then
		self:RevertState()
	end
end