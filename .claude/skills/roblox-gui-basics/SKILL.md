---
name: roblox-gui-basics
description: On-screen UI — coin counters, shop windows, banners, health bars. ScreenGui structure, phone-safe sizing, wiring GUI to server values. For the stylist (who builds most UI) and builder. Never shown to the player.
---

# Roblox GUI Basics

How to put things on the screen. The stylist owns most UI steps; the builder
touches GUI when a mechanic needs a display. STYLE.md decides every colour
and font used here — this file only decides structure.

## Where GUI lives

- Player UI goes in **StarterGui** — one ScreenGui per feature, named clearly
  (`CoinCounterGui`, `ShopGui`). Studio copies StarterGui into each player's
  PlayerGui at spawn.
- The LocalScript that runs a GUI sits **inside that ScreenGui** — it finds
  its own buttons with `script.Parent`, no fragile long paths.
- Build the visual tree in Luau (Instance.new, properties, Parent last) so it
  installs like everything else — one INSTALL block, no hand-placed pixels.
- GUI on a part in the world (a shop sign, a floating name) → **BillboardGui**
  (faces the camera) or **SurfaceGui** (painted on a face).

## Reference cards — load the one the step needs

| Load when the step... | Card |
|---|---|
| Builds a new GUI tree, or wires it to leaderstats/RemoteEvents | [references/structure-and-wiring.md](references/structure-and-wiring.md) |
| Anything screen-sized — most players are on phones | [references/sizing-and-mobile.md](references/sizing-and-mobile.md) |
| Wants show/hide feel, tween polish, or you hit a GUI gotcha | [references/polish-and-gotchas.md](references/polish-and-gotchas.md) |
