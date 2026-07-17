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
SKIP=0

ok()   { PASS=$((PASS+1)); echo "  PASS  $1"; }
bad()  { FAIL=$((FAIL+1)); echo "  FAIL  $1"; }
skip() { SKIP=$((SKIP+1)); echo "  SKIP  $1"; }

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
for f in block-danger.py auto-save.sh progress-nudge.sh safety-check.sh \
         session-nudge.sh studio-gate.py record-approval.py; do
  [ -f "$ROOT/.claude/hooks/$f" ] && ok "hook file exists: $f" || bad "hook file exists: $f"
done
[ -f "$ROOT/.claude/templates/install-wrapper.luau" ] \
  && ok "template exists: install-wrapper.luau" || bad "template exists: install-wrapper.luau"
bash -n "$ROOT/.claude/hooks/auto-save.sh" 2>/dev/null && ok "auto-save.sh syntax" || bad "auto-save.sh syntax"
bash -n "$ROOT/.claude/hooks/progress-nudge.sh" 2>/dev/null && ok "progress-nudge.sh syntax" || bad "progress-nudge.sh syntax"
bash -n "$ROOT/.claude/hooks/safety-check.sh" 2>/dev/null && ok "safety-check.sh syntax" || bad "safety-check.sh syntax"
bash -n "$ROOT/.claude/hooks/session-nudge.sh" 2>/dev/null && ok "session-nudge.sh syntax" || bad "session-nudge.sh syntax"
(cd "$ROOT" && "$PY" -c "import json; json.load(open('.claude/studio-tools.json'))") 2>/dev/null \
  && ok "studio-tools.json is valid JSON" || bad "studio-tools.json is valid JSON"

# --- 0.5 Skills (the agents' Roblox knowledge packs) -------------------------
check_skill() { # <name> <required: y|n>
  local s="$1" required="$2" f="$ROOT/.claude/skills/$1/SKILL.md"
  if [ ! -f "$f" ]; then
    if [ "$required" = "y" ]; then
      bad "skill exists: $s"
    else
      skip "skill exists: $s (not authored yet - expected while skills work is in flight)"
    fi
    return
  fi
  ok "skill exists: $s"
  head -6 "$f" 2>/dev/null | grep -q "^description:" \
    && ok "skill has frontmatter: $s" || bad "skill has frontmatter: $s"
  local lines bytes
  lines="$(wc -l < "$f" 2>/dev/null || echo 999999)"
  bytes="$(wc -c < "$f" 2>/dev/null || echo 999999999)"
  if [ "$lines" -le 150 ] && [ "$bytes" -le 6144 ]; then
    ok "skill within size budget: $s ($lines lines, $bytes bytes)"
  else
    bad "skill within size budget: $s ($lines lines, $bytes bytes)"
  fi
}

for s in roblox-luau-basics roblox-game-recipes roblox-safe-scripting \
         roblox-gui-basics roblox-fix-recipes roblox-npcs-and-enemies; do
  check_skill "$s" y
done
for s in roblox-sound-and-music roblox-worlds-and-terrain roblox-player-data \
         roblox-badges-and-passes roblox-code-peek; do
  check_skill "$s" n
done

# --- 0.6 Command files -------------------------------------------------------
for c in newgame build test fix undo publish peek help checkup; do
  [ -f "$ROOT/.claude/commands/$c.md" ] && ok "command exists: /$c" || bad "command exists: /$c"
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
  for _ in 1 2 3; do
    out="$(printf '{"session_id":"selftest","prompt":"/build"}' | RGB_NUDGE_ACTIONS=3 bash .claude/hooks/session-nudge.sh)"
  done
  printf '%s' "$out" | grep -q "suggest a break"
) && ok "session-nudge fires at the action threshold" \
  || bad "session-nudge fires at the action threshold"

(
  cd "$SCRATCH" || exit 1
  out="$(printf '{"session_id":"selftest","prompt":"/build"}' | RGB_NUDGE_ACTIONS=3 bash .claude/hooks/session-nudge.sh)"
  [ -z "$out" ]
) && ok "session-nudge nudges only once per session" \
  || bad "session-nudge nudges only once per session"

