---
name: roblox-fix-recipes
description: Diagnosis table for /fix — the errors and "it just doesn't work" symptoms beginners actually hit, with the usual cause and the fix. Check here FIRST before reasoning from scratch; a table lookup is cheaper and faster. Never shown to the player.
---

# Roblox Fix Recipes

The same ~15 problems cause almost every broken first game. Match the error
text or the symptom here before investigating from scratch. Explain the fix
to the player in one plain sentence — the technical column is for you.

## Which card

| Situation | Card |
|---|---|
| There's a red error in Studio's Output window | [references/output-errors.md](references/output-errors.md) |
| It just silently doesn't do the right thing, no error | [references/no-error-symptoms.md](references/no-error-symptoms.md) |

## Process rules (bind /fix, not just inform it)

- ONE cause at a time: apply the most likely fix, re-test, only then try the
  next. Shotgun fixes teach nothing and can break working parts.
- The canonical scripts live in `game/scripts/` — if Studio's copy and the
  file disagree, someone edited in Studio; re-install from the file, then
  fix the file if the bug is real.
- Two recipe attempts failed → stop. That's /undo or "ask Dave" territory
  (per /fix's "big or unclear problem" step). Don't spiral.
