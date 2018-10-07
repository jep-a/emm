
LobbyCardContainer = LobbyCardContainer or Class.New(Element)

function LobbyCardContainer:Init(lobby)
	LobbyCardContainer.super.Init(self, {
		layout_crop_x = 1,
		fit = true,
		child_margin = MARGIN * 4,
		alpha = 0
	})

	self.lobby = lobby
	self.lobby_card = self:Add(LobbyCard.New(lobby))

	if IsLocalPlayer(lobby.host) then
		self.settings = self:Add(LobbySettings.New(lobby))
	end

	self:AnimateAttribute("layout_crop_x", 0, ANIMATION_DURATION * 4)
	self:AnimateAttribute("alpha", 255, ANIMATION_DURATION * 4)
end

function LobbyCardContainer:AddSettings()
	self.settings = self:Add(LobbySettings.New(self.lobby))
end

function LobbyCardContainer:AnimateFinish()
	self:AnimateAttribute("layout_crop_x", 1, ANIMATION_DURATION * 4)

	self:AnimateAttribute("alpha", 0, {
		duration = ANIMATION_DURATION * 4,

		callback = function ()
			LobbyCardContainer.super.Finish(self)
		end
	})
	
	self.lobby_card:FinishLobby()
end

function LobbyCardContainer:Finish()
	self:AnimateFinish()
end

LobbyCard = LobbyCard or Class.New(Element)

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
		background_color = COLOR_GRAY,

		Element.New {
			layout_justification_x = JUSTIFY_CENTER,
			layout_justification_y = JUSTIFY_CENTER,
			width = LARGE_BUTTON_ICON_SIZE,
			height = LARGE_BUTTON_ICON_SIZE,
			padding = MARGIN/2,
			background_color = lobby.prototype.color,

			Element.New {
				width_percent = 1,
				height_percent = 1,
				material = PNGMaterial("emm2/minigames/"..lobby.prototype.key.."-2x.png")
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
		crop_margin = false
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
		material = PNGMaterial("emm2/ui/join.png"),
		text = "Join",

		on_click = function ()
			NetService.Send("RequestLobbyJoin", lobby)
		end
	})

	self.leave = self.actions:Add(ButtonBar.New {
		background_color = lobby.prototype.color,
		color = COLOR_WHITE,
		material = PNGMaterial("emm2/ui/leave.png"),
		text = "Leave",

		on_click = function ()
			NetService.Send "RequestLobbyLeave"
		end
	})
end

function LobbyCard:FinishLobby()
	if self == self.lobby.card_element then
		self.lobby.card_element = nil
	end

	for _, ply in pairs(self.lobby.players) do
		ply.lobby_card_element = nil
	end

	self.lobby = nil
end