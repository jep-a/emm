function MinigameService.CallNetHook(lobby, hk_name, ...)
	MinigameService.CallHook(lobby, hk_name, ...)
	NetService.Broadcast("Minigame."..hk_name, lobby, ...)
end

function MinigameService.CallNetHookWithoutMethod(lobby, hk_name, ...)
	MinigameService.CallHookWithoutMethod(lobby, hk_name, ...)
	NetService.Broadcast("Minigame."..hk_name, lobby, ...)
end