---
name: roblox-game-recipes
description: Proven mechanic recipes for the games kids actually make — obby, tycoon, simulator, collectibles, shops, rounds, and cosmetic effects. Each recipe is sized to fit one /build step. For the game-planner (sizing steps) and builder.
---

# Roblox Game Recipes

The mechanics that make up 90% of first Roblox games, each described as the
smallest version that works. Game-planner: steal these as Build List steps.
Builder: follow the shape, keep the gotchas.

Every recipe obeys roblox-luau-basics and roblox-safe-scripting. Recipes
never contradict them.

## Recipe cards — load the one the step needs

| Step is about... | Card |
|---|---|
| Checkpoints, kill bricks, moving platforms, a finish line | [references/obby.md](references/obby.md) |
| Coins, gems, eggs, anything that respawns after pickup | [references/collectibles.md](references/collectibles.md) |
| Droppers, collectors, buy buttons, an owned plot | [references/tycoon.md](references/tycoon.md) |
| Click/tap-to-earn with upgrades | [references/simulator.md](references/simulator.md) |
| A buy/sell screen wired to server-owned prices | [references/shop.md](references/shop.md) |
| Intermission → arena → winner loops | [references/rounds.md](references/rounds.md) |
| Smooth movement/colour/size changes on a part or door | [references/effects-tween.md](references/effects-tween.md) |
| Sparkles, confetti, smoke, a burst effect | [references/effects-particles.md](references/effects-particles.md) |
| A speed/dash/projectile trail | [references/effects-trails.md](references/effects-trails.md) |

## Sizing guide (for the game-planner)

One /build step ≈ one card above. "Coins that respawn" = one step. "A shop"
= one step. "Rounds" = two or three. If a recipe needs another recipe first
(shop needs coins), order them that way in the Build List.
