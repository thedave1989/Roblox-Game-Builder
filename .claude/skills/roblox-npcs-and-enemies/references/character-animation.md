# Character animation (walk/idle/attack)

An animated rig plays animations through its Humanoid's `Animator` child
(most default R15/R6 rigs already have one; if a template is missing it,
`Instance.new("Animator", humanoid)` adds it):

```lua
local anim = Instance.new("Animation")
anim.AnimationId = "rbxassetid://<id>"

local track = npc.Humanoid.Animator:LoadAnimation(anim)
track.Looped = true
track:Play()
-- later: track:Stop()
```

You'll also see the older `humanoid:LoadAnimation(anim)` form (calling
`LoadAnimation` directly on the Humanoid instead of its Animator) in a lot
of existing examples online — it still works, but `Animator:LoadAnimation`
is the currently-preferred shape. Confirm whichever form Studio's
autocomplete actually offers before relying on one.

## Ownership and cleanup

- NPC animation is **server-side**, same as all other NPC logic — the
  server Script that spawns/controls the NPC is what loads and plays its
  tracks, never a client.
- **Load each track once per NPC, when it spawns**, and keep a reference to
  it (e.g. in a table keyed by the NPC model) — call `:Play()`/`:Stop()` on
  that same track for state changes (start walking, stop walking, attack).
  Loading a fresh `Animation` + `LoadAnimation` every time is wasteful and a
  common source of "my zombie animates weird" bugs.
- Cleanup happens for free when the NPC model is destroyed — its Animator
  and tracks go with it. The thing to actually watch is leaked *connections*
  (e.g. `track.Stopped:Connect(...)`) outliving the model; disconnect them,
  or scope them so they only fire while the model still exists.
- A default Player character walks/idles automatically because Roblox's own
  "Animate" script ships with it. A cloned NPC template usually does **not**
  come with that for free — if a spawned enemy just slides around T-posed
  instead of visibly walking, that's the missing piece: it needs its own
  walk/idle tracks loaded and switched based on `Humanoid.MoveDirection`
  (non-zero → play walk, zero → play/keep idle) or `Humanoid:GetState()`.

_verified: 2026-07-17 — confirm the exact current-recommended LoadAnimation
form (Animator vs Humanoid) at create.roblox.com/docs before relying._
