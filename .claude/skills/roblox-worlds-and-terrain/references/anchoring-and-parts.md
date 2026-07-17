# Parts, models, pivots, and spawns

- `Anchored = true` on every static Part — ground, walls, buildings,
  decoration that shouldn't be pushed or fall. Dynamic props (something
  meant to fall or be pushed) are the deliberate exception, not the default.
- Grouping several parts into a **Model**: use `Model:PivotTo(cframe)` to
  move or rotate the whole thing at once (the modern, preferred way); you
  may still see the older `PrimaryPart` approach in examples, which sets one
  part as the reference point instead.
- `CanCollide`: leave `true` for solid ground/walls; set `false` on dense
  decoration (foliage, fine detail) so players don't get stuck on doodads —
  it's also cheaper for physics.

## SpawnLocation

```lua
local spawn = Instance.new("SpawnLocation")
spawn.Anchored = true
spawn.Neutral = true      -- true = anyone can spawn here (no team restriction)
spawn.Parent = workspace
```

Sit it flush with (or a hair above) the ground. Multiple SpawnLocations in a
place get picked between at random for each spawn.
