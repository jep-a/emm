function MinigameService.CallNetHook(lobby, hk_name, ...)
	MinigameService.CallHook(lobby, hk_name, ...)
	NetService.Broadcast("Minigame."..hk_name, lobby, ...)
end