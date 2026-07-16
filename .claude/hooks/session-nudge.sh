#!/usr/bin/env bash
# session-nudge.sh — UserPromptSubmit hook. Mechanical credit protection:
# counts prompts this session and, past a threshold, reminds Claude ONCE to
# suggest a friendly break. The player's Claude plan has limited hours;
# CLAUDE.md asks Claude to watch this, but hooks enforce what prose only
# suggests (a lesson taken straight from CCMAF).
#
# Tunable: RGB_NUDGE_PROMPTS (default 25). Always exits 0; never blocks.
set -uo pipefail

THRESHOLD="${RGB_NUDGE_PROMPTS:-25}"

cd "$(dirname "${BASH_SOURCE[0]}")/../.." 2>/dev/null || exit 0

INPUT="$(cat 2>/dev/null || true)"
# Pull the session id out of the event JSON without needing jq.
SID="$(printf '%s' "$INPUT" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
[ -n "$SID" ] || exit 0

COUNT_DIR=".claude/.tmp"
mkdir -p "$COUNT_DIR" 2>/dev/null || exit 0
COUNT_FILE="$COUNT_DIR/prompts-$SID"
NUDGED_FILE="$COUNT_DIR/nudged-$SID"

# Tidy files from old sessions (best-effort, quiet).
find "$COUNT_DIR" -type f -mtime +2 -delete 2>/dev/null || true

COUNT=0
[ -f "$COUNT_FILE" ] && COUNT="$(cat "$COUNT_FILE" 2>/dev/null || echo 0)"
case "$COUNT" in *[!0-9]*) COUNT=0 ;; esac
COUNT=$((COUNT + 1))
printf '%s' "$COUNT" > "$COUNT_FILE" 2>/dev/null || true

if [ "$COUNT" -ge "$THRESHOLD" ] && [ ! -f "$NUDGED_FILE" ]; then
  touch "$NUDGED_FILE" 2>/dev/null || true
  echo "(Session note for Claude: this chat has run ~$COUNT prompts. After finishing the current thing, warmly suggest a break at the next natural stopping point - e.g. after the next /test passes - and remind the player you'll remember everything next time. Keep replies extra-short from here on to save his plan's hours.)"
fi

exit 0
