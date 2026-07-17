# Movement

Simple chase (flat, open ground — start here, it's often enough):

```lua
-- server loop, a few times a second — NOT every frame
while npc.Parent do
    local target = nearestPlayerCharacter(npc, 40)   -- 40 studs aggro range
    if target then
        npc.Humanoid:MoveTo(target.HumanoidRootPart.Position)
    end
    task.wait(0.25)
end
```

- Patrol = `MoveTo` a list of waypoint positions, `MoveToFinished:Wait()`
  between them.
- Walls/obstacles in the way → **PathfindingService**: `CreatePath()`,
  `ComputeAsync(from, to)`, walk `path:GetWaypoints()` in order. Recompute
  when the target moves far, not every step. It CAN fail — check
  `path.Status` and fall back to plain MoveTo.
- A follower pet = chase logic aimed at its owner, stopping ~5 studs short.
  Non-combat, cosmetic pets can be a client-side visual instead (zero server
  cost) — but then other players' pets are the server's business, keep it simple.
