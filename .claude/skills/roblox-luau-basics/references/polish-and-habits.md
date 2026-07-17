# Making things move and look alive

- Smooth movement/colour/size changes → **TweenService** on the server for
  world objects, on the client for GUI. Never move parts with a bare loop
  when a tween does it.
- Per-frame work (`RunService.Heartbeat`) is a last resort — it runs 60×/sec
  and costs accordingly. Cap what it touches.

# Small-but-important habits

- Names matter: scripts find things by exact name. One typo = nil.
- Anchor parts that shouldn't fall (`part.Anchored = true`).
- `Instance.new("Part")` defaults to unanchored grey 4×1×2 — set Size,
  Position, Color/Material (from game/STYLE.md), Anchored, then Parent.
- Attributes (`part:SetAttribute("Stage", 3)`) beat hidden ValueObjects for
  tagging data onto parts.
- Comments: plain English, one per meaningful chunk — a curious kid reads these.
