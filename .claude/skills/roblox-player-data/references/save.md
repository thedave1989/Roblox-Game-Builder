# Saving: cadence, budgets, retries, shutdown

- **Don't save on every change.** Save on `Players.PlayerRemoving`, on a
  periodic timer (every few minutes is plenty for a first game), and in
  `game:BindToClose` for server shutdown — without the shutdown save, the
  last few minutes of everyone's progress vanish when the server closes.
- **Request budgets are real.** DataStore calls are rate-limited per
  experience; treat the exact numbers as something to confirm rather than
  hard-code (Roblox has changed the formula before) — the practical rule
  that doesn't depend on the exact number: save on leave + interval +
  shutdown only, never per-event (never "save on every coin").
- **Bounded retries, not infinite ones.** On a failed save: wait a few
  seconds, try once more, then give up and log it — an unbounded retry loop
  can itself contribute to hitting the budget.
- **`UpdateAsync` over blind `SetAsync`** for anything that must survive two
  saves racing each other (a global counter, anything more than one server
  could touch) — it hands you the previous value atomically so you can merge
  instead of overwrite.
- Never let a **failed load** lead to an automatic save of defaults — that's
  how a real save gets silently replaced with a blank one. This is the same
  rule as `roblox-safe-scripting`'s pattern, worth restating because it's
  the single most damaging mistake possible here.
