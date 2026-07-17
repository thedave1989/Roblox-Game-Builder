# SETUP — one-time install on the player's machine

For Dave (or whoever is setting this up). Budget ~30 minutes with the player's
machine in front of you. The player never repeats any of this.

## 0. What the machine needs

- Windows 10/11 (Mac works too — notes inline)
- A Roblox account (theirs) with **Roblox Studio** installed and signed in
- A Claude account (theirs) with a paid plan — Pro is what this framework is
  tuned for

## 1. Install the tools (as the machine's admin)

1. **Git for Windows** — https://git-scm.com/download/win. Defaults are fine
   EXCEPT: this framework's safety hooks run through `bash`, so after
   installing, open a fresh terminal and check BOTH:

   ```
   git --version
   bash --version
   ```

   If `bash` isn't found, re-run the installer and pick the PATH option that
   includes the Unix tools (or add `C:\Program Files\Git\bin` to PATH).
   **Do not skip this** — without bash on PATH the safety guard, auto-save,
   and /undo all silently do nothing. (Mac: `xcode-select --install` covers
   git, and bash is already there.) Claude Code runs every shell command
   through the one Bash tool it has, even on Windows — there's no separate
   "PowerShell tool" to also worry about. Windows-style dangerous commands
   typed into it (`Remove-Item -Recurse`, `del /s`, `diskpart`) are still
   caught; that logic lives in `block-danger.py` regardless of which shell
   syntax shows up.
2. **Python 3** — https://www.python.org/downloads/. On the installer's FIRST
   screen tick **"Add python.exe to PATH"** — this matters: the safety guard
   refuses to run commands without Python. Verify afterwards in a fresh
   terminal: `python --version`.
3. **Claude Code** — install per https://docs.anthropic.com/en/docs/claude-code
   (desktop app is the friendliest for a non-technical user). Sign into THEIR
   Claude account.

## 2. Put this repo on their machine

This repo is private on your GitHub — the player's machine shouldn't need
GitHub access at all. Simplest: copy the folder over (USB/drive), or clone it
yourself and delete the remote:

```
git clone https://github.com/thedave1989/Roblox-Game-Builder.git "C:\Users\<them>\RobloxGameBuilder"
cd "C:\Users\<them>\RobloxGameBuilder"
git remote remove origin
git config gamebuilder.player true
```

Removing the remote is deliberate: the invisible-git snapshots stay
local-only, and nothing can ever be pushed from their machine. The
`gamebuilder.player` flag tells the auto-save hook this is a player machine —
from then on it strips any remote that ever reappears, automatically.

If you copied the folder instead of cloning (no .git inside), initialise the
snapshot history:

```
cd "C:\Users\<them>\RobloxGameBuilder"
git init -b main
git add -A
git -c user.name="Game Builder" -c user.email="auto@local" commit -m "day one"
```

## 3. Turn on Roblox Studio's own safety net

Before wiring anything up: in Roblox Studio, confirm **auto-recovery /
version history is ON** (Studio's own settings — the exact menu moves
between versions, so find the current one rather than trusting this line).
This framework's own snapshots cover the game's code and its plan; anything
the player places by hand in Studio (parts, Toolbox models, manual tweaks)
is Studio's own job to protect, and it can only do that if this is on.

## 4. Connect Claude to Roblox Studio (the built-in MCP server)

Roblox Studio now ships its own MCP server — use that, not a separate
install. The old **community** plugin,
https://github.com/Roblox/studio-rust-mcp-server, is **deprecated** — don't
install it. Its tool list (`run_code`, `insert_model`, `get_console_output`,
`start_stop_play`, `run_script_in_play_mode`, `get_studio_mode`) is still
handy as a *reference* for the kind of tools to expect, but it is NOT proof
of the built-in server's real names — step 5 below inventories those for
real, on the player's own machine.

1. In Roblox Studio: **Assistant Settings → MCP Servers** → enable it.
2. Use **Quick connect** to wire it to Claude Code. (Verify this exact menu
   path still holds on the installed Studio version before you rely on it —
   it can move; check Roblox's current Studio MCP docs if it's not where
   you expect.)
3. In Claude Code, confirm the server registered: `claude mcp list`. Note
   its name — you'll need it for the safety step below.
4. **Do NOT** add a blanket `"mcp__<server-name>"` line to
   `.claude/settings.json`, even though that was the old advice for the
   deprecated plugin. The built-in Studio gate hook already covers the
   whole server and default-denies anything you haven't sorted into a tier
   — allowing the whole thing here would undo that. Per-tool allows come
   next, once you know what the tools actually are.

