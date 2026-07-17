# Developer products (repeatable/consumable purchases)

A developer product is a **repeatable** paid purchase (100 coins, a revive,
a crate) — different from a game pass, which is a one-time unlock. Created
on the Creator Dashboard, Dave's job.

```lua
local MarketplaceService = game:GetService("MarketplaceService")

MarketplaceService.ProcessReceipt = function(receiptInfo)
    local granted = alreadyGranted(receiptInfo.PurchaseId)   -- your own tracking
    if not granted then
        local ok = pcall(function() grantProduct(receiptInfo) end)
        if not ok then
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end
        markGranted(receiptInfo.PurchaseId)
    end
    return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- from a "Buy 100 Coins" button, client-side:
-- MarketplaceService:PromptProductPurchase(player, productId)
```

- **`ProcessReceipt` is set once, for developer products only** — it is the
  callback Roblox invokes to actually deliver a consumable purchase, and it
  is **not** how game passes are handled (that's ownership checks, see
  `references/game-passes.md`). This split is the single easiest thing to
  get wrong in this whole area.
- **Must be idempotent.** Roblox can re-deliver the same receipt more than
  once — track which `receiptInfo.PurchaseId` values have already been
  granted (store it, same discipline as any other save data) so a
  re-delivery never grants double.
- Return `PurchaseGranted` once genuinely fulfilled; return `NotProcessedYet`
  if something failed and it should be retried later (e.g. a DataStore call
  inside the grant failed) — never silently swallow a failure.
- Never trust a client-side "purchase succeeded" message for anything —
  only a server-side `ProcessReceipt` call, which Roblox itself verifies,
  actually grants a product.

_verified: 2026-07-17 — this card is the highest stale-risk in the whole
skill roster. Confirm the exact `ProcessReceipt` signature, the
`ProductPurchaseDecision` enum values, and current idempotency guidance at
create.roblox.com/docs before relying on anything above beyond the
game-pass-vs-product split itself._
