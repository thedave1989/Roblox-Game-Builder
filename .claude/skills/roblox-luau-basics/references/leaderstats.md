# leaderstats (the score column every Roblox player knows)

```lua
Players.PlayerAdded:Connect(function(player)
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"           -- exact name, lowercase, required
    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Parent = stats
    stats.Parent = player
end)
```

Only the **server** ever changes leaderstats values.

## leaderstats are NOT persistence

This folder is a live display, held in memory only — it resets to nothing
the moment the player leaves, and nothing about it is ever written to disk.
If a step needs progress to survive a rejoin, that's a separate job:
`roblox-player-data` (native DataStores). The usual shape is: DataStore
holds the real number, and on `PlayerAdded` you set the fresh leaderstats
IntValue's `.Value` from the loaded save — never the other way round, and
never assume the leaderstats value alone means the player's progress is safe.
