# RemoteEvents / RemoteFunctions

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
