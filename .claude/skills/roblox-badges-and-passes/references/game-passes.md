# Game passes (one-time-per-player unlocks)

A game pass is a **permanent, one-off** unlock per player (VIP door, skip a
level, double coins forever) bought once with Robux. It is created on the
Creator Dashboard (name, price, icon) — Dave's job, same as a badge.

```lua
local MarketplaceService = game:GetService("MarketplaceService")

local function playerOwnsPass(player, passId)
    local ok, owns = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
    end)
    return ok and owns
end

-- from a "Buy VIP" button, client-side:
-- MarketplaceService:PromptGamePassPurchase(player, passId)
```

- **Always check ownership server-side** with `UserOwnsGamePassAsync` before
  granting the perk — never trust a client's claim that a purchase went
  through.
- The simplest robust pattern for a first game: don't try to catch the exact
  moment a purchase finishes — just re-check `UserOwnsGamePassAsync` every
  time ownership matters (e.g. every time the player reaches the VIP door).
  Ownership persists forever once bought, so this is cheap and can't miss.
- `PromptGamePassPurchase` is what actually opens Roblox's purchase dialog
  — call it from a client script on a button press.
- **`ProcessReceipt` does NOT apply to game passes** — see
  `references/developer-products.md`.

_verified: 2026-07-17 — confirm exact method names/signatures and the
purchase-finished event name (if using one instead of re-checking ownership)
at create.roblox.com/docs before relying._
