---
name: roblox-safe-scripting
description: Security and data-safety rules — server authority, RemoteEvent validation, saving with native DataStores, and the forbidden-call list. Read for any step involving money, saving, remotes, or anything a player could cheat. For agents, never shown to the player.
---

# Roblox Safe Scripting

Exploiters run their own code on the client. Anything the client controls,
a cheater controls. These rules keep the game honest and the save data safe.

## Server authority (the one big rule)

Money, health, scores, inventory, purchases, win conditions: the **server**
owns them. A LocalScript may *ask* and *display* — never *decide*.

- Client changes its own leaderstats? Cosmetic — the server copy is unchanged.
  So the server must be the only writer, or the display lies.
- Never trust position/speed claims from the client for rewards ("I touched
  the finish") — verify server-side (server sees Touched too).

## RemoteEvents / RemoteFunctions

Create them in ReplicatedStorage. Every server handler validates, every time:

```lua
buyEvent.OnServerEvent:Connect(function(player, itemName)
    -- 1. types: reject anything unexpected
    if typeof(itemName) ~= "string" then return end
    -- 2. look up in the SERVER's table — the client sends names, never prices
    local price = SHOP_PRICES[itemName]
    if not price then return end
    -- 3. state check: can THIS player do this NOW?
    local coins = player:FindFirstChild("leaderstats") and player.leaderstats.Coins
    if not coins or coins.Value < price then return end
    coins.Value -= price
    grant(player, itemName)
end)
```

- The `player` argument is supplied by Roblox and can't be faked — use it for
  ownership, never a player name sent as data.
- Rate-limit spammable remotes (ignore a player firing >10×/sec).
- Numbers from the client: check type, range, and `math.floor` if it must be whole.
- RemoteFunction server→client is a hang risk (client can just not answer) — avoid.

## Saving with DataStores (native only)

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

## Forbidden — never write, never let through

Mirrors the checker's blocklist; the builder must never produce these:

- `require(<asset id number>)` — runs marketplace code sight-unseen. The #1
  backdoor vector in free models.
- `loadstring(...)` — executes strings as code.
- `getfenv` / `setfenv` — environment tampering, and deoptimizes Luau.
- `HttpService` requests — this framework's games don't call the internet.
- Obfuscated code (long unreadable strings, byte arrays that decode to code):
  treat as hostile, delete.

## Free models (Toolbox)

Visuals are fine; scripts inside are untrusted. The checker scans every
inserted model — its REMOVE verdicts get acted on before building continues.
Default stance: delete all scripts inside a free model and keep the looks.
