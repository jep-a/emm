local LIFE_SPAN = 1

function EFFECT:Init(data)
	self.entity = data:GetEntity()
	self.start_time = CurTime()
	self.die_time = CurTime() + LIFE_SPAN
	self.origin = data:GetOrigin()
	self.normal = data:GetNormal()
	self.color = self.entity.color
	self.size = 0
	self.alpha = 255
end

local Ease = CubicBezier(0.2, 1, 0.2, 1)

function EFFECT:Think()
	local time = math.TimeFraction(self.start_time, self.die_time, CurTime())
	local alive = 1 >= time

	if alive then
		local eased_time = Ease(time)
		self.size = Lerp(eased_time, 0, 150)
		self.alpha = Lerp(eased_time, 255, 0)
	end

	return alive
end

local CIRCLE_MATERIAL = PNGMaterial "emm2/shapes/circle.png"

function EFFECT:Render()
	local pos = self.origin + (self.normal/2)
	local norm_ang = self.normal:Angle()

	local ignore_z

	if IsValid(self.entity) then
		ignore_z = self.entity.indicator ~= nil
	else
		ignore_z = false
	end

	cam.IgnoreZ(ignore_z)
	surface.SetAlphaMultiplier(self.alpha/255)
	surface.SetMaterial(CIRCLE_MATERIAL)
	surface.SetDrawColor(self.color)

	cam.Start3D2D(pos, norm_ang + Angle(90, 0, 0), 0.25)
	surface.DrawTexturedRect(-self.size/2, -self.size/2, self.size, self.size)
	cam.End3D2D()

	cam.Start3D2D(pos, norm_ang + Angle(-90, 0, 0), 0.25)
	surface.DrawTexturedRect(-self.size/2, -self.size/2, self.size, self.size)
	cam.End3D2D()

	surface.SetAlphaMultiplier(1)
	cam.IgnoreZ(false)
end
