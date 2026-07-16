# /checkup — is everything healthy? (mainly for Dave)

A full health report. The player CAN run it safely (nothing here changes
anything), but its main job is letting Dave diagnose the machine — in person
or over the phone ("type /checkup and read me what it says").

## The sequence

1. Run: `bash .claude/hooks/safety-check.sh --verbose` and show the result.
2. Run: `bash tests/run-tests.sh` and report the last summary line (and any
   FAIL lines, verbatim — Dave needs the exact text).
3. Snapshots: `git log --oneline -5` — report how recent the newest snapshot
   is, in human words ("your work was last saved 10 minutes ago").
4. Studio bridge: check whether the Roblox Studio MCP tools are available
   right now, and say which ("Studio is connected" / "Studio isn't connected
   — that's normal if it isn't open").
5. Game state: one line each — game name from GAME-PLAN.md, steps done vs
   remaining, last PROGRESS.md entry.

## How to report it

To the player: a short friendly summary first — "Everything looks healthy!"
or "Something needs Dave's attention" — followed by the details in a tidy
block Dave can read or be sent a photo of. Technical lines are FINE here
(this is the one command where they're allowed) — but the first sentence
must always be plain English.

If anything failed: end with exactly what to tell Dave, quoted, one line.
