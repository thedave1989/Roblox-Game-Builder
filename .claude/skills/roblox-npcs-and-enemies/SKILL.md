---
name: roblox-npcs-and-enemies
description: Characters the game controls — chasing zombies, pet followers, shopkeepers, patrol guards. Rig basics, movement with Humanoid and PathfindingService, safe damage rules, and server-cost caps. For the builder. Never shown to the player.
---

# Roblox NPCs and Enemies

"A monster that chases you" is one of the most-asked features in kids'
games. NPCs are also the easiest way to melt a server — every rule here
about caps and cost is load-bearing.

## What an NPC is

A Model in Workspace containing: a Humanoid, body parts, and a part named
`HumanoidRootPart` (the thing you move). Easiest safe source: right-click in
Explorer → an R15/R6 rig from Studio's built-in rig builder, or clone simple
block rigs — NOT a Toolbox model with scripts inside (checker scans apply).

- Keep a template in **ServerStorage**, `:Clone()` into Workspace to spawn.
- All NPC logic is **server-side** Scripts — clients never drive an enemy.
- Name the model what it is (`Zombie`), tag it with CollectionService
  (`"Enemy"`) so one script can manage all of them.

## Movement

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

## Damage — the safety rules

- NPC hurts player: on Touched (or a ranged check), server-side, with a
  debounce per victim (e.g. 10 damage max once per second). Never
  per-Touched-event raw damage — that's instant death by event spam.
- Player hurts NPC: sword Touched or click-target → server validates
  distance ("is the attacker actually near it?") before applying damage.
  A RemoteEvent that says "I hit the zombie for 50" violates
  roblox-safe-scripting — the server decides hits and numbers.
- NPC death: `Humanoid.Died` → award coins/XP server-side, play a small
  effect, `Debris:AddItem(model, 3)` to clean the corpse, respawn on a timer.
- NPCs must never damage other NPCs of the same tag (zombies fighting each
  other looks broken) — check the tag before applying damage.

## Server cost caps (non-negotiable)

- **Hard cap the count.** A spawner keeps at most N alive (count the tag;
  6–10 enemies is plenty for a first game). Spawner loop: if under cap and
  `task.wait(5)` passed, clone one.
- Decision loops run at `task.wait(0.25)`-ish, never Heartbeat.
- Idle NPCs (no player within aggro range) should do nothing — skip the
  whole body, don't pathfind to no one.
- `SetNetworkOwner(nil)` on the HumanoidRootPart after spawning — keeps the
  server in charge of physics so enemies don't stutter or get exploited.
- Despawn or freeze everything when no players are near the area.

## Shopkeepers and friendly NPCs

- A static rig + a **ProximityPrompt** ("Talk"/"Shop") is a complete
  shopkeeper — prompt opens the shop GUI (roblox-gui-basics), purchase flows
  through the validated RemoteEvent (roblox-safe-scripting). No wandering AI
  needed; personality comes from the look (stylist) and the words.
- Name tag over the head: BillboardGui on the head part, one TextLabel.

## Sizing guide (for the game-planner)

"One enemy that chases and hurts you" = one step. "Enemies respawn and give
coins" = a second step. "A boss" = chase + more health + bigger numbers, one
step AFTER basic enemies work. Pathfinding through a maze, ranged attacks,
NPC dialogue trees → "Ideas for later".
