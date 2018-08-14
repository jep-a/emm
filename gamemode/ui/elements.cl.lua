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
		self:SetAttribute("text_color", COLOR_WHITE)
	end
end

MeterBar = MeterBar or Class.New(Element)

function MeterBar:Init(props)
	MeterBar.super.Init(self, {
		layout_justification_x = JUSTIFY_CENTER,
		width_percent = 1,
		height = LINE_THICKNESS,
		background_color = COLOR_BACKGROUND
	})

	if props then
		self:SetAttributes(props)
	end

	self.bar = self:Add(Element.New {
		width_percent = AnimatableValue.New(0, {smooth = true}),
		height_percent = 1,
		fill_color = true
	})
end

function MeterBar:SetPercent(percent)
	self.bar:SetAttribute("width_percent", math.Clamp(percent, 0, 1))
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

