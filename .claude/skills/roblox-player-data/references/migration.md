# Schema versions and migration

Store a small `version` number **inside the saved table itself**, in
addition to versioning the store name (`PlayerSave_v1`) — belt and braces,
because a new feature can need new fields without needing a whole new store.

```lua
local DEFAULTS = { version = 2, coins = 0, stage = 1, ownsPet = false }

local function migrate(data)
    if data.version == nil then data.version = 1 end
    if data.version < 2 then
        data.ownsPet = data.ownsPet or false   -- v1 → v2: add the new field
        data.version = 2
    end
    return data
end
```

- Run migration right after a successful load, before anything else reads
  the data.
- Each step should be small, numbered, and **additive** — add a field with
  a sensible default rather than deleting or renaming one a still-loading
  older save might depend on.
- New players skip migration entirely — they start at `DEFAULTS` already at
  the current version.
