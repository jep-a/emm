NametagService = NametagService or {}

local hide_radius = 32
local height_offset = 24
local nametag_alpha_smooth_multiplier = 4

local function NametagAlpha(ply)
	local alpha

	local not_near_crosshair

	if ply.indicator_x and ply.indicator_y then
		not_near_crosshair = math.sqrt(((ply.indicator_x - (ScrW()/2)) ^ 2) + ((ply.indicator_y - (ScrH()/2) - height_offset) ^ 2)) > hide_radius
	end

	if IsValid(ply) and LocalPlayer():Alive() and (ply:Alive() or GhostService.IsGhostingWithoutRagdoll(ply)) and not_near_crosshair then
		if ply.indicator then
			alpha = 255
		elseif ply.visible >= 0.5 then
			alpha = HALF_ALPHA
		else
			alpha = 0
		end
	else
		alpha = 0
	end

	return alpha
end

function NametagService.InitPlayerProperties(ply)
	if not IsLocalPlayer(ply) then
		ply.nametag_alpha = AnimatableValue.New(0, {
			smooth = true,
			smooth_multiplier = nametag_alpha_smooth_multiplier,

			generate = function ()
				return NametagAlpha(ply)
			end
		})
	end
end
hook.Add("InitPlayerProperties", "NametagService.InitPlayerProperties", NametagService.InitPlayerProperties)

function NametagService.FinishPlayerProperties(ply)
	if not IsLocalPlayer(ply) then
		ply.nametag_alpha:Finish()
	end
end
hook.Add("PlayerDisconnected", "NametagService.FinishPlayerProperties", NametagService.FinishPlayerProperties)

function NametagService.Draw(ply)
	local plys = player.GetAll()

	for i = 1, #plys do
		local ply = plys[i]

		if not IsLocalPlayer(ply) and ply.nametag_alpha then
			local alpha = ply.nametag_alpha.smooth

			if alpha > 0 then
				surface.SetFont "Nametag"

				local ply_name = string.upper(ply:GetName())
				local w, h = surface.GetTextSize(ply_name)
				local color = GetAnimatableEntityColor(ply)

				surface.SetTextColor(ColorAlpha(color, CombineAlphas(color.a, alpha) * 255))
				surface.SetTextPos(ply.indicator_x - (w/2), ply.indicator_y - (h/2) - height_offset)
				surface.DrawText(ply_name)
			end
		end
	end
end
hook.Add("DrawNametags", "NametagService.Draw", NametagService.Draw)

function GM:HUDDrawTargetID()
	--
end