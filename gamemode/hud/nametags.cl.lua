NametagService = NametagService or {}

local hide_radius = 32
local nametag_alpha_smooth_multiplier = 4

local function NametagAlpha(ent)
	local alpha

	local not_near_crosshair

	if ent.indicator_x and ent.indicator_y then
		not_near_crosshair = math.sqrt(((ent.indicator_x - (ScrW()/2)) ^ 2) + ((ent.indicator_y - (ScrH()/2)) ^ 2)) > hide_radius
	end

	if IsValid(ent) and GhostService.Alive(LocalPlayer()) and not_near_crosshair and (
		not IsPlayer(ent) or
		GhostService.Alive(ent)
	) then
		if MinigameService.IsSharingLobby(ent) then
			alpha = 255
		elseif ent.visible and ent.visible >= 0.5 then
			alpha = HALF_ALPHA
		else
			alpha = 0
		end
	else
		alpha = 0
	end

	return alpha
end

function NametagService.PlayerName(ply)
	local text

	if IsLocalPlayer(ply) then
		text = "you"
	else
		text = ply:GetName()
	end

	return text
end

function NametagService.InitEntityProperties(ent)
	ent.nametag_alpha = AnimatableValue.New(0, {
		smooth = true,
		smooth_multiplier = nametag_alpha_smooth_multiplier,

		generate = function ()
			return NametagAlpha(ent)
		end
	})
end
hook.Add("InitPlayerProperties", "NametagService.InitPlayerProperties", NametagService.InitEntityProperties)

function NametagService.FinishPlayerProperties(ply)
	ply.nametag_alpha:Finish()
end
hook.Add("PlayerDisconnected", "NametagService.FinishPlayerProperties", NametagService.FinishPlayerProperties)

function NametagService.InitEntityProperties(ent)
	ent.nametag_alpha = AnimatableValue.New(0, {
		smooth = true,
		smooth_multiplier = nametag_alpha_smooth_multiplier,

		generate = function ()
			return NametagAlpha(ent)
		end
	})
end
hook.Add("LobbyEntityProperties", "NametagService.InitEntityProperties", NametagService.InitEntityProperties)

function NametagService.FinishEntityProperties(lobby, ent)
	ent.nametag_alpha:Finish()
end
hook.Add("LobbyEntityRemove", "NametagService.FinishEntityProperties", NametagService.FinishEntityProperties)

function NametagService.Name(ent)
	return ent.indicator_name or ent.GetIndicatorName and ent:GetIndicatorName() or NametagService.PlayerName(ent)
end

function NametagService.Draw()
	if SettingsService.Get "show_nametags" then
		local plys = player.GetAll()
		local lobby = LocalPlayer().lobby

		for i = 1, #plys do
			local ply = plys[i]

			if ply.nametag_alpha then
				local alpha = ply.nametag_alpha.smooth

				if alpha > 0 then
					surface.SetFont "Nametag"

					local ply_name = string.upper(NametagService.Name(ply))
					local w, h = surface.GetTextSize(ply_name)
					local color = GetAnimatableEntityColor(ply)

					local dist_offset

					if MinigameService.IsSharingLobby(ply) or IsLocalPlayer(ply) then
						dist_offset = Lerp(ply.indicator_distance/800, 32, 24)
					else
						dist_offset = Lerp(ply.indicator_distance/800, 16, 8)
					end

					surface.SetTextColor(ColorAlpha(color, CombineAlphas(color.a, alpha) * 255))
					surface.SetTextPos(ply.indicator_x - (w/2), ply.indicator_y - (h/2) - dist_offset)
					surface.DrawText(ply_name)
				end
			end
		end

		if lobby then
			local ents = lobby.entities

			for i = 1, #ents do
				local ent = ents[i]
				local ent_name = NametagService.Name(ent)

				if ent_name then
					local alpha = ent.nametag_alpha.smooth

					if alpha > 0 then
						surface.SetFont "Nametag"

						local upper_name = string.upper(ent_name)
						local w, h = surface.GetTextSize(upper_name)
						local color = GetAnimatableEntityColor(ent)
						local dist_offset = Lerp(ent.indicator_distance/800, 32, 24)

						surface.SetTextColor(ColorAlpha(color, CombineAlphas(color.a, alpha) * 255))
						surface.SetTextPos(ent.indicator_x - (w/2), ent.indicator_y - (h/2) - dist_offset)
						surface.DrawText(upper_name)
					end
				end
			end
		end
	end
end
hook.Add("DrawNametags", "NametagService.Draw", NametagService.Draw)

function GM:HUDDrawTargetID()
	--
end