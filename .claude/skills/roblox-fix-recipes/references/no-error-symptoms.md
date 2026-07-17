# "No error, it just doesn't work"

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
| Sound doesn't play | Sound not loaded/moderated, or played client-side only in the wrong place | Use a plain uploaded/owned sound; `:Play()` server-side for world sounds — see roblox-sound-and-music |
| Tween/moving platform doesn't move | Part unanchored (physics fights the tween) or tween garbage-collected | Anchor the part; keep a reference to the tween |
| Works alone, breaks with 2 players | Per-player state stored in one shared variable | Key state by `player` (a table indexed by player), clean up on PlayerRemoving |
| Everything gone when rejoining | No saving built yet (that's a feature, not a bug) — or a failed load overwrote the save | If saving exists: check the failed-load guard from roblox-safe-scripting / roblox-player-data |
