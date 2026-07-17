---
name: roblox-badges-and-passes
description: Celebrate and, carefully, monetise — BadgeService awards, game passes, and developer products. Loaded only from /publish's guided tail. Never shown to the player.
---

# Roblox Badges and Passes

**Hard rule, no exceptions:** any step touching Robux, a price, or making
the game/an item publicly purchasable goes to Dave. This skill explains the
mechanics so the *conversation* with Dave is informed — the builder never
creates a badge, a game pass, or a product listing itself; those are all
created on Roblox's own Creator Dashboard, a real account/payment surface.

Two systems that sound similar and are **not interchangeable**:

- **Badges** — free, a permanent "you did this" mark. `BadgeService`.
- **Game passes** — one-time-per-player paid unlocks. Checked with
  `UserOwnsGamePassAsync`, bought via `PromptGamePassPurchase`.
- **Developer products** — paid, repeatable/consumable purchases (100
  coins, a revive). Fulfilled through `ProcessReceipt` — **`ProcessReceipt`
  is for developer products only, never for game passes.** Mixing these up
  is the single most common mistake in this area.

## Reference cards — load the one the step needs

| Load when the step... | Card |
|---|---|
| Awards a badge for an achievement | [references/badges.md](references/badges.md) |
| Checks or sells a game pass (a one-time unlock) | [references/game-passes.md](references/game-passes.md) |
| Sells something repeatable/consumable (coins, a revive) | [references/developer-products.md](references/developer-products.md) |
