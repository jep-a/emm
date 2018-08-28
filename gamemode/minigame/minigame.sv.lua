function MinigameService.CallNetHook(lobby, hk_name, ...)
	NetService.Send("Minigame."..hk_name, lobby, ...)
end