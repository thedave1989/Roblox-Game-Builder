---
name: roblox-worlds-and-terrain
description: Build the world itself — anchoring, Terrain sculpting, materials, spawns, water/lava, lighting, and free-model placement. For the builder and stylist. Never shown to the player.
---

# Roblox Worlds and Terrain

Building the place the game happens in — ground, rooms, terrain, spawn
points, sky. This is often hand-built by the child in Studio's own tools,
with this framework relaying instructions and placing the scriptable pieces
(spawns, triggers) via MCP.

## Anchored — the #1 world-building bug

New parts placed by hand in Studio are **not anchored by default**. Anything
static (ground, walls, buildings, scenery) that isn't welded to something
already anchored will fall through the world the moment the game starts.
When a build "disappears" or "falls into the void" on first test, this is
almost always why — check `Anchored` before anything else.

## Reference cards — load the one the step needs

| Load when the step... | Card |
|---|---|
| Places/moves parts or models, sets up a spawn point | [references/anchoring-and-parts.md](references/anchoring-and-parts.md) |
| Sculpts or edits the Terrain (ground, hills, water, lava) | [references/terrain-editor.md](references/terrain-editor.md) |
| Picks colours/materials for anything | [references/materials-and-style.md](references/materials-and-style.md) |
| Sets time-of-day, mood lighting, or a sky | [references/lighting-and-atmosphere.md](references/lighting-and-atmosphere.md) |
| Inserts a free/Toolbox model, or the world feels slow | [references/quarantine-and-performance.md](references/quarantine-and-performance.md) |
