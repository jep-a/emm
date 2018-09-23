Indicator = Indicator or Class.New(Element)

local indicator_material = Material("emm2/shapes/arrow.png", "noclamp smooth")

function Indicator:Init(ent_or_vec)
	Indicator.super.Init(self, {
		layout = false,
		width_percent = 1,
		height_percent = 1,
		inherit_color = false,
	})

	self.x = 0
	self.y = 0
	self.distance = 0
	self.world_alpha = AnimatableValue.New()

	self.animatable_color = AnimatableValue.New(COLOR_WHITE, {
		smooth = true,
		generate = function ()
			local color

			if IsValid(self.entity) then
				color = self.entity.color
			else
				color = COLOR_WHITE
			end

			return color
		end
	})

	self:SetAttribute("color", function ()
		return self.animatable_color.smooth
	end)

	self.off_screen = AnimatableValue.New(false, {
		generate = function ()
			return 0 > self.x or self.x > ScrW() or 0 > self.y or self.y > ScrH()
		end,

		callback = function (anim_v)
			if anim_v.current then
				self.world_alpha:AnimateTo(0)
				self.peripheral:AnimateAttribute("alpha", 255)
			else
				self.world_alpha:AnimateTo(255)
				self.peripheral:AnimateAttribute("alpha", 0)
			end
		end
	})

	if isentity(ent_or_vec) then
		self.entity = ent_or_vec
	elseif isvector(ent_or_vec) then
		self.position = ent_or_vec
	end

	self.peripheral = self:Add(Element.New {
		layout = false,
		width = INDICATOR_PERIPHERAL_SIZE,
		height = INDICATOR_PERIPHERAL_SIZE,
		material = indicator_material,
		angle = 0,
		alpha = 0
	})
end

function Indicator:Think()
	Indicator.super.Think(self)

	if self.off_screen.current then
		local scr_w = ScrW()
		local scr_h = ScrH()
		local half_scr_w = scr_w/2
		local half_scr_h = scr_h/2
		local periph_radius = half_scr_h - HUD_PADDING_Y

		local x = self.x
		local y = self.y

		local rad_ang = math.atan2(y - half_scr_h, x - half_scr_w)
		local periph_x = (math.cos(rad_ang) * periph_radius) + half_scr_w
		local periph_y = (math.sin(rad_ang) * periph_radius) + half_scr_h

		local attr = self.peripheral.attributes

		attr.x.current = periph_x - (attr.width.current/2)
		attr.y.current = periph_y - (attr.height.current/2)
		attr.angle.current = -math.deg(rad_ang) + 90

		self.peripheral:Layout()
	end
end

function Indicator:AnimateFinish()
	self:AnimateAttribute("alpha", 0, {
		duration = 1,

		callback = function ()
			local ent = self.entity

			if IsValid(ent) then
				if self == ent.indicator then
					ent.indicator = nil
				end
			end

			Indicator.super.Finish(self)
			self.world_alpha:Finish()
			self.animatable_color:Finish()
			self.off_screen:Finish()
		end
	})
end

function Indicator:Finish()
	self:AnimateFinish()
end