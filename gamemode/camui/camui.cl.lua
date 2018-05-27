CamUIService = CamUIService or {}
CamUIService.panels = CamUIService.panels or {}


-- # Rendering

local lag_angle = Angle(0, 0, 0)
local last_angle = Angle(0, 0, 0)
local current_angle
local new_angle
local function LagEyeAngles()
	local frame_frac = (1/FrameTime() - 20)/60
	local ang_div = Lerp(frame_frac, 15, 12)
	local ang_mod = Lerp(frame_frac, 0.75, 0.1)
	current_angle = LocalPlayer():EyeAngles()

	if (last_angle.y < -90) and (current_angle.y > 90) then
		last_angle.y = last_angle.y + 360
	elseif (last_angle.y > 90) and (current_angle.y < -90) then
		last_angle.y = last_angle.y - 360
	end

	lag_angle = Angle((current_angle.p - last_angle.p)/ang_div, (current_angle.y - last_angle.y)/ang_div, 0)
	new_angle = Angle((current_angle.p * ang_mod + last_angle.p)/(ang_mod + 1), (current_angle.y * ang_mod + last_angle.y)/(ang_mod + 1), 0)
	last_angle = new_angle
end

function CamUIService.AddPanel(pnl)
	pnl:SetPaintedManually(true)
	table.insert(CamUIService.panels, pnl)
end

local cam_vector = Vector(0, -ScrW()/2, -ScrH()/2)
function CamUIService.Render()
	LagEyeAngles()
	cam.Start3D(cam_vector, lag_angle, 90)

	local invalid_pnls = {}

	for i, pnl in pairs(CamUIService.panels) do
		if IsValid(pnl) then
			CamUIService.RenderPanel(pnl)
		else
			table.insert(invalid_pnls, i)
		end
	end

	if #invalid_pnls > 0 then
		for _, pnl_i in pairs(invalid_pnls) do
			table.remove(CamUIService.panels, pnl_i)
		end
	end

	cam.End3D()
end
hook.Add("HUDPaint", "CamUIService.Render", CamUIService.Render)

local cam_angle = Angle(0, -90, 90)
function CamUIService.RenderPanel(pnl)
	cam.Start3D2D(Vector(ScrW()/2, 0, 0), cam_angle, 1)
	cam.IgnoreZ(true)
	pnl:PaintManual()
	cam.IgnoreZ(false)
	cam.End3D2D()
end
