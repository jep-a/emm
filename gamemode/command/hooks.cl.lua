hook.Add("OnPlayerChat", "CommandSerive.OnPlayerChat", function(ply, text)
	return hook.Call("OnChat", nil, ply, text)
end)