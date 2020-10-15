AutoJumpService = AutoJumpService or {}


-- # Properties

function AutoJumpService.InitPlayerProperties(ply)
	ply.can_autojump = false
	ply.force_autojump = false
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"AutoJumpService.InitPlayerProperties",
	AutoJumpService.InitPlayerProperties
)
-- hook.Add("InitPlayerClassProperties", "AutoJumpService.InitPlayerClassProperties", AutoJumpService.InitPlayerProperties)


-- # Autojump

function AutoJumpService.AutoJump(ply, move)
	if
		ply.can_autojump and
		(move:KeyDown(IN_JUMP) or ply.force_autojump) and
		ply:IsOnGround()
	then
		move:SetOldButtons(bit.band(move:GetOldButtons(), bit.bnot(IN_JUMP)))
		move:SetButtons(bit.bor(move:GetButtons(), IN_JUMP))
	end
end
hook.Add("SetupMove", "AutoJumpService.AutoJump", AutoJumpService.AutoJump)