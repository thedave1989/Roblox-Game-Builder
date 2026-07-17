---
name: roblox-luau-basics
description: Core Luau + Roblox Studio patterns — script types and where they live, services, events, leaderstats, and load-safety. Read before writing ANY script. For agents, never shown to the player.
---

# Roblox Luau Basics

The ground rules for every script this framework writes. When code you're
about to write disagrees with this file, this file wins.

## Script types and where they go

| Suffix (our files)  | Studio object | Runs on | Standard home |
| ------------------- | ------------- | ------- | ------------- |
| `.server.luau`      | Script        | server  | ServerScriptService |
| `.client.luau`      | LocalScript   | player's device | StarterPlayer > StarterPlayerScripts (or StarterGui for UI code) |
| `.module.luau`      | ModuleScript  | whoever requires it | ReplicatedStorage (shared) or ServerScriptService (server-only) |

- Game logic, money, saving → server Scripts. Camera, input, GUI → LocalScripts.
- RemoteEvents/RemoteFunctions and shared ModuleScripts live in **ReplicatedStorage**.
- Anything the client must never see (secret values, server modules) → **ServerStorage** / ServerScriptService.

## Services

Always `local Players = game:GetService("Players")` — never `game.Players` dot-access.
Common ones: Players, Workspace, ReplicatedStorage, ServerStorage, TweenService,
DataStoreService, RunService, UserInputService (client), CollectionService.

## Load-safety (the #1 crash source)

- Things load in over time. Use `:WaitForChild("Name")` for anything a script
  needs at startup; use `:FindFirstChild("Name")` + a nil-check when the thing
  might legitimately not exist.
- New instances: set all properties first, set `.Parent` **last**.
- Use the `task` library: `task.wait(n)`, `task.spawn(fn)`, `task.defer(fn)`.
  Never a loop without a `task.wait()` inside.

## Events you'll use constantly

```lua
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        -- character exists now; character:WaitForChild("Humanoid")
    end)
end)
```

Touch with debounce (touched fires many times per touch):

```lua
local busy = {}
part.Touched:Connect(function(hit)
    local player = Players:GetPlayerFromCharacter(hit.Parent)
    if not player or busy[player] then return end
    busy[player] = true
    -- do the thing once
    task.wait(1)
    busy[player] = nil
end)
```

- Clickable things: prefer **ProximityPrompt** (walk up + press E) or
  **ClickDetector**. Both have server-side events — keep the logic there.

## leaderstats (the score column every Roblox player knows)

```lua
Players.PlayerAdded:Connect(function(player)
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"           -- exact name, lowercase, required
    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Parent = stats
    stats.Parent = player
end)
```

Only the **server** ever changes leaderstats values.

## Making things move and look alive

- Smooth movement/colour/size changes → **TweenService** on the server for
  world objects, on the client for GUI. Never move parts with a bare loop
  when a tween does it.
- Per-frame work (`RunService.Heartbeat`) is a last resort — it runs 60×/sec
  and costs accordingly. Cap what it touches.

## Small-but-important habits

- Names matter: scripts find things by exact name. One typo = nil.
- Anchor parts that shouldn't fall (`part.Anchored = true`).
- `Instance.new("Part")` defaults to unanchored grey 4×1×2 — set Size,
  Position, Color/Material (from game/STYLE.md), Anchored, then Parent.
- Attributes (`part:SetAttribute("Stage", 3)`) beat hidden ValueObjects for
  tagging data onto parts.
- Comments: plain English, one per meaningful chunk — a curious kid reads these.
