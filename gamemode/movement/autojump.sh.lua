AutojumpService = AutojumpService or {}


-- # Properties

function AutojumpService.InitPlayerProperties(ply)
	ply.can_autojump = true
	ply.force_autojump = false
end
hook.Add(
	SERVER and "InitPlayerProperties" or "InitLocalPlayerProperties",
	"AutojumpService.InitPlayerProperties",
	AutojumpService.InitPlayerProperties
)


-- # Autojump

function AutojumpService.AutoJump(ply, cmd)
	if 	
		ply.can_autojump and
		(cmd:KeyDown(IN_JUMP) or ply.force_autojump) and
		ply:IsOnGround()
	then
		cmd:SetOldButtons(bit.band(cmd:GetOldButtons(), bit.bnot(IN_JUMP)))
		cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_JUMP))
	end
end
hook.Add("SetupMove", "AutojumpService.AutoJump", AutojumpService.AutoJump)