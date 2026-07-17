# Events you'll use constantly

```lua
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        -- character exists now; character:WaitForChild("Humanoid")
    end)
end)
```

Touch with debounce (touched fires many times per touch):

```lua
local busy = {}
part.Touched:Connect(function(hit)
    local player = Players:GetPlayerFromCharacter(hit.Parent)
    if not player or busy[player] then return end
    busy[player] = true
    -- do the thing once
    task.wait(1)
    busy[player] = nil
end)
```

- Clickable things: prefer **ProximityPrompt** (walk up + press E) or
  **ClickDetector**. Both have server-side events — keep the logic there.
