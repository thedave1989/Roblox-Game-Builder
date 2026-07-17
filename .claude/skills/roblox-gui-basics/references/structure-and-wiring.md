# The structure that always works

```
ScreenGui (ResetOnSpawn = false for persistent HUD like coin counters)
└─ Frame            -- the panel: position, size, background from STYLE.md
   ├─ UICorner      -- rounded corners, kid-friendly chunky look
   ├─ TextLabel     -- words (set TextScaled = true)
   └─ TextButton    -- taps/clicks (one .Activated connection)
```

# Wiring GUI to game values (the pattern for every counter/bar)

Client displays, server owns (roblox-safe-scripting rules apply):

```lua
-- LocalScript inside CoinCounterGui
local player = game:GetService("Players").LocalPlayer
local label = script.Parent:WaitForChild("Frame"):WaitForChild("Amount")
local coins = player:WaitForChild("leaderstats"):WaitForChild("Coins")

local function show(v) label.Text = tostring(v) end
show(coins.Value)
coins.Changed:Connect(show)          -- fires whenever the server changes it
```

- Health bar = same idea: Humanoid.HealthChanged → set an inner Frame's
  X-scale to `health / humanoid.MaxHealth`.
- Shop buy button: `.Activated` → fire the buy RemoteEvent (name only —
  the server owns prices, per roblox-safe-scripting).
- Announcements ("Round starting!"): server FireAllClients → one listening
  LocalScript sets a banner's text, shows it, `task.wait(3)`, hides it.
