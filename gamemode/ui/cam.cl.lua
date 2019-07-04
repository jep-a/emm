CamUIService = CamUIService or {}
CamUIService.panels = CamUIService.panels or {}

local cam_angle_divider = 4


-- # Setup

CamUIService.cam_smooth_multiplier = CamUIService.cam_smooth_multiplier or AnimatableValue.NewFromSetting "cam_ui_smooth_multiplier"

CamUIService.eye_angle = CamUIService.eye_angle or AnimatableValue.New(Angle(0, 0, 0), {
	smooth = true,
	smooth_multiplier = CAMUI_SMOOTH_MULTIPLIER,
	smooth_delta_only = true
})

CamUIService.eye_angle_2 = CamUIService.eye_angle_2 or AnimatableValue.New(Angle(0, 0, 0), {
	smooth = true,

	generate = function ()
		return CamUIService.eye_angle.smooth
	end
})

function CamUIService.CalcView(ply, _, eye_ang)
	CamUIService.eye_angle.current = eye_ang
end
hook.Add("CalcView", "CamUIService.CalcView", CamUIService.CalcView)

function CamUIService.AddPanel(pnl, props)
	pnl.camui_panel = true
	pnl.cam_smooth_divider = AnimatableValue.New(props.smooth_divider or 1)
	pnl.cam_distance = AnimatableValue.New(props.distance or 0)
	pnl.cam_angle = AnimatableValue.New(props.angle or Angle(0, 0, 0))
	pnl.cam_rotate_origin_x = props.rotate_origin_x or 0.5
	pnl.cam_rotate_origin_y = props.rotate_origin_y or 0.5

	pnl:SetPaintedManually(true)
	table.insert(CamUIService.panels, pnl)
end


-- # Rendering

function CamUIService.Render()
	for i, pnl in pairs(CamUIService.panels) do
		if not IsValid(pnl) then
			table.remove(CamUIService.panels, i)
		end
	end

	local scr_w = ScrW()
	local scr_h = ScrH()
	local half_scr_w = scr_w/2
	local half_scr_h = scr_h/2
	local cam_3d_vec = Vector(0, -half_scr_w, -half_scr_h)
	local cam_3d_ang = IsValid(LocalPlayer():GetObserverTarget()) and Angle(0, 0, 0) or CamUIService.eye_angle_2.smooth/cam_angle_divider

	surface.DisableClipping(false)

	for i, pnl in pairs(CamUIService.panels) do
		if IsValid(pnl) then
			CamUIService.RenderPanel(pnl, scr_w, scr_h, half_scr_w, half_scr_h, cam_3d_vec, cam_3d_ang)
		end
	end

	surface.DisableClipping(true)
end
hook.Add("DrawCamUI", "CamUIService.Render", CamUIService.Render)

local cam_3d2d_angle = Angle(0, -90, 90)
local cam_3d2d_matrix_angle = Angle(0, -90, 270)

function CamUIService.RenderPanel(pnl, scr_w, scr_h, half_scr_w, half_scr_h, cam_3d_vec, cam_3d_ang)
	local scr_w_offset = scr_w * pnl.cam_rotate_origin_x
	local scr_h_offset = scr_h * pnl.cam_rotate_origin_y
	local offset_ang = pnl.cam_angle.current

	local offset_vec = Vector(scr_w_offset, scr_h_offset, 0)
	offset_vec:Rotate(Angle(offset_ang.y, offset_ang.r, offset_ang.p))

	cam.Start3D(cam_3d_vec, (cam_3d_ang/pnl.cam_smooth_divider.current) * CamUIService.cam_smooth_multiplier.current, 90)

	cam.Start3D2D(
		Vector((half_scr_w * (pnl.cam_distance.current + 1)) - offset_vec.z, offset_vec.x - scr_w_offset, offset_vec.y - scr_h_offset),
		cam_3d2d_angle + Angle(offset_ang.r, -offset_ang.y, offset_ang.p),
		1
	)

	-- local mat = Matrix()
	-- mat:Translate(Vector(0, -half_scr_w, -half_scr_h))
	-- mat:Scale(Vector(1, 1, 1))
	-- mat:Translate(Vector(0, half_scr_w, half_scr_h))
	-- mat:Translate(Vector((half_scr_w * (pnl.cam_distance.current + 1)) - offset_vec.z, offset_vec.x - scr_w_offset, offset_vec.y - scr_h_offset))
	-- mat:Rotate(cam_3d2d_matrix_angle + Angle(offset_ang.r, -offset_ang.y, offset_ang.p))
	-- cam.PushModelMatrix(mat)

	cam.IgnoreZ(true)

	local parent = pnl:GetParent()

	if IsValid(parent) and not parent.camui_panel then
		surface.SetAlphaMultiplier(parent:GetAlpha()/255)
	end

	pnl:PaintManual()
	surface.SetAlphaMultiplier(1)
	cam.IgnoreZ(false)

	-- cam.PopModelMatrix()

	cam.End3D2D()
	cam.End3D()
end

function CamUIService.ResetCamAngle()
	CamUIService.eye_angle_2:Freeze()
end
hook.Add("LocalPlayerSpawn", "CamUIService.ResetCamAngle", CamUIService.ResetCamAngle)
hook.Add("OnReloaded", "CamUIService.ResetCamAngle", CamUIService.ResetCamAngle)