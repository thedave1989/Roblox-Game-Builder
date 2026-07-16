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

**Three agents** (that's the "multi-agent" — deliberately no more):

- **game-planner** (Opus — the only place Opus runs): turns the player's idea
  into `game/GAME-PLAN.md`, a plain-English plan of small buildable steps.
- **builder** (Sonnet): writes the Luau for exactly one step into
  `game/scripts/`, each file carrying an `--[[ INSTALL ]]` header.
- **checker** (Sonnet): reviews every script against a Roblox-pitfall
  checklist before it's allowed anywhere near Studio. Writer never reviews
  its own work — that separation is inherited straight from CCMAF.

**Seven commands** are the player's whole interface: `/newgame` `/build`
`/test` `/fix` `/undo` `/publish` `/help`. The loop is /build → /test,
one visible step at a time.

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
  disk writers, formatters, diskpart, fork bombs — Windows-aware, on both
  the Bash and PowerShell tools. Fails open on parse errors, fails CLOSED if
  Python is missing. One honest caveat: the hook chain runs through `bash`,
  so SETUP.md's bash-on-PATH check and by-hand guard test are mandatory —
  a machine without bash has none of this protection.
- **Permission walls** in `.claude/settings.json`: Write/Edit scoped to
  `game/**`; deny-rules on secret paths (.env, ssh/aws keys, `.git/`
  internals); ask-gates on `.claude/**`, CLAUDE.md, and remote-touching git.
  The destructive-command ask-gates (`rm -rf` etc.) are belt-and-braces
  only — they're prefix matchers and easy to sidestep; the guard hook is
  the real control.
- **Code hygiene rules** the agents enforce: no marketplace `require()`, no
  `loadstring`, server validates everything a client sends.

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
.claude/
  settings.json      # model pin, permissions, hook wiring
  hooks/             # block-danger.py, auto-save.sh, progress-nudge.sh
  agents/            # game-planner, builder, checker
  commands/          # newgame, build, test, fix, undo, publish, help
game/
  GAME-PLAN.md       # their game's plan (starts as a friendly placeholder)
  PROGRESS.md        # memory between chats
  scripts/           # canonical copy of every script installed in Studio
```