(
  cd "$SCRATCH" || exit 1
  rm -rf .claude/.tmp
  out=""
  for _ in 1 2 3 4; do
    out="$(printf '{"session_id":"selftest2","prompt":"how is it going"}' | RGB_NUDGE_ACTIONS=3 bash .claude/hooks/session-nudge.sh)"
  done
  [ -z "$out" ]
) && ok "session-nudge ignores non-build/fix prompts" \
  || bad "session-nudge ignores non-build/fix prompts"

# --- 5. Studio gate (F1) -----------------------------------------------------
if [ -n "$PY" ]; then
(
  cd "$SCRATCH" || exit 1
  rm -rf .claude/.tmp game/.builder/approved.json

  # A controlled tool-tier fixture — this matrix must not depend on whatever
  # tiers happen to be sitting in the shipped .claude/studio-tools.json.
  cat > .claude/studio-tools.json <<'JSON'
{
  "server": "roblox_studio",
  "tools": {
    "get_console_output": "auto",
    "run_code": {"tier": "artifact", "field": "command"},
    "insert_model": "dave",
    "insert_quar": {"tier": "quarantine", "field": "parent"}
  }
}
JSON

  mkdir -p game/.builder game/scripts
  printf 'local x = 1\n' > game/scripts/TEST-coins.server.luau
  # An approved file that legitimately contains this level's closer ]==]
  # (the long-bracket differential vector).
  printf 'local a = "]==]"\nlocal b = 2\n' > game/scripts/TEST-evil.server.luau

  # Real recorder, real hash — proves the matrix against actual approval
  # bookkeeping, not a hand-crafted approved.json.
  "$PY" .claude/hooks/record-approval.py --by test \
    --step STEP-1-coins --artifact game/scripts/TEST-coins.server.luau \
    --service ServerScriptService --name Coins --class Script \
    >/dev/null 2>&1
  "$PY" .claude/hooks/record-approval.py --by test \
    --step STEP-2-evil --artifact game/scripts/TEST-evil.server.luau \
    --service ServerScriptService --name Evil --class Script \
    >/dev/null 2>&1

  # Build every install payload from the REAL template, so drift between
  # the template and this test can't hide a bug either way.
  "$PY" - <<'PYEOF'
import json, pathlib

tmpl = pathlib.Path(".claude/templates/install-wrapper.luau").read_text(encoding="utf-8")
body = tmpl[tmpl.rindex("-- GB-INSTALL v1"):]
source = pathlib.Path("game/scripts/TEST-coins.server.luau").read_text(encoding="utf-8")
evil = pathlib.Path("game/scripts/TEST-evil.server.luau").read_text(encoding="utf-8")

def fill(service="ServerScriptService", child="", name="Coins", cls="Script", eq="", src=None):
    s = body
    s = s.replace("<SERVICE>", service, 1)
    s = s.replace("<CHILD_PATH>", child, 1)
    s = s.replace('"<NAME>"', '"%s"' % name, 2)
    s = s.replace("<CLASS>", cls, 1)
    s = s.replace("<EQ>", eq, 2)
    s = s.replace("<SOURCE>", src if src is not None else source, 1)
    return s

def gate(tool, inp):
    return {"tool_name": "mcp__roblox_studio__" + tool, "tool_input": inp}

fixtures = {
    "gate-approved.json":       gate("run_code", {"command": fill()}),
    "gate-wrong-target.json":   gate("run_code", {"command": fill(name="Different")}),
    "gate-extra-stmt.json":     gate("run_code", {"command": fill() + '\nprint("extra")'}),
    "gate-stale-hash.json":     gate("run_code", {"command": fill(src=source + "-- edited\n")}),
    "gate-forbidden.json":      gate("run_code", {"command": fill(src="loadstring('x')()")}),
    "gate-template-drift.json": gate("run_code", {"command": fill().replace("s.Parent = parent", "s.Parent = parent -- x")}),
    "gate-raw.json":            gate("run_code", {"command": "print('hand authored')"}),
    "gate-unknown-tool.json":   gate("mystery_tool", {}),
    "gate-dave-tier.json":      gate("insert_model", {"query": "castle"}),
    # P0-1 multi-field smuggle: valid install in one field, extra code in another.
    "gate-smuggle-marker.json": gate("run_code", {"command": fill(), "note": fill()}),
    "gate-smuggle-blob.json":   gate("run_code", {"command": fill(), "note": "x" * 300}),
    # P0-2 long-bracket differential: approved source with ]==], wrapped at eq="==".
    "gate-longbracket.json":    gate("run_code", {"command": fill(name="Evil", eq="==", src=evil)}),
    # CRLF payload must still pass (newline-normalised before match).
    "gate-crlf.json":           gate("run_code", {"command": fill().replace("\n", "\r\n")}),
    # Quarantine tier: exact parent only.
    "gate-quar-ok.json":        gate("insert_quar", {"parent": "ServerStorage/ToolboxQuarantine"}),
    "gate-quar-bad.json":       gate("insert_quar", {"parent": "Workspace"}),
    "gate-quar-comment.json":   gate("insert_quar", {"parent": "Workspace", "x": "ServerStorage/ToolboxQuarantine"}),
    # Same tool name on a different MCP server -> default-deny.
    "gate-wrong-server.json":   {"tool_name": "mcp__other__get_console_output", "tool_input": {}},
    # Parsed event with no tool name -> fail closed.
    "gate-empty-name.json":     {"tool_name": "", "tool_input": {}},
}
for fname, payload in fixtures.items():
    pathlib.Path(fname).write_text(json.dumps(payload), encoding="utf-8")
PYEOF
) >/dev/null 2>&1
fi

