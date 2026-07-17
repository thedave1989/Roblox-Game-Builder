#!/usr/bin/env bash
# run-tests.sh — proves the safety net works. For Dave, not the player.
#
# Run it from the repo root any time you change anything under .claude/:
#     bash tests/run-tests.sh
#
# Everything runs against throwaway copies in a temp dir — it never touches
# the real game/ or snapshot history. Exit 0 = all green.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PY="$(command -v python3 || command -v python || command -v py || true)"
PASS=0
FAIL=0

ok()   { PASS=$((PASS+1)); echo "  PASS  $1"; }
bad()  { FAIL=$((FAIL+1)); echo "  FAIL  $1"; }

check_guard() { # <expected-exit> <label> <command-json-payload>
  local expected="$1" label="$2" cmd="$3" got
  printf '{"tool_input":{"command":"%s"}}' "$cmd" \
    | "$PY" "$ROOT/.claude/hooks/block-danger.py" >/dev/null 2>&1
  got=$?
  [ "$got" -eq "$expected" ] && ok "guard: $label" || bad "guard: $label (exit $got, wanted $expected)"
}

echo "== Roblox Game Builder self-test =="

# --- 0. Prerequisites --------------------------------------------------------
[ -n "$PY" ] && ok "python present" || { bad "python present - EVERYTHING below depends on it"; }
command -v git >/dev/null 2>&1 && ok "git present" || bad "git present"
# Relative path on purpose: Windows Python can't open Git Bash /c/... paths.
(cd "$ROOT" && "$PY" -c "import json; json.load(open('.claude/settings.json'))") 2>/dev/null \
  && ok "settings.json is valid JSON" || bad "settings.json is valid JSON"
for f in block-danger.py auto-save.sh progress-nudge.sh safety-check.sh session-nudge.sh; do
  [ -f "$ROOT/.claude/hooks/$f" ] && ok "hook file exists: $f" || bad "hook file exists: $f"
done
bash -n "$ROOT/.claude/hooks/auto-save.sh" 2>/dev/null && ok "auto-save.sh syntax" || bad "auto-save.sh syntax"
bash -n "$ROOT/.claude/hooks/progress-nudge.sh" 2>/dev/null && ok "progress-nudge.sh syntax" || bad "progress-nudge.sh syntax"
bash -n "$ROOT/.claude/hooks/safety-check.sh" 2>/dev/null && ok "safety-check.sh syntax" || bad "safety-check.sh syntax"
bash -n "$ROOT/.claude/hooks/session-nudge.sh" 2>/dev/null && ok "session-nudge.sh syntax" || bad "session-nudge.sh syntax"

# --- 0.5 Skills (the agents' Roblox knowledge packs) -------------------------
for s in roblox-luau-basics roblox-game-recipes roblox-safe-scripting \
         roblox-gui-basics roblox-fix-recipes roblox-npcs-and-enemies; do
  f="$ROOT/.claude/skills/$s/SKILL.md"
  [ -f "$f" ] && ok "skill exists: $s" || bad "skill exists: $s"
  head -6 "$f" 2>/dev/null | grep -q "^description:" \
    && ok "skill has frontmatter: $s" || bad "skill has frontmatter: $s"
done

# --- 1. The dangerous-command guard ------------------------------------------
if [ -n "$PY" ]; then
  # Must BLOCK (exit 2):
  check_guard 2 "blocks rm -rf /"                'rm -rf /'
  check_guard 2 "blocks rm -r of a drive root"   'rm -r C:\\\\'
  check_guard 2 "blocks del /s of a drive root"  'del /s C:\\\\'
  check_guard 2 "blocks diskpart"                'diskpart'
  check_guard 2 "blocks deleting .git"           'rm -rf .git'
  check_guard 2 "blocks nested .git delete"      'rm -rf ./game/.git'
  check_guard 2 "blocks Remove-Item -Recurse C:" 'Remove-Item -Recurse -Force C:/'
  check_guard 2 "blocks dd onto a disk"          'dd if=/dev/zero of=/dev/sda'
  check_guard 2 "blocks rm -rf home"             'rm -rf ~'
  check_guard 2 "sees through wrappers"          'timeout 5 rm -rf ~'
  # Must ALLOW (exit 0):
  check_guard 0 "allows quoted mention in a message" "git commit -m 'never rm -rf / here'"
  check_guard 0 "allows deleting a project subfolder" 'rm -rf game/archive/old'
  check_guard 0 "allows plain commands"          'echo hello'
fi

