#!/usr/bin/env bash
# progress-nudge.sh — Stop hook. Three small jobs, then always exit 0:
#
#   1. Take an end-of-session snapshot (via auto-save.sh) so nothing is
#      ever lost between chats.
#   2. If the session changed game files but game/PROGRESS.md wasn't
#      updated, remind Claude (exit 2 feeds the message back) — ONCE.
#      The reminder is skipped when stop_hook_active is set, so it can
#      never trap the player in a loop.
#   3. If game/PROGRESS.md has grown past ~4 KB, remind Claude to prune the
#      oldest entries into a one-line summary — the file is meant to stay a
#      short, fixed schema, and letting it balloon defeats the whole point
#      of a cheap two-file cold start.
#
# This is deliberately gentler than CCMAF's enforce-state-update.sh:
# the player must always be able to close his chat.
set -uo pipefail

# How big game/PROGRESS.md can grow before Claude gets asked to prune it.
PROGRESS_MAX_BYTES=4096

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

# PROGRESS.md itself has grown too big to stay cheap to read at cold start.
if [ -f "game/PROGRESS.md" ]; then
  size="$(wc -c < "game/PROGRESS.md" 2>/dev/null || echo 0)"
  case "$size" in *[!0-9]*) size=0 ;; esac
  if [ "$size" -gt "$PROGRESS_MAX_BYTES" ]; then
    echo "Before finishing: game/PROGRESS.md has grown past ${PROGRESS_MAX_BYTES} bytes. Prune it back to the short schema — squash older finished work into one plain-English line each, and keep only: last child-proven result / next step / current problem / one Dave hint if blocked." >&2
    exit 2
  fi
fi

exit 0
