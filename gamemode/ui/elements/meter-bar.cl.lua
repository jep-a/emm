MeterBar = MeterBar or Class.New(Element)

function MeterBar:Init(props)
	MeterBar.super.Init(self, {
		layout_justification_x = JUSTIFY_CENTER,
		width_percent = 1,
		height = LINE_THICKNESS,
		background_color = COLOR_BACKGROUND,

		bar = Element.New {
			width_percent = 0,
			height_percent = 1,
			fill_color = true
		}
	})

	self.animatable_percent = AnimatableValue.New(0, {smooth = true})

	if props then
		self:SetAttributes(props)
	end
end

function MeterBar:Finish()
	MeterBar.super.Finish(self)
	self.animatable_percent:Finish()
end

function MeterBar:SetPercent(percent)
	self.animatable_percent.current = math.Clamp(percent, 0, 1)
end

function MeterBar:Think()
	MeterBar.super.Think(self)

	local w_percent = self.bar.attributes.width_percent
	local old_w_percent = w_percent.current

	w_percent.current = self.animatable_percent.smooth

	if math.Round(old_w_percent, 4) ~= math.Round(w_percent.current, 4) then
		self.bar:Layout()
	end
end
