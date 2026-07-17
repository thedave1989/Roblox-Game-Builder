# World ambience (continuous background sound)

Positional (fades with distance — for one area, e.g. a waterfall):

```lua
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://<id>"
sound.Looped = true
sound.Volume = 0.4
sound.Parent = waterfallPart      -- Parent = the world object → 3D
sound.Playing = true
```

Map-wide (no falloff — wind, background hum):

```lua
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://<id>"
sound.Looped = true
sound.Volume = 0.25
sound.Parent = game:GetService("SoundService")
sound.Playing = true
```

- Set these up **server-side** (or authored once at build time) — a Sound's
  `Playing`/`Looped`/`SoundId` are ordinary properties, so setting them from
  the server is enough for every player to hear the same thing at the same
  time; no RemoteEvent needed for something everyone always hears.
- Conservative default volume, same reasoning as everywhere else in this
  skill — ambience should sit under gameplay sounds, not compete with them.
