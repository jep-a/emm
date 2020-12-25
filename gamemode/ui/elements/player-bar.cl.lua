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

function PlayerBar:Finish()
	self.player = nil
	self:AnimateFinish {crop_bottom = 1}
end

function PlayerBar:Layout()
	PlayerBar.super.Layout(self)

	if self.avatar then
		local w = self.attributes.width.current
		local h = self.attributes.height.current

		self.avatar:SetSize(w, w)
		self.avatar:SetPos(0, (h/2) - (w/2))
	end
end