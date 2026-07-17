# Badges

Badges are free — there's no purchase involved, so awarding one is lower-
stakes than passes/products, but creating the badge itself is still a
Creator Dashboard step (Dave uploads an icon, names it, writes a
description; Roblox reviews the icon before it's live) — never something
the builder does.

```lua
local BadgeService = game:GetService("BadgeService")

local function award(player, badgeId)
    local ok, hasIt = pcall(function()
        return BadgeService:UserHasBadgeAsync(player.UserId, badgeId)
    end)
    if ok and not hasIt then
        pcall(function() BadgeService:AwardBadge(player.UserId, badgeId) end)
    end
end
```

- Award server-side only, at the moment the achievement genuinely happens
  (finished the obby, beat the boss) — never on a client's say-so.
- Check `UserHasBadgeAsync` first so a repeat trigger doesn't waste a call
  or confuse the "you already have this!" messaging.
- Wrap the award call in `pcall`, same discipline as any other Roblox
  service call that talks to the backend.
- The badge's numeric ID (shown on the Dashboard after creation) is what
  the script needs — Dave supplies it.

_verified: 2026-07-17 — confirm the exact current `BadgeService` award
method (its name and whether it's synchronous or has an Async variant) and
the Creator Dashboard badge-creation flow/cost at create.roblox.com/docs
before relying on the specifics above._
