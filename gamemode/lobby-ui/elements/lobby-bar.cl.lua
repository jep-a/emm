LobbyBar = LobbyBar or Class.New(Element)

function LobbyBar:Init(lobby)
	LobbyBar.super.Init(self, {
		layout_justification_y = JUSTIFY_END,
		fit_y = true,
		width_percent = 1,
		crop_bottom = 1,
		padding_x = MARGIN * 8,
		padding_top = MARGIN * 3,
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
		layout_justification_y = JUSTIFY_CENTER,
		wrap = false,
		fit_y = true,
		width_percent = 0.75,
		padding_bottom = MARGIN * 3,
		child_margin = MARGIN * 8,

		Element.New {
			width = BUTTON_ICON_SIZE,
			height = BUTTON_ICON_SIZE,
			crop_y = 0.1,
			material = PNGMaterial("emm2/minigames/"..lobby.prototype.key..".png")
		}
	})

	self.host = left_section:Add(Element.New {
		fit = true,
		font = "Info",
		text_justification = 4,
		text = ProperPlayerName(lobby.host)
	})

	local right_section = self:Add(Element.New {
		layout_justification_x = JUSTIFY_END,
		layout_justification_y = JUSTIFY_CENTER,
		fit_y = true,	
		crop_bottom = 0.01,
		width_percent = 0.25,
		padding_bottom = MARGIN * 3,
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
	self:AnimateAttribute("crop_bottom", 1, {
		duration = ANIMATION_DURATION * 4,

		callback = function ()
			LobbyBar.super.Finish(self)
		end
	})

	self:AnimateAttribute("background_color", COLOR_BACKGROUND_LIGHT)
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
	if self.lobby and not self.lobby.card_element then
		self:RevertState()
	end
end