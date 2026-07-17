# Event sounds (coin pickup, NPC hit, level-up, explosion)

```lua
-- server-side, at the same moment the event is decided
local sound = coinPart:FindFirstChild("PickupSound")
if sound then sound:Play() end
```

- If the sound announces something that happened in the **shared game
  world** (a coin was collected, an enemy died, a round started) — trigger
  it from the **same server code that decided the event happened**
  (roblox-safe-scripting's server-authority rule applies to the trigger,
  not really to the sound itself). Parenting the Sound to the relevant part
  keeps it positional and in sync for everyone nearby.
- If it's private feedback about the **player's own UI** only (see
  `references/ui.md`), client-side is simpler and doesn't need this.
- Conservative default volume (`0.3–0.6` is a reasonable range for effects —
  a bit louder than ambience, quieter than a full-volume alarm).
