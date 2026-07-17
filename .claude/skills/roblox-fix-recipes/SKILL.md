---
name: roblox-fix-recipes
description: Diagnosis table for /fix — the errors and "it just doesn't work" symptoms beginners actually hit, with the usual cause and the fix. Check here FIRST before reasoning from scratch; a table lookup is cheaper and faster. Never shown to the player.
---

# Roblox Fix Recipes

The same ~15 problems cause almost every broken first game. Match the error
text or the symptom here before investigating from scratch. Explain the fix
to the player in one plain sentence — the technical column is for you.

## Red errors in the Output window

| Error text (pattern) | Usual cause | Fix |
| --- | --- | --- |
| `attempt to index nil with '<Name>'` | Dot-access on something not loaded yet, or a typo'd/renamed object | `WaitForChild`; check exact spelling AND capitals against Explorer |
| `Infinite yield possible on ...WaitForChild("X")` | "X" doesn't exist where the script looks — wrong name, wrong parent, or never created | Find where X really is (or create it); names must match exactly |
| `X is not a valid member of Y` | Same family: wrong name/path, or the script ran before X existed | Fix the name or WaitForChild |
| `attempt to perform arithmetic on nil` | A Value object read before set, or `FindFirstChild` miss used as a number | Nil-check first; make the server create the value before anyone reads it |
| `attempt to compare nil` / `attempt to call a nil value` | Calling/comparing something misspelled or not required properly | Check spelling; check the module actually returns the function |
| `<name> is not a valid Service` | Typo in `GetService` | Exact service name, e.g. "TweenService" not "TweenServce" |
| `expected ')' (to close '(' ...)` / `'end' expected` | Broken bracket/end pairing after a hand edit | Re-emit the whole file from the canonical copy in `game/scripts/` — don't patch brackets by hand |
| `DataStore request was throttled/rejected` | Saving too often, or Studio API access off | Save on leave + interval only; tick Game Settings → Security → Studio API access |
| `HTTP 403/blocked` on a DataStore call in Studio | Studio API access not enabled for this place | Same toggle as above; must be a SAVED/published place |

## "No error, it just doesn't work"

| Symptom | Usual cause | Fix |
| --- | --- | --- |
| Script seems to never run at all | Wrong container: LocalScript in Workspace/ServerScriptService, or Script in StarterPlayerScripts | Move it per the INSTALL block table in roblox-luau-basics; check `Disabled` isn't ticked |
| Part falls through the world at start | Not anchored | `Anchored = true` (or weld it) |
| Touch thing fires many times / gives 5 coins per touch | No debounce | Debounce pattern from roblox-luau-basics |
| Touch thing never fires | `CanCollide=false` part without `CanTouch`, or touching a child part not the scripted one | Put the handler on the part actually touched; check CanTouch |
| Leaderstats don't show | Folder not named exactly `leaderstats` (lowercase), or created client-side | Exact name, created by a server Script on PlayerAdded |
| Money/score changes then snaps back, or only I can see it | A LocalScript changed it — client-side change, server never knew | Move the change server-side behind a validated RemoteEvent (roblox-safe-scripting) |
| GUI invisible for the player | ScreenGui `Enabled=false`, element `Visible=false`, Scale 0 sizing, or it died with respawn | Check Enabled/Visible/size; `ResetOnSpawn=false` for HUDs |
| GUI fine on PC, broken on phone | Offset-based sizing | Rebuild sizes with Scale (roblox-gui-basics) |
| Sound doesn't play | Sound not loaded/moderated, or played client-side only in the wrong place | Use a plain uploaded/owned sound; `:Play()` server-side for world sounds |
| Tween/moving platform doesn't move | Part unanchored (physics fights the tween) or tween garbage-collected | Anchor the part; keep a reference to the tween |
| Works alone, breaks with 2 players | Per-player state stored in one shared variable | Key state by `player` (a table indexed by player), clean up on PlayerRemoving |
| Everything gone when rejoining | No saving built yet (that's a feature, not a bug) — or a failed load overwrote the save | If saving exists: check the failed-load guard from roblox-safe-scripting |

## Process rules (bind /fix, not just inform it)

- ONE cause at a time: apply the most likely fix, re-test, only then try the
  next. Shotgun fixes teach nothing and can break working parts.
- The canonical scripts live in `game/scripts/` — if Studio's copy and the
  file disagree, someone edited in Studio; re-install from the file, then
  fix the file if the bug is real.
- Two recipe attempts failed → stop. That's /undo or "ask Dave" territory
  (per /fix's "big or unclear problem" step). Don't spiral.
