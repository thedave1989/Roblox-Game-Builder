#!/usr/bin/env bash
# progress-nudge.sh — Stop hook. Two small jobs, then always exit 0:
#
#   1. Take an end-of-session snapshot (via auto-save.sh) so nothing is
#      ever lost between chats.
#   2. If the session changed game files but game/PROGRESS.md wasn't
#      updated, remind Claude (exit 2 feeds the message back) — ONCE.
#      The reminder is skipped when stop_hook_active is set, so it can
#      never trap the player in a loop.
#
# This is deliberately gentler than CCMAF's enforce-state-update.sh:
# the player must always be able to close his chat.
set -uo pipefail

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HOOK_DIR/../.." 2>/dev/null || exit 0

INPUT="$(cat 2>/dev/null || true)"

# Snapshot first — this must happen no matter what.
bash "$HOOK_DIR/auto-save.sh" "end of session" || true

# Never nag twice (harness sets stop_hook_active on the retry pass).
case "$INPUT" in *'"stop_hook_active":true'*) exit 0 ;; esac

command -v git >/dev/null 2>&1 || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# Did this session's snapshots touch game/ scripts without updating PROGRESS.md?
recent="$(git log --since='6 hours ago' --name-only --pretty=format: 2>/dev/null || true)"
if printf '%s' "$recent" | grep -q '^game/scripts/' \
   && ! printf '%s' "$recent" | grep -q '^game/PROGRESS.md'; then
  echo "Before finishing: update game/PROGRESS.md in plain English — what got built, what to do next time. Keep it to a few lines." >&2
  exit 2
fi

exit 0
