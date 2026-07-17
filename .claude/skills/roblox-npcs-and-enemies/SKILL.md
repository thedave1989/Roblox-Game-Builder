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

## Reference cards — load the one the step needs

| Load when the step... | Card |
|---|---|
| Needs the NPC to chase, patrol, or navigate around obstacles | [references/movement-and-pathfinding.md](references/movement-and-pathfinding.md) |
| Involves the NPC dealing or taking damage | [references/damage-rules.md](references/damage-rules.md) |
| You're spawning more than one, or worried about server cost | [references/server-cost-caps.md](references/server-cost-caps.md) |
| Needs the NPC to actually animate (walk/idle/attack) | [references/character-animation.md](references/character-animation.md) |
| Is a shopkeeper or other friendly, non-combat NPC | [references/shopkeepers-and-friendly-npcs.md](references/shopkeepers-and-friendly-npcs.md) |

## Sizing guide (for the game-planner)

"One enemy that chases and hurts you" = one step. "Enemies respawn and give
coins" = a second step. "A boss" = chase + more health + bigger numbers, one
step AFTER basic enemies work. Pathfinding through a maze, ranged attacks,
NPC dialogue trees → "Ideas for later".
