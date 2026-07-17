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
5. **Studio tool inventory (Dave's judgment call, only if Studio is
   connected).** List every real tool name the connected server exposes.
   Compare it against `.claude/studio-tools.json`'s `tools` map:
   - Anything listed there that ISN'T one of these real names is stale —
     say so.
   - Anything the server exposes that ISN'T in the map is currently
     blocked (default-deny). Tell Dave its exact name and let HIM decide
     the tier (`auto` / `artifact` / `dave`) and add it by hand — never
     guess a tier for him.
   - `run_code` starts life at `dave`. It only becomes safe to move to
     `artifact` (as `{"tier":"artifact","field":"<its code arg name>"}`) once
     the gate canary below is green.
   - Once Dave has set tiers, he also adds a per-tool `allow` line to
     `.claude/settings.json` for each `auto`/`artifact` tool (e.g.
     `"mcp__<server>__get_console_output"`) so the child sees NO permission
     prompt on the normal path — the gate still runs behind the allow. Tools
     left unlisted, and every `dave`-tier tool, correctly keep prompting.
   - Set `"server"` in `.claude/studio-tools.json` to the REAL server name
     (not `SET-BY-CHECKUP`) — until then the wrong-server protection is off.
     Don't enable any `artifact` tier before the server is pinned.
6. **Gate canary (only if Studio is connected) — proves the Studio safety
   gate actually works on this machine, not just in theory.**
   a. Make one harmless `auto`-tier MCP call (reading the console output is
      a good one) and confirm it goes through cleanly. This proves the
      gate's matcher fires and the tool still runs on the installed Claude
      Code version.
   b. Try a hand-written `run_code` payload that is NOT the checker-approved
      install template (a trivial raw line of Luau, no `GB-INSTALL v1`
      wrapper, nothing recorded in `game/.builder/approved.json`) and
      confirm it comes back BLOCKED. **If it is NOT blocked, this is the
      top finding of the whole report** — tell Dave plainly not to set
      `run_code` to `artifact` until this is fixed, and that installs
      should keep using guided copy-paste in the meantime.
   Only once both (a) and (b) behave exactly as expected should Dave
   consider setting `run_code`'s tier to `artifact` in
   `.claude/studio-tools.json` — and that edit is always his to make by
   hand, never something you do automatically.
7. Game state: one line each — game name from GAME-PLAN.md, steps done vs
   remaining, last PROGRESS.md entry.

## How to report it

To the player: a short friendly summary first — "Everything looks healthy!"
or "Something needs Dave's attention" — followed by the details in a tidy
block Dave can read or be sent a photo of. Technical lines are FINE here
(this is the one command where they're allowed) — but the first sentence
must always be plain English.

The tool-inventory and gate-canary findings (steps 5-6) are Dave-only
judgment calls — report them as plain facts and open questions for him
("Studio has a tool called X I don't recognise — you decide its tier"), never
as something you resolved yourself. A failed gate canary always leads the
report, above everything else.

If anything failed: end with exactly what to tell Dave, quoted, one line.
