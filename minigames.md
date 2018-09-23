# Minigames

## MinigamePrototype

Prototypes are the actual classes that contain the logic and hooks for minigames. This is where you configure minigame properties and player classes.

```lua
MinigamePrototype {
	player_classes = {},

	states = {
		{
			name = "Waiting",
			next = "Starting"
		},
		{
			name = "Starting",
			time = 3,
			next = "Playing"
		},
		{
			name = "Playing",
			next = "Ending"
		},
		{
			name = "Ending",
			time = 3,
			next = "Starting"
		}
	},

	hooks = {
		PlayerLeave = {
			RequirePlayers = function () ... end -- Sets the state to Waiting if there's not enough players
		}
	},

	state_hooks = {
		Waiting = {
			PlayerLeave = {
				RequirePlayers = function () ... end -- Progresses the state if there's enough players
			}
		}
	},

	default_state = "Waiting",

	require_players = 2
}
```

### MinigameState

Prototypes have different states like `Waiting` (not enough players), `Starting` (round start countdown), and `Playing` (actual minigame starts). You can add different states and change the default ones. Each state has a next state and an optional duration until the next state.

### PlayerClass

PlayerClasses are tables of properties like `color` and `can_walljump` that will override a player's default properties.

```lua
PlayerClass {
	name = "Hunted",
	color = COLOR_ORANGE,
	can_tag = {"Hunter"}
}
```

### Hooks

Minigame hooks work like Garry's Mod hooks. Additionally you can add hooks that only work in a specific state.

- `PlayerJoin(player)/Playerleave`
- `StartState{state_name}(state)`
- `Tag(player taggable, player tagger)` (server-side only)
- `PlayerSpawn(player)`
- `PlayerProperties(player)`
- `PrePlayerDeath(player, entity attacker)`
- `PlayerDeath(player, entity inflictor, entity attacker)`
- `PostPlayerDeath(player)` (client-side only)

### Methods
- `SetAdjustableSettings(table modifiable_variables)` sets what properties can be edited by lobby hosts.
- `AddPlayerClass(table player_class)`
- `AddHook(string hook_name, string identifier, function)/RemoveHook`
- `AddStateHook(string state_name, string hook_name, string identifier, function)/RemoveStateHook`

## MinigameLobby

Lobbies are instantiated prototypes. These hold properties like the current host, players, and other meta-information.

```lua
MinigameLobby {
	prototype
	host = player
	players = {}
}
```

### Methods
- `__index` first looks in the prototype and then the MinigameLobby metatable.
- `Init/Finish`
- `GetSanitized` returns a JSON friendly version of the lobby for the JSUI.
- `IsLocal` (client-side only)
- `SetHost(player)`
- `AddPlayer(player)/RemovePlayer`
- `SetState(table state)`