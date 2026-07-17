# Damage — the safety rules

- NPC hurts player: on Touched (or a ranged check), server-side, with a
  debounce per victim (e.g. 10 damage max once per second). Never
  per-Touched-event raw damage — that's instant death by event spam.
- Player hurts NPC: sword Touched or click-target → server validates
  distance ("is the attacker actually near it?") before applying damage.
  A RemoteEvent that says "I hit the zombie for 50" violates
  roblox-safe-scripting — the server decides hits and numbers.
- NPC death: `Humanoid.Died` → award coins/XP server-side, play a small
  effect, `Debris:AddItem(model, 3)` to clean the corpse, respawn on a timer.
- NPCs must never damage other NPCs of the same tag (zombies fighting each
  other looks broken) — check the tag before applying damage.
