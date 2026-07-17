# Loading a save

```lua
local function load(player)
    local ok, data = pcall(function() return store:GetAsync("p_" .. player.UserId) end)
    if not ok then
        warn("load failed for", player.Name)
        return nil, false     -- false = "load did not succeed" — do NOT treat as new player
    end
    return data, true         -- data may legitimately be nil here: a genuinely new player
end
```

- Two different "no data" cases that must never be confused: **`GetAsync`
  succeeding with `nil`** (a real new player — safe to hand them defaults)
  vs **the `pcall` itself failing** (network/service problem — the player
  might have a real save that just couldn't be read right now). Track which
  one happened; only the first is safe to treat as "start fresh".
- Server-only. A LocalScript has no business calling `GetAsync` — if a step
  seems to need that, the design is wrong; load server-side and hand the
  player their numbers via leaderstats/RemoteEvent instead.
- Studio testing needs **Game Settings → Security → Enable Studio Access to
  API Services** ticked once, or every load/save silently fails while
  testing — the same toggle `roblox-safe-scripting` and `roblox-fix-recipes`
  mention; it only applies to a saved/published place, not an unsaved one.
