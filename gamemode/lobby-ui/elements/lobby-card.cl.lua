LobbyCard = LobbyCard or Class.New(Element)

function LobbyCard:Init(lobby)
	LobbyCard.super.Init(self, {
		layout = false,
		origin_position = true,
		layout_direction = DIRECTION_COLUMN,
		fit_y = true,
		width = COLUMN_WIDTH,
		child_margin = MARGIN * 4,
		alpha = 0,
		header = LobbyUIService.CreateHeader(LobbyUIService.LobbyHostText(lobby.host))
	})

	self.lobby = lobby
	lobby.card_element = self

	self.prototype = self:Add(Element.New {
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
		crop_bottom = 0.5
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