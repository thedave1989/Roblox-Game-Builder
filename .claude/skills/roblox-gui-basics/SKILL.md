---
name: roblox-gui-basics
description: On-screen UI — coin counters, shop windows, banners, health bars. ScreenGui structure, phone-safe sizing, wiring GUI to server values. For the stylist (who builds most UI) and builder. Never shown to the player.
---

# Roblox GUI Basics

How to put things on the screen. The stylist owns most UI steps; the builder
touches GUI when a mechanic needs a display. STYLE.md decides every colour
and font used here — this file only decides structure.

## Where GUI lives

- Player UI goes in **StarterGui** — one ScreenGui per feature, named clearly
  (`CoinCounterGui`, `ShopGui`). Studio copies StarterGui into each player's
  PlayerGui at spawn.
- The LocalScript that runs a GUI sits **inside that ScreenGui** — it finds
  its own buttons with `script.Parent`, no fragile long paths.
- Build the visual tree in Luau (Instance.new, properties, Parent last) so it
  installs like everything else — one INSTALL block, no hand-placed pixels.
- GUI on a part in the world (a shop sign, a floating name) → **BillboardGui**
  (faces the camera) or **SurfaceGui** (painted on a face).

## The structure that always works

```
ScreenGui (ResetOnSpawn = false for persistent HUD like coin counters)
└─ Frame            -- the panel: position, size, background from STYLE.md
   ├─ UICorner      -- rounded corners, kid-friendly chunky look
   ├─ TextLabel     -- words (set TextScaled = true)
   └─ TextButton    -- taps/clicks (one .Activated connection)
```

## Sizing that works on phones (most Roblox kids play on phones)

- `UDim2` is `(xScale, xOffset, yScale, yOffset)`. Use **Scale** for panel
  size/position (`UDim2.fromScale(0.25, 0.1)`); Offset-only UI is invisible-
  tiny or screen-eating on other devices.
- `AnchorPoint` pins the element by its centre/corner:
  centre-screen = `AnchorPoint (0.5, 0.5)` + `Position fromScale(0.5, 0.5)`.
  Top-right HUD = `AnchorPoint (1, 0)` + `Position fromScale(0.98, 0.02)`.
- `TextScaled = true` on every label/button; add `UITextSizeConstraint`
  (MaxTextSize ~40) so text can't get comically huge.
- Rows/grids of items (shop!) → `UIListLayout` / `UIGridLayout` inside a
  Frame — never hand-position ten buttons.
- Buttons: use `.Activated` (fires for tap AND click), not MouseButton1Click.

## Wiring GUI to game values (the pattern for every counter/bar)

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

## Feel (cheap polish that reads as quality)

- Show/hide with `.Visible`, or tween Position to slide panels in —
  TweenService works on GUI properties too. 0.2–0.3s tweens feel right.
- Button feedback: tween Size to 1.05× on press and back. One connection.
- Space with `UIPadding`, don't cram. Fewer, bigger elements always beats
  many small ones — this is a kid's game on a phone.

## Gotchas

- A LocalScript under StarterGui only runs after spawn — always WaitForChild
  for game objects; never assume leaderstats exists on frame one.
- `ResetOnSpawn` defaults to TRUE: your HUD vanishes on death unless you set
  it false (persistent HUD) or rebuild on respawn (per-life UI).
- Test in Studio's device emulator sizes mentally: would this fit a phone?
  If a panel needs a close button, make it big and top-right.
