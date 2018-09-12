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