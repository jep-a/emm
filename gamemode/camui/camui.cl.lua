CamUIService = CamUIService or {}
CamUIService.panels = CamUIService.panels or {}


-- # Setup

CamUIService.eye_angles_delta = AnimatableValue.New(Angle(0, 0, 0), {
	smooth = true,
	smooth_multiplier = 16,
	smooth_delta_only = true
})

CamUIService.cam_angle = AnimatableValue.New(Angle(0, 0, 0), {
	smooth = true,
	generate = function ()
		return CamUIService.eye_angles_delta.smooth
	end
})

function CamUIService.CalcView(ply, _, eye_ang)
	CamUIService.eye_angles_delta.current = eye_ang
end
hook.Add("CalcView", "CamUIService.CalcView", CamUIService.CalcView)

function CamUIService.AddPanel(pnl, offset_cam_dist, offset_cam_ang)
	pnl.offset_cam_distance = offset_cam_dist or 0
	pnl.offset_cam_angle = offset_cam_ang or Angle(0, 0, 0)
	pnl:SetPaintedManually(true)
	table.insert(CamUIService.panels, pnl)
end


-- # Rendering

function CamUIService.Render()
	cam.Start3D(Vector(0, -ScrW()/2, -ScrH()/2), CamUIService.cam_angle.smooth, 90)

	for i, pnl in pairs(CamUIService.panels) do
		if not IsValid(pnl) then
			table.remove(CamUIService.panels, i)
		end
	end

	for i, pnl in pairs(CamUIService.panels) do
		if IsValid(pnl) then
			CamUIService.RenderPanel(pnl)
		end
	end

	cam.End3D()
end
hook.Add("HUDPaint", "CamUIService.Render", CamUIService.Render)

local cam_angle = Angle(0, -90, 90)
function CamUIService.RenderPanel(pnl)
	local offset_ang = pnl.offset_cam_angle
	local scr_w = ScrW()
	local scr_h = ScrH()
	local scr_w_offset = scr_w/2
	local scr_h_offset = scr_h/2

	local offset_vec_a = Vector(scr_w_offset, scr_h_offset, 0)
	offset_vec_a:Rotate(Angle(offset_ang.y, offset_ang.r, offset_ang.p))

	cam.Start3D2D(Vector((scr_w_offset * (pnl.offset_cam_distance/100 + 1)) - offset_vec_a.z, -scr_w_offset + offset_vec_a.x, -scr_h_offset + offset_vec_a.y), cam_angle + Angle(offset_ang.r, -offset_ang.y, offset_ang.p), 1)
	cam.IgnoreZ(true)
	pnl:PaintManual()
	cam.IgnoreZ(false)
	cam.End3D2D()
end
