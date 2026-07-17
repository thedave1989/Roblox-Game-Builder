#!/usr/bin/env python3
"""Record a checker-approved script so the Studio gate will let it install.

The Studio gate (studio-gate.py) only lets a run_code install through if the
source it carries hashes to an entry in game/.builder/approved.json AND targets
the recorded service/name/class. This script writes those entries. It binds
"this exact source was reviewed, for this exact place" to the install, so the
gate enforces the checker instead of trusting a convention.

TWO WAYS TO RUN (design §2 Hooks — spike the hook path, keep the CLI fallback):

  1. CLI (the reliable path /build uses right now). After the checker approves,
     the main session records the artifact, THEN installs it:
        python .claude/hooks/record-approval.py \
          --step coins-1 --artifact game/scripts/coins.server.luau \
          --service ServerScriptService --name Coins --class Script \
          [--child Folder --child SubFolder]

  2. SubagentStop hook (the stronger, to-be-spiked path). Wired on SubagentStop,
     it reads the event on stdin and records any line the checker emitted of the
     form:  GB-APPROVED {"step":"...","artifact":"...","service":"...",
                          "name":"...","class":"...","child":["..."]}
     If no such marker is present it exits 0 and records nothing.

HONESTY: whichever path writes the record, this is NOT cryptographic attestation
of the checker. A steered main model could write a bogus entry — so the record
raises the bar against accidents and stale installs, not against a compromised
orchestrator. That is why arbitrary exec / model insertion stay Dave-gated even
with this in place. (Documented in README.)
"""
import argparse
import hashlib
import json
import os
import re
import sys

APPROVED = "game/.builder/approved.json"
_ALLOWED_SERVICE = {
    "ServerScriptService", "ReplicatedStorage", "StarterPlayer",
    "StarterGui", "ServerStorage", "Workspace",
}
_ALLOWED_CLASS = {"Script", "LocalScript", "ModuleScript"}


def _norm(text: str) -> bytes:
    """Match studio-gate._norm exactly, or hashes won't line up."""
    return text.replace("\r\n", "\n").replace("\r", "\n").encode("utf-8")


def _hash_file(path: str) -> str:
    with open(path, "r", encoding="utf-8") as fh:
        return hashlib.sha256(_norm(fh.read())).hexdigest()


def _record(step, artifact, service, name, cls, child, recorded_by) -> None:
    if service not in _ALLOWED_SERVICE:
        sys.exit(f"record-approval: unknown service '{service}'")
    if cls not in _ALLOWED_CLASS:
        sys.exit(f"record-approval: unknown class '{cls}'")
    if not re.fullmatch(r"[A-Za-z0-9_-]+", name or ""):
        sys.exit(f"record-approval: bad name '{name}'")
    if child and not isinstance(child, list):
        # A stdin marker could pass a string; iterating it char-by-char would
        # mint a bogus childPath. Require a real list.
        sys.exit("record-approval: child must be a list of folder names")
    for seg in (child or []):
        # Mirror the gate's childPath charset, or the record can never match an install.
        if not re.fullmatch(r"[A-Za-z0-9_ -]+", seg or ""):
            sys.exit(f"record-approval: bad child folder '{seg}'")
    if not os.path.isfile(artifact):
        sys.exit(f"record-approval: no such artifact '{artifact}'")

    os.makedirs(os.path.dirname(APPROVED), exist_ok=True)
    try:
        with open(APPROVED, "r", encoding="utf-8") as fh:
            rec = json.load(fh)
        if not isinstance(rec, dict) or not isinstance(rec.get("steps"), dict):
            rec = {"steps": {}}
    except (OSError, ValueError):
        rec = {"steps": {}}

    rec["steps"][step] = {
        "artifact": artifact,
        "sha256": _hash_file(artifact),
        "target": {
            "service": service,
            "childPath": list(child or []),
            "name": name,
            "class": cls,
        },
        "recordedBy": recorded_by,
    }
    with open(APPROVED, "w", encoding="utf-8") as fh:
        json.dump(rec, fh, indent=2)
        fh.write("\n")


def _from_stdin() -> None:
    """SubagentStop mode: record any GB-APPROVED marker the checker emitted."""
    try:
        raw = sys.stdin.read()
    except OSError:
        sys.exit(0)
    if not raw.strip():
        sys.exit(0)
    # The marker's JSON must stay FLAT (no nested {}) — this scan matches a
    # single brace pair only. If the SubagentStop path is ever spiked with
    # nested fields, replace this with a brace-balanced parser.
    for m in re.finditer(r"GB-APPROVED\s+(\{[^{}]*\})", raw):
        try:
            d = json.loads(m.group(1))
        except ValueError:
            continue
        try:
            _record(
                d["step"], d["artifact"], d["service"], d["name"], d["class"],
                d.get("child", []), "subagent-stop",
            )
        except SystemExit:
            # A malformed marker must never break the Stop hook chain.
            pass
    sys.exit(0)


def main() -> None:
    if len(sys.argv) == 1 and not sys.stdin.isatty():
        _from_stdin()
        return
    p = argparse.ArgumentParser(description="Record a checker-approved script.")
    p.add_argument("--step", required=True)
    p.add_argument("--artifact", required=True)
    p.add_argument("--service", required=True)
    p.add_argument("--name", required=True)
    p.add_argument("--class", dest="cls", required=True)
    p.add_argument("--child", action="append", default=[])
    p.add_argument("--by", default="orchestrator")
    a = p.parse_args()
    _record(a.step, a.artifact, a.service, a.name, a.cls, a.child, a.by)


if __name__ == "__main__":
    main()
