# Daily rewards and login streaks

Store the last claim as a plain server-side timestamp or date string inside
the normal save data — it goes through the exact same load/save/pcall
discipline as coins or stage, it's just another field:

```lua
-- server-side only; never trust a client's idea of "what day it is"
local today = os.date("!*t")   -- UTC, so it can't be gamed by a device's local clock
local last = data.lastClaim    -- e.g. {year=..., month=..., day=...} from a previous claim
```

- Compare using **the server's clock**, never anything the client reports —
  a device's local time/date can be changed by the player, which would
  otherwise let them claim "tomorrow's" reward instantly.
- Streak logic: if the new claim date is exactly one calendar day after
  `lastClaim`, increment the streak; if a day (or more) was skipped, reset
  the streak to 1; claiming again on the same day is simply not allowed
  (check before granting anything).
- Save `lastClaim` and the streak count as part of the same save write that
  grants the reward — don't grant first and save later, or a crash between
  the two lets someone re-claim.
