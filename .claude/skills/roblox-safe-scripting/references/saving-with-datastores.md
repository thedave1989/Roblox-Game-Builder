# Saving with DataStores (native only)

Community save modules (ProfileService etc.) are marketplace requires — this
framework never requires marketplace assets. Native DataStoreService does
everything a first game needs:

```lua
local store = game:GetService("DataStoreService"):GetDataStore("PlayerSave_v1")

local function load(player)
    local ok, data = pcall(function() return store:GetAsync("p_" .. player.UserId) end)
    if ok then return data end          -- nil is fine: new player
    warn("load failed for", player.Name)
    return nil                          -- NEVER overwrite a real save with defaults after a FAILED load
end

local function save(player, data)
    local ok, err = pcall(function() store:SetAsync("p_" .. player.UserId, data) end)
    if not ok then task.wait(3) pcall(function() store:SetAsync("p_" .. player.UserId, data) end) end
end
```

- **Every** DataStore call sits in `pcall`. They fail routinely.
- Save on `Players.PlayerRemoving` AND in `game:BindToClose` (server shutdown
  — without it, the last few minutes of everyone's progress vanish).
- Don't save on every coin. Save on leave + every few minutes. Budgets are real.
- Counters that must survive races (global stats) → `UpdateAsync`, not Get+Set.
- Key by `UserId` (never player name — names change). Version the store name
  (`_v1`) so a format change can't corrupt old saves.
- Track "load succeeded" per player; if their load FAILED, don't auto-save
  defaults over their real data.
- Studio needs **Game Settings → Security → Enable Studio Access to API
  Services** ticked once, or every save fails silently in testing.
- This is the load-bearing pattern only. Schema versions, migration, request
  budgets, autosave cadence, and daily/streak-style state are their own deep
  dive: `roblox-player-data`. leaderstats are a display, not a save — see
  `roblox-luau-basics`' leaderstats card.
