TextBar = TextBar or Class.New(Element)

function TextBar:Init(text, props)
	TextBar.super.Init(self, {
		fit = true,
		padding_x = MARGIN * 2,
		padding_y = MARGIN,
		fill_color = true,
		font = "TextBar",
		text_justification = 5,
		text = text
	})

	if props then
		self:SetAttributes(props)
	end

	if self:GetAttribute "fill_color" then
		self:SetAttribute("text_color", COLOR_BACKGROUND)
	end
end

ButtonBar = ButtonBar or Class.New(Element)

function ButtonBar:Init(props)
	props = props or {}

	ButtonBar.super.Init(self, {
		layout_direction = DIRECTION_ROW,
		layout_justification_y = JUSTIFY_CENTER,
		fit_y = true,
		width_percent = 1,
		padding_left = MARGIN * 8,
		padding_top = MARGIN * 2,
		padding_bottom = MARGIN * 3,
		child_margin = MARGIN * 8,
		background_color = props.background and COLOR_GRAY or props.background_color,
		inherit_color = false,
		border = LINE_THICKNESS/2,
		border_color = props.color,
		border_alpha = 0,
		cursor = "hand",
		bubble_mouse = false,

		hover = {
			color = props.color,
			border_alpha = 255
		},

		press = {
			background_color = COLOR_GRAY_DARK,
			color = COLOR_BACKGROUND,
			border_color = COLOR_BACKGROUND
		},

		props.material and Element.New {
			width = BUTTON_ICON_SIZE,
			height = BUTTON_ICON_SIZE,
			crop_y = 0.1,
			material = props.material
		},

		Element.New {
			fit = true,
			font = "ButtonBar",
			text_justification = 4,
			text = string.upper(props.text)
		},

		props.divider and Element.New {
			layout = false,
			origin_position = true,
			origin_justification_x = JUSTIFY_CENTER,
			origin_justification_y = JUSTIFY_END,
			position_justification_x = JUSTIFY_CENTER,
			position_justification_y = JUSTIFY_END,
			width_percent = 0.95,
			height = 1,
			inherit_color = false,
			fill_color = true,
			color = COLOR_BACKGROUND_LIGHT,

			alpha = function ()
				return self.last and 0 or 255
			end
		}
	})

	self.on_click = props.on_click
end

function ButtonBar:OnMousePressed(mouse)
	ButtonBar.super.OnMousePressed(self, mouse)
	self.on_click(self, mouse)
end

MeterBar = MeterBar or Class.New(Element)

function MeterBar:Init(props)
	MeterBar.super.Init(self, {
		layout_justification_x = JUSTIFY_CENTER,
		width_percent = 1,
		height = LINE_THICKNESS,
		background_color = COLOR_BACKGROUND,

		bar = Element.New {
			width_percent = AnimatableValue.New(0, {smooth = true}),
			height_percent = 1,
			fill_color = true
		}
	})

	if props then
		self:SetAttributes(props)
	end
end

function MeterBar:SetPercent(percent)
	self.bar:SetAttribute("width_percent", math.Clamp(percent, 0, 1))
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

	self:SetText(ProperPlayerName(ply))
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

AvatarBar = AvatarBar or Class.New(Element)

function AvatarBar:Init(ply_or_id)
	AvatarBar.super.Init(self, {
		width = BAR_WIDTH,
		height = BAR_HEIGHT,
		background_color = COLOR_GRAY,
		text_justification = 5,
		font = "TextBar"
	})

	self.avatar = self.panel:Add(vgui.Create "AvatarImage")
	self.avatar:MoveToBefore(self.panel.text)
	self.avatar:SetSize(BAR_WIDTH, BAR_WIDTH)
	self.avatar:SetPos(0, (BAR_HEIGHT/2) - (BAR_WIDTH/2))
	self.avatar:SetAlpha(QUARTER_ALPHA)

	if isentity(ply_or_id) then
		self.avatar:SetPlayer(ply_or_id, 184)
		self:SetText(ply_or_id:GetName())
	else
		self.avatar:SetSteamID(ply_or_id, 184)
	end
end

