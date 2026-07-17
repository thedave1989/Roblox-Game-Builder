---
name: roblox-player-data
description: Persist progress safely with native DataStores only — load/save discipline, schema versions, request budgets, autosave, and daily/streak state. For the builder. Never shown to the player.
---

# Roblox Player Data

Losing a kid's progress is the worst outcome this framework can produce.
DataStores are **server-only** — never call them from a LocalScript — and
every call sits in `pcall`, because they fail routinely and a script that
doesn't expect that will silently eat someone's save.

For the core safe-save pattern (pcall discipline, keying by UserId, never
overwriting on a failed load) see `roblox-safe-scripting`'s
saving-with-datastores card — that's the floor everyone follows. This skill
goes deeper: schema/migration, request budgets, autosave cadence, shutdown
handling, and streak-style daily state.

**leaderstats are not persistence** — see `roblox-luau-basics`'s leaderstats
card. A DataStore holds the real number; leaderstats is just today's display
of it.

## Reference cards — load the one the step needs

| Load when the step... | Card |
|---|---|
| Loads a player's save on join | [references/load.md](references/load.md) |
| Saves progress (on leave, on a timer, on shutdown) | [references/save.md](references/save.md) |
| Adds a new field/feature to data that already has old saves | [references/migration.md](references/migration.md) |
| Needs a daily reward or a login streak | [references/daily-state.md](references/daily-state.md) |
