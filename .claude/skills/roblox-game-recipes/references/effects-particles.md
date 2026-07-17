# Effects: Particles (sparkles, confetti, smoke, bursts)

```lua
local emitter = Instance.new("ParticleEmitter")
emitter.Parent = part          -- or an Attachment on the part
emitter.Enabled = false        -- start off; burst on demand
```

Key properties: `Texture`, `Rate` (continuous emission), `Lifetime`,
`Speed`, `Color` (a ColorSequence), `Size` (a NumberSequence). For a one-shot
burst (finish-line confetti, a coin pop) leave `Enabled = false` and call
`emitter:Emit(20)` at the moment it should fire, rather than toggling
Enabled on/off.

## Client-cosmetic vs server-authoritative

Particle effects are almost always **pure cosmetic** — no gameplay depends
on exactly where a particle renders. The trigger that decides *whether* the
effect should happen (did the player actually win, actually collect the
coin) is still server-decided per roblox-safe-scripting; the emitter itself
is just a property (`Enabled`, or an `:Emit()` call) that replicates fine
when set from the server, so the whole moment stays in sync for everyone
watching without needing a RemoteEvent. A "just for me" flourish (my own
screen-only sparkle) can be done purely client-side instead.