## 5. Classify the Studio tools and prove the safety gate (do NOT skip)

This is the step that makes /build's Studio installs both safe AND
prompt-free for the player. Do it once, with Studio open and connected:

1. In Claude Code, type `/checkup`. It lists every real tool name the
   connected server exposes and compares them against
   `.claude/studio-tools.json`.
2. For each tool it flags as unclassified, decide its tier yourself and add
   it to `.claude/studio-tools.json` by hand:
   - `auto` — safe reads, console output, play mode, start/stop play. No
     prompt, ever.
   - `artifact` — a bounded script install, checked against a file the
     checker already reviewed. Only `run_code` should ever be this, and
     only once the canary below is green.
   - `dave` — anything else, including model insertion and anything you're
     not sure about. Blocked; comes to you.
   Leave `run_code` at `dave` for now.
3. **Allow the tools you just set to `auto` (and, later, `artifact`)** so
   the player never sees a raw permission dialog for them: add one line per
   tool to the `allow` array in `.claude/settings.json`, e.g.
   `"mcp__<server-name>__get_console_output"`. The Studio gate hook still
   checks every one of these calls regardless — allowing a tool here only
   removes the prompt, the gate is what actually enforces the tier. Never
   add a blanket `"mcp__<server-name>"` line — that's exactly the hole this
   whole setup step closes.
4. `/checkup` also runs the **gate canary**: one harmless allowed call
   (proves the gate fires at all on this Claude Code version), then a
   hand-written, NOT checker-approved `run_code` payload (proves the gate
   actually BLOCKS an untrusted Studio write). Both must behave as expected
   before you touch `run_code`'s tier.
5. Only once the canary is green: edit `.claude/studio-tools.json` yourself
   and set `"run_code": "artifact"`, then add its allow line too. Until you
   do this, /build falls back to guided copy-paste for every install — safe,
   just slower for the player.

## 6. Smoke test (do NOT skip)

First, run the shipped self-test suite — deterministic proof of the whole
safety net (guard block/allow matrix, the Studio gate's block/allow matrix,
snapshots, remote stripping, both nudge hooks, skill sizes):

```
cd "C:\Users\<them>\RobloxGameBuilder"
bash tests/run-tests.sh
```

Every line must say PASS. Any FAIL → stop and fix before hand-off. (The
safety-check hook re-verifies the essentials at EVERY session start from
then on, and tells Claude to send the player to you if anything breaks —
but never hand over a machine that starts red.)

Then, in Claude Code opened at the project folder, Studio open on a blank
baseplate:

1. Type `/help` → the friendly menu appears. (Proves commands load.)
2. Type: "make a red part appear in my game" → if you set `run_code` to
   `artifact` and the canary passed, a part appears in Studio via MCP,
   prompt-free; if not, the helper walks through pasting the code by hand
   instead. Either is fine here — the real proof is step 3.
3. **Watch for permission dialogs.** If ANY appeared for a tool you
   classified `auto` or `artifact`, setup is not finished — go back to
   step 5 and check its `allow` line in `.claude/settings.json`. The
   player's happy path must be prompt-free.
4. Check snapshots exist: `git log --oneline` — you should see "snapshot: …"
   entries from the session. (Proves invisible git.)
5. Type `/undo` and walk one restore → it lists plain-English choices, no
   permission dialog, no git words shown. (Proves the undo path end to end.)
6. Close the chat, open a new one → Claude greets them and knows where
   things stand. (Proves PROGRESS.md memory.)

## 7. Hand-off

- Put a desktop shortcut to Claude Code (opened at the project folder).
- Open `HOW-TO-USE.md` with them and do their first `/newgame` together.
- Tell them the one sentence that matters: **"I save your game's code and
  plan — and if it ever tells you to ask me, just send me the hint it
  shows."**

## When Claude needs a rest

Pro plans have a usage cap. The framework is tuned to stretch it, but a long
build day can still hit it. Nothing about their plan or their code is lost
either way — the next session picks up right from PROGRESS.md. Tell them,
exactly, with no numbers attached (the cap structure changes and this
framework doesn't try to track it): "Claude sometimes needs a rest. Try
again after dinner — if it's still resting, tomorrow."

## Updating the framework later

Fix things in your own copy of this repo, then copy the changed files onto
their machine (everything except `game/` — that folder is THEIR game, never
overwrite it).