# --- 2. auto-save + progress-nudge in a scratch repo --------------------------
SCRATCH="$(mktemp -d 2>/dev/null || echo "${TMP:-/tmp}/rgb-selftest-$$")"
mkdir -p "$SCRATCH"
cp -r "$ROOT/." "$SCRATCH/" 2>/dev/null
rm -rf "$SCRATCH/.git"
(
  cd "$SCRATCH" || exit 1
  git init -qb main
  git add -A >/dev/null 2>&1
  GIT_COMMITTER_DATE="2001-01-01T10:00:00" GIT_AUTHOR_DATE="2001-01-01T10:00:00" \
    git -c user.name=t -c user.email=t@t commit -qm "base" >/dev/null 2>&1

  # snapshot happens, with forced identity (no git config needed)
  echo "x" >> game/PROGRESS.md
  bash .claude/hooks/auto-save.sh "test" >/dev/null 2>&1
  git log --oneline -1 | grep -q "snapshot: test"
) && ok "auto-save creates snapshots without git identity" \
  || bad "auto-save creates snapshots without git identity"

(
  cd "$SCRATCH" || exit 1
  # player flag strips remotes
  git remote add origin https://example.com/fake.git 2>/dev/null
  git config gamebuilder.player true
  echo "y" >> game/PROGRESS.md
  bash .claude/hooks/auto-save.sh "strip" >/dev/null 2>&1
  [ -z "$(git remote)" ]
) && ok "auto-save strips remotes on a player machine" \
  || bad "auto-save strips remotes on a player machine"

(
  cd "$SCRATCH" || exit 1
  # nudge fires when scripts changed but PROGRESS.md didn't (base is backdated)
  rm -rf .git && git init -qb main && git add -A >/dev/null 2>&1
  GIT_COMMITTER_DATE="2001-01-01T10:00:00" GIT_AUTHOR_DATE="2001-01-01T10:00:00" \
    git -c user.name=t -c user.email=t@t commit -qm "base" >/dev/null 2>&1
  echo "code" > game/scripts/TEST-thing.server.luau
  bash .claude/hooks/auto-save.sh "built" >/dev/null 2>&1
  echo '{}' | bash .claude/hooks/progress-nudge.sh >/dev/null 2>&1
  [ $? -eq 2 ]
) && ok "progress-nudge fires when PROGRESS.md was skipped" \
  || bad "progress-nudge fires when PROGRESS.md was skipped"

(
  cd "$SCRATCH" || exit 1
  echo '{"stop_hook_active":true}' | bash .claude/hooks/progress-nudge.sh >/dev/null 2>&1
  [ $? -eq 0 ]
) && ok "progress-nudge never loops (stop_hook_active)" \
  || bad "progress-nudge never loops (stop_hook_active)"

# --- 3. safety-check -----------------------------------------------------------
(
  cd "$SCRATCH" || exit 1
  out="$(bash .claude/hooks/safety-check.sh 2>/dev/null)"
  [ $? -eq 0 ] && [ -z "$out" ]
) && ok "safety-check silent when healthy" \
  || bad "safety-check silent when healthy"

(
  cd "$SCRATCH" || exit 1
  mv .claude/hooks/block-danger.py .claude/hooks/block-danger.py.bak
  out="$(bash .claude/hooks/safety-check.sh 2>/dev/null)"
  mv .claude/hooks/block-danger.py.bak .claude/hooks/block-danger.py
  printf '%s' "$out" | grep -q "SAFETY CHECK FAILED"
) && ok "safety-check reports a broken guard" \
  || bad "safety-check reports a broken guard"

# --- 4. session-nudge ------------------------------------------------------------
(
  cd "$SCRATCH" || exit 1
  rm -rf .claude/.tmp
  out=""
  for i in 1 2 3; do
    out="$(echo '{"session_id":"selftest"}' | RGB_NUDGE_PROMPTS=3 bash .claude/hooks/session-nudge.sh)"
  done
  printf '%s' "$out" | grep -q "suggest a break"
) && ok "session-nudge fires at the threshold" \
  || bad "session-nudge fires at the threshold"

(
  cd "$SCRATCH" || exit 1
  out="$(echo '{"session_id":"selftest"}' | RGB_NUDGE_PROMPTS=3 bash .claude/hooks/session-nudge.sh)"
  [ -z "$out" ]
) && ok "session-nudge nudges only once per session" \
  || bad "session-nudge nudges only once per session"

rm -rf "$SCRATCH" 2>/dev/null

# --- Summary ---------------------------------------------------------------------
echo ""
echo "== $PASS passed, $FAIL failed =="
[ "$FAIL" -eq 0 ]
