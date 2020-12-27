hook.Add("PlayerSay", "CommandSerive.PlayerSay", function(ply, text)
	hook.Call("OnChat", nil, ply, text)
end)