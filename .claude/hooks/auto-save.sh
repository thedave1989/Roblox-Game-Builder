#!/usr/bin/env bash
# auto-save.sh — the "invisible git" snapshotter.
#
# Commits every change to a LOCAL-ONLY git history so /undo always has
# somewhere to go. The player never sees this run and never needs a git
# identity configured — author details are forced per-commit with -c.
#
# Wired in .claude/settings.json:
#   PostToolUse (Write|Edit|MultiEdit) -> auto-save.sh after-change
#   Stop -> progress-nudge.sh -> auto-save.sh "end of session"
#
# Rules (contract:snapshot-protocol in the parent project):
#   - local commits on main only; NEVER push, branch, rebase, or force
#   - always exit 0 — a snapshot failure must never block the session
set -uo pipefail

LABEL="${1:-auto-save}"

# Run from the repo root (this script lives in .claude/hooks/).
cd "$(dirname "${BASH_SOURCE[0]}")/../.." 2>/dev/null || exit 0

# No repo (or git missing entirely) -> silently do nothing.
command -v git >/dev/null 2>&1 || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# On the player's machine (SETUP.md sets `git config gamebuilder.player true`),
# actively strip any remote that somehow got configured — snapshots are
# local-only by contract, and this makes that true rather than hoped-for.
# On a maintainer's machine (no flag), remotes are left alone.
if [ "$(git config --get gamebuilder.player 2>/dev/null)" = "true" ]; then
  for r in $(git remote 2>/dev/null); do
    git remote remove "$r" >/dev/null 2>&1 || true
  done
fi

git add -A >/dev/null 2>&1 || exit 0
git diff --cached --quiet 2>/dev/null && exit 0   # nothing changed

git -c user.name="Game Builder" -c user.email="auto@local" \
    commit -q -m "snapshot: ${LABEL} ($(date '+%Y-%m-%d %H:%M'))" \
    >/dev/null 2>&1 || true

exit 0
