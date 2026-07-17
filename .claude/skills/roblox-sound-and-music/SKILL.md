---
name: roblox-sound-and-music
description: Make the game sound alive — UI sounds, world ambience, event effects, background music, and where audio is allowed to come from. For the builder and stylist. Never shown to the player.
---

# Roblox Sound and Music

A Sound instance's **Parent decides how it behaves** — that one fact answers
most "why does this sound wrong" questions:

- Parented to a **Part or Attachment in the world** → plays **3D/positional**
  (louder near it, fades with distance). Good for a waterfall, a shop, a
  campfire.
- Parented to **SoundService** (or set up as a global ambience) → plays the
  **same everywhere**, no distance falloff. Good for map-wide ambience or
  background music.
- Parented under a **GUI element / PlayerGui** → a UI sound, heard by that
  one player regardless of where their character is.

## Reference cards — load the one the step needs

| Load when the step... | Card |
|---|---|
| Adds a click/purchase/error sound to a button or menu | [references/ui.md](references/ui.md) |
| Adds continuous ambience to an area (waterfall, wind, shop hum) | [references/world-ambience.md](references/world-ambience.md) |
| Plays a one-shot sound tied to a gameplay event (coin, hit, level-up) | [references/effects.md](references/effects.md) |
| Adds background music that loops | [references/music.md](references/music.md) |
| Wants a sound that isn't already free in the Creator Store | [references/licensing-and-uploads.md](references/licensing-and-uploads.md) |
