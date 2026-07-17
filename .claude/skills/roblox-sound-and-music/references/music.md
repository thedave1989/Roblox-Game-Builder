# Background music (looping)

```lua
local music = Instance.new("Sound")
music.SoundId = "rbxassetid://<id>"
music.Looped = true
music.Volume = 0.2                -- quieter than effects, on purpose
music.Parent = game:GetService("SoundService")
music.Playing = true
```

- Music usually wants **map-wide**, not positional — parent to
  `SoundService` (or Workspace) rather than a single part, unless the goal
  is specifically "music only inside this one room" (then parent it to a
  part/region in that room instead, same as world ambience).
- **Conservative default volume, and lower than effects/UI sounds** — start
  around `0.15–0.3`. Music that drowns out a coin-pickup chime or a warning
  sound is a common beginner mistake; effects should always still be
  audible over it.
- One looping Sound is enough for a first game. Track/playlist switching,
  fade-between-songs, and per-area music zones are "ideas for later".
