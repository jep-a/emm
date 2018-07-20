local Vector = Vector
local Angle = Angle
local IgnoreZ = cam.IgnoreZ
local Start3D2D = cam.Start3D2D
local End3D2D = cam.End3D2D
local SetAlphaMultiplier = surface.SetAlphaMultiplier
local SetMaterial = surface.SetMaterial
local SetDrawColor = surface.SetDrawColor
local DrawTexturedRect = surface.DrawTexturedRect

local LIFE_SPAN = 2

function EFFECT:Init(data)
	self.entity = data:GetEntity()
	self.die_time = CurTime() + LIFE_SPAN
	self.origin = data:GetOrigin()
	self.normal = data:GetNormal()
	self.color = self.entity.color or COLOR_WHITE
	self.alpha = 255
	self.size = 0
end

function EFFECT:Think()
	local prog = (self.die_time - CurTime())
	if prog > 0 then
		local frac = math.EaseInOut(prog/LIFE_SPAN, 1, 0)
		self.alpha = Lerp(frac, 0, 255)
		self.size = Lerp(frac, 150, 0)

		return true
	else
		return false
	end
end

local CIRCLE_MATERIAL = Material("emm/indicator/circle.png", "noclamp smooth")
function EFFECT:Render()
	local ent = self.entity
	local norm = self.normal
	local norm_ang = norm:Angle()
	local size = self.size
	local vec = self.origin + (norm * Vector(0.5, 0.5, 0.5))
	IgnoreZ(IsValid(ent) and ent.indicator)
		SetAlphaMultiplier(self.alpha/255)
			SetMaterial(CIRCLE_MATERIAL)
			SetDrawColor(self.color)

			Start3D2D(vec, norm_ang + Angle(90, 0, 0), 0.25)
					DrawTexturedRect(-size/2, -size/2, size, size)
			End3D2D()

			Start3D2D(vec, norm_ang + Angle(-90, 0, 0), 0.25)
					DrawTexturedRect(-size/2, -size/2, size, size)
			End3D2D()
		SetAlphaMultiplier(1)
	IgnoreZ(false)
end
