local Vector = Vector
local Angle = Angle
local random = math.random

function EFFECT:Init(data)
	local ent = data:GetEntity()
	local origin = data:GetOrigin()
	local ang = data:GetAngles()
	local norm = data:GetNormal()
	local emitter = ParticleEmitter(origin, false)
	local color = ent.color or COLOR_WHITE

	for i = 0, 20 do
		local vel = Vector(random(0, 256), random(-128, 128), random(0, 128))
		vel:Rotate(norm:Angle())

		local particle = emitter:Add("effects/spark", origin)
		particle:SetCollide(true)
		particle:SetVelocity(vel)
		particle:SetLifeTime(0)
		particle:SetDieTime(1)
		particle:SetGravity(Vector(0, 0, -800))
		particle:SetBounce(0.25)
		particle:SetColor(color.r, color.g, color.b)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(random(3, 5))
		particle:SetStartLength(random(3, 10))
		particle:SetEndSize(0)
		particle:SetEndLength(0)
	end

	for i = 0, 20 do
		local vel = Vector(random(0, 256), random(-128, 256), random(-128, 256))
		vel:Rotate(norm:Angle())

		local particle = emitter:Add("effects/spark", origin)
		particle:SetCollide(true)
		particle:SetVelocity(vel)
		particle:SetLifeTime(0)
		particle:SetDieTime(0.5)
		particle:SetGravity(Vector(0, 0, -800))
		particle:SetBounce(0.25)
		particle:SetColor(color.r, color.g, color.b)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(random(2, 2))
		particle:SetStartLength(random(1, 3))
		particle:SetEndSize(0)
		particle:SetEndLength(0)
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	--
end
