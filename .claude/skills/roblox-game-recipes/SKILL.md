---
name: roblox-game-recipes
description: Proven mechanic recipes for the games kids actually make — obby, tycoon, simulator, collectibles, shops, rounds. Each recipe is sized to fit one /build step. For the game-planner (sizing steps) and builder (building them).
---

# Roblox Game Recipes

The mechanics that make up 90% of first Roblox games, each described as the
smallest version that works. Game-planner: steal these as Build List steps.
Builder: follow the shape, keep the gotchas.

Every recipe obeys roblox-luau-basics and roblox-safe-scripting. Recipes
never contradict them.

## Obby (obstacle course)

- **Checkpoints** — one SpawnLocation per stage. On Touched, set the player's
  `RespawnLocation` (or store their stage in an IntValue/attribute and
  teleport on respawn). Track `leaderstats.Stage`. Gotcha: debounce, and only
  move the stage *forward* (touching checkpoint 2 after 5 must not reset you).
- **Kill brick** — Touched → `Humanoid.Health = 0`. One script can serve every
  kill brick: tag them with CollectionService ("KillBrick") and loop the tag.
- **Moving/disappearing platforms** — TweenService between two positions, or a
  loop toggling `CanCollide`+`Transparency` with `task.wait()`. Anchor them.
- **Finish line** — Touched → celebrate (confetti = particles), award a win to
  leaderstats, teleport back to lobby.

## Collectibles (coins, gems, eggs)

- Coin = anchored part, slow spin tween. Touched → +1 server-side, coin
  vanishes (`CanCollide=false, Transparency=1`), reappears after `task.wait(10)`.
  Debounce per-coin. Never destroy-and-clone when hide-and-show works.
- Spawning many: one template in ServerStorage, `:Clone()` to marked spots.

## Tycoon

- **Dropper** — server loop: clone a small part above a conveyor every few
  seconds, `Debris:AddItem(part, 30)` so drops can't pile up forever.
- **Collector** — Touched at the conveyor end → add the drop's value to the
  owner's money, destroy the drop.
- **Buy button** — Touched by the owner → server checks money ≥ price →
  subtract, make the purchased thing visible/real. Price and money live
  server-side only.
- **Owner door** — Touched → walk through only if `player == plot.Owner`.
- Start with ONE plot single-player; multi-plot claiming is an "Ideas for
  later" upgrade, not step 1.

## Simulator (click to earn)

- Tool in StarterPack. Tool.Activated (client) → fire ONE RemoteEvent with no
  arguments → server adds the amount (server decides how much, never the
  client) → leaderstats update. Rate-limit server-side (ignore >10 fires/sec).
- Upgrades ("+1 per click") are server-stored numbers the shop changes.

## Shop

- ProximityPrompt on a shop part → opens a simple GUI (client) → Buy click
  fires RemoteEvent with the item name (a string) → server looks the item up
  in ITS OWN price table, checks money, subtracts, grants. Client never sends
  a price. Unknown item name → ignore.

## Rounds / arena games

- One server loop: intermission (`task.wait(15)`) → teleport everyone to the
  arena → play until timer or one player left → winner gets a point →
  everyone back to lobby. Track state in one place; announce with a single
  RemoteEvent the clients listen to for GUI text.
- This is the most script-heavy recipe here — plan it as 2–3 steps
  (teleport + timer first, winning second, polish third).

## Sizing guide (for the game-planner)

One /build step ≈ one bullet above. "Coins that respawn" = one step.
"A shop" = one step. "Rounds" = two or three. If a recipe needs another
recipe first (shop needs coins), order them that way in the Build List.
