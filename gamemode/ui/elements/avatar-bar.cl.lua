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

