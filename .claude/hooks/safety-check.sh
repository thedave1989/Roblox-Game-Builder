#!/usr/bin/env bash
# safety-check.sh — SessionStart hook. Verifies the safety net is actually
# alive, every single session. Adapted from CCMAF's guard-interpreter-check
# + doctor, collapsed into one kid-proof check.
#
# Why this exists: every promise this framework makes ("you can't lose
# work", "dangerous commands get blocked") depends on python, bash, git and
# the hook wiring all functioning. Any of those can silently break on a
# family PC — and a safety net that fails silently is worse than none,
# because the player keeps trusting it.
#
# Behaviour:
#   - All clear -> prints nothing (SessionStart stdout goes into Claude's
#     context; silence keeps sessions cheap).
#   - Problems  -> prints a SAFETY CHECK block so Claude tells the player
#     to ask Dave, and stops promising protection it doesn't have.
#   - --verbose -> prints the full checklist either way (used by /checkup).
#   - ALWAYS exits 0 — the player must never be locked out of his chat.
set -uo pipefail

VERBOSE=0
[ "${1:-}" = "--verbose" ] && VERBOSE=1

cd "$(dirname "${BASH_SOURCE[0]}")/../.." 2>/dev/null || exit 0

PROBLEMS=()
OK=()

# 1. Python — the command guard's interpreter.
PY="$(command -v python3 || command -v python || command -v py || true)"
if [ -n "$PY" ]; then
  OK+=("python found ($PY)")
else
  PROBLEMS+=("Python is missing - the dangerous-command guard cannot run")
fi

# 2. The guard actually blocks (live-fire test, deterministic).
if [ -n "$PY" ] && [ -f ".claude/hooks/block-danger.py" ]; then
  echo '{"tool_input":{"command":"rm -rf /"}}' | "$PY" .claude/hooks/block-danger.py >/dev/null 2>&1
  if [ $? -eq 2 ]; then
    OK+=("dangerous-command guard blocks correctly")
  else
    PROBLEMS+=("the dangerous-command guard did NOT block a test command")
  fi
elif [ -n "$PY" ]; then
  PROBLEMS+=("block-danger.py is missing from .claude/hooks/")
fi

# 3. Guard is wired into settings.json (someone may have edited it).
if grep -q "block-danger.py" .claude/settings.json 2>/dev/null; then
  OK+=("guard wired in settings.json")
else
  PROBLEMS+=("the guard is not wired in .claude/settings.json")
fi

# 4. git + snapshot history — the substance behind /undo.
if command -v git >/dev/null 2>&1; then
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    OK+=("snapshot history present")
    # 5. Player machines must have no remote (auto-save strips; verify).
    if [ "$(git config --get gamebuilder.player 2>/dev/null)" = "true" ]; then
      if [ -z "$(git remote 2>/dev/null)" ]; then
        OK+=("no remote configured (local-only, as designed)")
      else
        PROBLEMS+=("a git remote appeared on a player machine (auto-save will strip it, but check how it got there)")
      fi
    fi
  else
    PROBLEMS+=("no snapshot history (.git missing) - /undo has nothing to restore from")
  fi
else
  PROBLEMS+=("git is missing - auto-save and /undo cannot work")
fi

# 6. The two state files the whole framework runs on.
[ -f "game/GAME-PLAN.md" ] && OK+=("GAME-PLAN.md present") \
  || PROBLEMS+=("game/GAME-PLAN.md is missing")
[ -f "game/PROGRESS.md" ] && OK+=("PROGRESS.md present") \
  || PROBLEMS+=("game/PROGRESS.md is missing")

# --- Report -----------------------------------------------------------------
if [ "${#PROBLEMS[@]}" -gt 0 ]; then
  echo "SAFETY CHECK FAILED (${#PROBLEMS[@]} problem(s)):"
  for p in "${PROBLEMS[@]}"; do echo "  - $p"; done
  echo "Instructions for Claude: the safety net is NOT fully working."
  echo "Tell the player, gently, at the start of this chat: \"Before we build"
  echo "anything - ask Dave to look at this. Tell him: the safety check found:"
  echo "${PROBLEMS[0]}\". Do not build until Dave fixes it, and do not promise"
  echo "that work is being saved if the snapshot checks above failed."
elif [ "$VERBOSE" = "1" ]; then
  echo "SAFETY CHECK: all clear."
  for o in "${OK[@]}"; do echo "  + $o"; done
fi

exit 0
