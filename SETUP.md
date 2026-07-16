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
   git, and bash is already there.)
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

## 3. Connect Claude to Roblox Studio (the MCP plugin)

Follow the official Roblox Studio MCP server README — it moves, so trust it
over this file: **https://github.com/Roblox/studio-rust-mcp-server**

The shape of it:

1. Download and run their installer (releases page) on the player's machine.
2. It installs a Studio plugin + a local MCP server and wires up Claude.
   If it only auto-configures Claude Desktop, add it to Claude Code yourself
   with `claude mcp add` (see their README for the exact command/args).
3. In Studio: **Plugins tab → the MCP plugin → make sure it's ON** and
   Studio's popup asking to allow the connection is accepted.
4. **Allowlist the MCP tools so the player never sees a permission dialog.**
   Find the server's registered name (`claude mcp list`), then add one line
   to the `allow` array in `.claude/settings.json`:

   ```
   "mcp__<server-name>"
   ```

   (The exact name depends on how the installer registered it. Allowing the
   whole server is right here — every tool it has is a Studio tool.) This is
   the single most important line for the player's experience: without it,
   every /build asks scary permission questions until he learns to mash
   "always allow" — the exact reflex we don't want to teach him.

## 4. Smoke test (do NOT skip)

First, run the shipped self-test suite — deterministic proof of the whole
safety net (guard block/allow matrix, snapshots, remote stripping, both
nudge hooks):

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
2. Type: "make a red part appear in my game" → a part appears in Studio via
   MCP. (Proves the bridge.)
3. **Watch for permission dialogs during step 2.** If ANY appeared, setup is
   not finished — go back to the MCP allowlist step. The player's happy path
   must be prompt-free.
4. Check snapshots exist: `git log --oneline` — you should see "snapshot: …"
   entries from the session. (Proves invisible git.)
5. Type `/undo` and walk one restore → it lists plain-English choices, no
   permission dialog, no git words shown. (Proves the undo path end to end.)
6. Close the chat, open a new one → Claude greets them and knows where
   things stand. (Proves PROGRESS.md memory.)

## 5. Hand-off

- Put a desktop shortcut to Claude Code (opened at the project folder).
- Open `HOW-TO-USE.md` with them and do their first `/newgame` together.
- Tell them the one sentence that matters: **"You can't break it — and if
  it ever tells you to ask me, just send me the hint it shows."**

## When they hit Claude's usage limit

Pro has a usage cap that resets every ~5 hours. The framework is tuned to
stretch it, but a long build day can still hit it. Nothing is lost — the next
session picks up from PROGRESS.md. Tell them: "come back after dinner."

## Updating the framework later

Fix things in your own copy of this repo, then copy the changed files onto
their machine (everything except `game/` — that folder is THEIR game, never
overwrite it).
