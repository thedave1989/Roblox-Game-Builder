# Roblox Game Builder

A multi-agent Claude Code framework with exactly one job: let a completely
non-technical person build real Roblox games in Roblox Studio by talking to
Claude — safely, cheaply, and without ever seeing a terminal command, a config
file, or the word "git".

Built by adapting the best parts of [CCMAF](https://github.com/drushegh/CCMAF)
(its security posture, state-file discipline, and hook patterns) and deleting
everything a non-technical user would ever have to think about.

## Who does what

| File | For |
| --- | --- |
| `SETUP.md` | **You (the helper)** — one-time install on their machine |
| `HOW-TO-USE.md` | **The player** — their entire manual, one page |
| `CLAUDE.md` | Claude — the behavioral rules for every session |

## How it works

**Four agents** (that's the "multi-agent" — deliberately no more):

- **game-planner** (Opus — the only place Opus runs): turns the player's idea
  into `game/GAME-PLAN.md`, a plain-English plan of small buildable steps.
- **builder** (Sonnet): writes the Luau for exactly one mechanics step into
  `game/scripts/`, each file carrying an `--[[ INSTALL ]]` header.
- **stylist** (Sonnet): owns how the game LOOKS — `game/STYLE.md` (palette,
  materials, sky, fonts), the `style-preview.html` picture page the player
  can double-click to SEE the style in a browser, and the Luau for visual
  steps (UI, lighting, world dressing).
- **checker** (Sonnet): reviews every script against a Roblox-pitfall
  checklist before it's allowed anywhere near Studio, enforces STYLE.md on
  visual steps, and scans Toolbox free models for hidden malicious scripts.
  Writer never reviews its own work — that separation is inherited straight
  from CCMAF.

**Eight commands** are the player's whole interface: `/newgame` `/build`
`/test` `/fix` `/undo` `/publish` `/peek` `/help` (plus `/checkup` for Dave).
The loop is /build → /test, one visible step at a time; `/peek` is an opt-in
"explain this in plain words" mode, offered only from `/help`.

**Studio bridge:** the official Roblox Studio MCP plugin (scripts appear in
their game automatically), with a guided copy-paste fallback built into
/build for when Studio isn't connected.

**Two state files** (`game/GAME-PLAN.md`, `game/PROGRESS.md`) carry all
memory between chats. Cold start = read those two files. That's it.

## Safety net (the part to trust)

- **Invisible git:** hooks auto-snapshot on every change and at session end
  (`auto-save.sh`), with author identity forced per-commit so the machine
  needs no git config. Local-only — no remote ever. `/undo` presents
  snapshots as plain choices ("end of yesterday") and restores `game/` only.
- **Command guard:** `block-danger.py` (adapted from CCMAF) structurally
  blocks catastrophic commands — recursive deletes of roots/home/`.git`,
  disk writers, formatters, diskpart, fork bombs — Windows-aware (it catches
  `del /s`, `Remove-Item -Recurse`, `diskpart` and friends too, however
  they're typed). Claude Code only has the one Bash tool, even on Windows —
  there's no separate "PowerShell tool" to also guard. Fails open on parse
  errors, fails CLOSED if Python is missing. One honest caveat: the hook
  chain runs through `bash`, so SETUP.md's bash-on-PATH check and by-hand
  guard test are mandatory — a machine without bash has none of this
  protection.
- **Studio gate** (`studio-gate.py` + `record-approval.py` + the install
  template) — the real control on what reaches Studio. Every Roblox Studio MCP
  call passes through a `PreToolUse` gate; a script install runs only if it is
  the EXACT checker-approved file source (matched structurally against the
  install template and by SHA-256 to a record in `game/.builder/approved.json`),
  and arbitrary code, model insertion, or any tool Dave hasn't classified in
  `.claude/studio-tools.json` is blocked by default. It fails CLOSED (unlike the
  shell guard). Two honest limits: **(1)** the approval record is written by the
  framework, not cryptographically signed by the checker — so it stops accidents
  and stale/edited installs, not a deliberately-lying orchestrator, which is why
  arbitrary exec and model insertion stay Dave-gated even with it in place;
  **(2)** the `builder`/`stylist` agents that WRITE Luau have no Bash and no MCP
  tools — they cannot execute anything; only the main session installs, after
  the checker's PASS. Both are load-bearing — don't "simplify" them away.
- **Permission walls** in `.claude/settings.json`: Write/Edit scoped to
  `game/**`; deny-rules on secret paths (.env, ssh/aws keys, `.git/`
  internals); ask-gates on `.claude/**`, CLAUDE.md, and remote-touching git.
  The destructive-command ask-gates (`rm -rf` etc.) are belt-and-braces
  only — they're prefix matchers and easy to sidestep; the guard hook is
  the real control.
- **Code hygiene rules** the agents enforce: no marketplace `require()`, no
  `loadstring`, server validates everything a client sends; Toolbox free
  models get scanned for hidden scripts before they stay.
- **Safety-net self-check** (`safety-check.sh`, every session start —
  adapted from CCMAF's guard-interpreter-check + doctor): live-fire tests
  the command guard, verifies git/snapshots/hook wiring, confirms no remote
  on player machines. Silent when healthy; on failure it makes Claude tell
  the player to get Dave BEFORE building. `/checkup` runs the same checks
  verbosely, plus the test suite, for phone-call diagnosis.
- **Mechanical frugality** (`session-nudge.sh`): counts substantial build/fix
  actions and past ~12–15 has Claude suggest a friendly break — the credit
  protection is enforced by a hook, not just promised in prose (CCMAF's "hooks
  are enforcement, not suggestion"), and it never quotes a usage number it
  can't actually measure.
- **Shipped test suite** (`tests/run-tests.sh`): 80+ checks proving the shell
  guard's block/allow matrix, the Studio gate's install-and-bypass matrix,
  snapshot behavior, remote stripping, and both nudges — run it after ANY
  change under `.claude/`.

## Frugality (Pro-plan friendly)

Sonnet by default (pinned in settings.json), Opus only for game planning,
two-file cold start, short-reply rules in CLAUDE.md, one build step per
command, and zero background machinery (no telemetry, no update checks, no
consoles). Hitting the plan limit just means "come back after the reset" —
the state files make every fresh chat cheap.

## Repo layout

```
CLAUDE.md            # Claude's rules (the brain)
HOW-TO-USE.md        # the player's one-page manual
SETUP.md             # your install guide
tests/
  run-tests.sh       # self-test suite — run after any .claude/ change
.claude/
  settings.json      # model pin, permissions, hook wiring
  studio-tools.json  # Dave's Studio-tool safety map (auto / artifact / dave)
  hooks/             # block-danger.py, studio-gate.py (the F1 Studio gate),
                     # record-approval.py, auto-save, progress-nudge,
                     # safety-check (SessionStart), session-nudge (frugality)
  agents/            # game-planner, builder, stylist, checker
  commands/          # newgame, build, test, fix, undo, publish, peek, help,
                     # checkup
  templates/         # style-preview-template.html, install-wrapper.luau
  skills/            # Roblox knowledge packs (router SKILL.md + references/):
                     # luau-basics, game-recipes, safe-scripting, gui-basics,
                     # fix-recipes, npcs-and-enemies, sound-and-music,
                     # worlds-and-terrain, player-data, badges-and-passes,
                     # code-peek
game/
  GAME-PLAN.md       # their game's plan (starts as a friendly placeholder)
  STYLE.md           # the look: palette, materials, sky, fonts
  style-preview.html # generated picture page of STYLE.md (double-click it)
  PROGRESS.md        # memory between chats
  scripts/           # canonical copy of every script installed in Studio
  changes/           # approved non-script edits (bounded property changes)
  .builder/          # approval ledger the Studio gate reads (machine state)
```
