# Feel (cheap polish that reads as quality)

- Show/hide with `.Visible`, or tween Position to slide panels in —
  TweenService works on GUI properties too. 0.2–0.3s tweens feel right.
- Button feedback: tween Size to 1.05× on press and back. One connection.
- Space with `UIPadding`, don't cram. Fewer, bigger elements always beats
  many small ones — this is a kid's game on a phone.

# Gotchas

- A LocalScript under StarterGui only runs after spawn — always WaitForChild
  for game objects; never assume leaderstats exists on frame one.
- `ResetOnSpawn` defaults to TRUE: your HUD vanishes on death unless you set
  it false (persistent HUD) or rebuild on respawn (per-life UI).
- Test in Studio's device emulator sizes mentally: would this fit a phone?
  If a panel needs a close button, make it big and top-right.