check_gate() { # <expected-exit> <label> <payload-file>
  local expected="$1" label="$2" file="$3" got
  (cd "$SCRATCH" && "$PY" .claude/hooks/studio-gate.py < "$SCRATCH/$file") >/dev/null 2>&1
  got=$?
  [ "$got" -eq "$expected" ] && ok "gate: $label" || bad "gate: $label (exit $got, wanted $expected)"
}

if [ -n "$PY" ]; then
  check_gate 0 "approved template install passes"        "gate-approved.json"
  check_gate 2 "raw hand-authored Luau blocked"          "gate-raw.json"
  check_gate 2 "wrapper with an extra statement blocked" "gate-extra-stmt.json"
  check_gate 2 "stale/wrong hash blocked"                "gate-stale-hash.json"
  check_gate 2 "wrong target blocked"                    "gate-wrong-target.json"
  check_gate 2 "forbidden API (loadstring) blocked"      "gate-forbidden.json"
  check_gate 2 "unknown/unlisted tool blocked"           "gate-unknown-tool.json"
  check_gate 2 "dave-tier tool blocked"                  "gate-dave-tier.json"
  check_gate 2 "template drift blocked"                  "gate-template-drift.json"
  check_gate 2 "multi-field marker smuggle blocked"      "gate-smuggle-marker.json"
  check_gate 2 "multi-field blob smuggle blocked"        "gate-smuggle-blob.json"
  check_gate 2 "long-bracket differential blocked"       "gate-longbracket.json"
  check_gate 0 "CRLF payload still passes"               "gate-crlf.json"
  check_gate 0 "quarantine correct parent passes"        "gate-quar-ok.json"
  check_gate 2 "quarantine wrong parent blocked"         "gate-quar-bad.json"
  check_gate 2 "quarantine parent-in-comment blocked"    "gate-quar-comment.json"
  check_gate 2 "tool on wrong MCP server blocked"        "gate-wrong-server.json"
  check_gate 2 "empty tool name fails closed"            "gate-empty-name.json"
  printf 'not json' | "$PY" "$ROOT/.claude/hooks/studio-gate.py" >/dev/null 2>&1
  [ $? -eq 2 ] && ok "gate: unparseable stdin blocked" || bad "gate: unparseable stdin blocked"
fi

rm -rf "$SCRATCH" 2>/dev/null

# --- Summary ---------------------------------------------------------------------
echo ""
echo "== $PASS passed, $FAIL failed, $SKIP skipped =="
[ "$FAIL" -eq 0 ]
