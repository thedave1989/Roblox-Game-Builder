# Day/night lighting and mood

```lua
local Lighting = game:GetService("Lighting")
Lighting.ClockTime = 18          -- 0-24 hour clock; 18 ≈ sunset
Lighting.Brightness = 2
Lighting.OutdoorAmbient = Color3.fromRGB(120, 120, 140)   -- overall scene tint
```

- `ClockTime` sets a fixed time of day — good enough for most first games;
  a day/night **cycle** is just a server script slowly incrementing it in a
  loop, which is a step of its own, not a default.
- `Ambient` / `OutdoorAmbient` set the general fill light/tint of the whole
  scene — this is what makes a moment feel "warm sunset" vs "cold night"
  more than any single light does.
- Sky/atmosphere objects and fog live under `Lighting` too — the stylist
  drives these from `game/STYLE.md`'s Sky & lighting section, via a setup
  script, never by freelancing new values.
