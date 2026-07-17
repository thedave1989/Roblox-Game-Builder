#!/usr/bin/env python3
"""PreToolUse gate for the Roblox Studio MCP tools — the F1 fix.

The shell guard (block-danger.py) protects the *computer*. This guard protects
*Studio*: every call to the Studio MCP server runs code or changes objects
inside the child's game, and until now nothing enforced the checker's review on
that path — the whole server was allowlisted so the child saw no prompts, and a
Toolbox model's script or injected text could have steered an unreviewed write.

WHAT IT DOES (design §3):
  * It is wired on the ENTIRE Studio MCP namespace (mcp__<server>__.*), so even
    a tool added by a future server update passes through it.
  * Dave classifies each real tool once, at /checkup, into .claude/studio-tools.json:
      "auto"     reads / console / mode / play start-stop  -> pass through
      "artifact" bounded writes (script installs)          -> must prove boundedness
      "dave"     arbitrary exec / model insertion / unknown -> blocked, fetch Dave
  * An "artifact" script install must be the EXACT install-wrapper template
    (.claude/templates/install-wrapper.luau) whose embedded source hashes to a
    checker-recorded entry in game/.builder/approved.json. Anything else — raw
    hand-authored Luau, extra statements, a stale or wrong-target hash — is blocked.
  * Toolbox insertion, if ever automated, is confined to a non-running
    ServerStorage/ToolboxQuarantine parent; otherwise it stays "dave".

FAIL MODES (deliberately unlike the shell guard):
  * missing Python -> the settings.json wrapper fails CLOSED (refuses the call).
  * an unparseable event, an unconfigured framework, an unclassifiable tool, or
    any payload this guard cannot positively validate -> fail CLOSED (exit 2).
  An unvalidatable Studio write must never run. (The shell guard fails OPEN on
  parse errors because blocking the whole tool loop on a harness hiccup is worse
  there; a Studio write is rarer and higher-stakes, so the trade flips.)

HONESTY: like the shell guard this is defence in depth, not a hard boundary. The
template match + hash is a strong structural control; the forbidden-API scan is a
secondary floor, defeatable by obfuscation. The checker (a prompt-level review)
is quality control, not enforcement — which is exactly why this hook exists.

Every block ends with the one escape hatch a 10-year-old can use: ask Dave.
"""
import hashlib
import json
import os
import re
import sys

BUILDER_TAG = "studio-gate"


def _block(hint: str) -> None:
    """Refuse the tool call with kid-safe copy, then exit 2 (fail closed)."""
    print(
        "BLOCKED: something about this change to your game didn't look safe, so "
        "I didn't do it. Nothing was changed.\n"
        f"If you're stuck, say: \"ask Dave to look at this — tell him: {hint}\".",
        file=sys.stderr,
    )
    sys.exit(2)


# --- Opt-out (Dave only), same convention as block-danger -------------------
_disabled = os.environ.get("CLAUDE_DISABLED_HOOKS", "")
if "studio-gate" in [t.strip() for t in _disabled.replace(",", " ").split()]:
    sys.exit(0)

# --- Read the event. Unparseable -> fail closed. ---------------------------
try:
    data = json.load(sys.stdin)
    if not isinstance(data, dict):
        raise ValueError
except (ValueError, json.JSONDecodeError):
    _block("the Studio safety gate got something it couldn't read")

tool_name = data.get("tool_name") or data.get("tool") or ""
tool_input = data.get("tool_input")
if not isinstance(tool_input, dict):
    tool_input = {}

# A well-formed non-MCP tool name is not ours to judge (exit 0). But an event
# that parsed yet carries no tool name is malformed -> fail closed.
if not isinstance(tool_name, str) or not tool_name:
    _block("the Studio safety gate got an event with no tool name")
if not tool_name.startswith("mcp__"):
    sys.exit(0)


# --- Load Dave's tool classification. Missing/invalid -> fail closed. -------
def _load_json(path):
    try:
        with open(path, "r", encoding="utf-8") as fh:
            return json.load(fh)
    except (OSError, ValueError):
        return None


tools_cfg = _load_json(".claude/studio-tools.json")
if not isinstance(tools_cfg, dict) or not isinstance(tools_cfg.get("tools"), dict):
    _block("Studio isn't set up yet — run /checkup to list the Studio tools")

# mcp__<server>__<tool>
parts = tool_name.split("__", 2)
if len(parts) != 3:
    _block("the Studio safety gate got a tool name it couldn't read")
srv, short = parts[1], parts[2]

# If Dave has pinned the server name, only THAT server's tools are classified;
# a same-named tool on any other MCP server is unknown -> default-deny.
cfg_server = tools_cfg.get("server")
if cfg_server and cfg_server != "SET-BY-CHECKUP" and srv != cfg_server:
    _block(f"Studio wants a tool from an unexpected place ('{srv}')")

entry = tools_cfg["tools"].get(short, "dave")   # default-deny the unclassified

# Normalise the entry to {tier, ...}.
if isinstance(entry, str):
    cfg = {"tier": entry}
elif isinstance(entry, dict):
    cfg = dict(entry)
else:
    _block(f"the Studio tool '{short}' is set up in a way I don't understand")
tier = cfg.get("tier", "dave")


# --- Helpers ---------------------------------------------------------------
def _all_strings(obj):
    """Every string anywhere in the tool input — values AND dict keys (payloads
    hide in fields whose names we can't assume across MCP versions)."""
    out = []
    if isinstance(obj, str):
        out.append(obj)
    elif isinstance(obj, dict):
        for k, v in obj.items():
            if isinstance(k, str):
                out.append(k)
            out.extend(_all_strings(v))
    elif isinstance(obj, list):
        for v in obj:
            out.extend(_all_strings(v))
    return out


_FORBIDDEN = re.compile(
    r"\bloadstring\b|\bgetfenv\b|\bsetfenv\b|\bHttpService\b|\brequire\s*\(\s*\d"
)

# The install-wrapper template, as a matcher. Kept in lockstep with
# .claude/templates/install-wrapper.luau — the "template drift" self-test fails
# on purpose if they diverge. Anchored: nothing may precede or follow it.
_TEMPLATE = re.compile(
    r'-- GB-INSTALL v1\n'
    r'local parent = game:GetService\("'
    r'(?P<service>ServerScriptService|ReplicatedStorage|StarterPlayer|StarterGui|ServerStorage|Workspace)'
    r'"\)(?P<childpath>(?::WaitForChild\("[A-Za-z0-9_ -]+"\))*)\n'
    r'local old = parent:FindFirstChild\("(?P<name1>[A-Za-z0-9_-]+)"\)\n'
    r'if old then old:Destroy\(\) end\n'
    r'local s = Instance\.new\("(?P<class>Script|LocalScript|ModuleScript)"\)\n'
    r's\.Name = "(?P<name2>[A-Za-z0-9_-]+)"\n'
    r's\.Source = \[(?P<eq>=*)\[(?P<source>.*?)\](?P=eq)\]\n'
    r's\.Parent = parent',
    re.DOTALL,
)
_CHILD_SEG = re.compile(r':WaitForChild\("([A-Za-z0-9_ -]+)"\)')


def _norm_text(text: str) -> str:
    """Strip CR so CRLF vs LF never changes a template match or a hash."""
    return text.replace("\r\n", "\n").replace("\r", "\n")


def _norm(text: str) -> bytes:
    """Hash input, newline-normalised (see _norm_text)."""
    return _norm_text(text).encode("utf-8")


def _approved_targets():
    rec = _load_json("game/.builder/approved.json")
    steps = rec.get("steps") if isinstance(rec, dict) else None
    return list(steps.values()) if isinstance(steps, dict) else []


def _target_matches(t, service, child_segs, name, cls) -> bool:
    if not isinstance(t, dict):
        return False
    tt = t.get("target", {})
    return (
        tt.get("service") == service
        and list(tt.get("childPath", [])) == child_segs
        and tt.get("name") == name
        and tt.get("class") == cls
    )


# --- Dispatch by tier ------------------------------------------------------
if tier == "auto":
    sys.exit(0)                       # reads / console / mode / play — no friction

if tier not in ("artifact", "quarantine"):
    # "dave", "blocked", or any unrecognised tier -> fetch Dave.
    _block(f"Studio wants to use '{short}', which only Dave should run")

# Both remaining tiers name the ONE field of tool_input that carries their
# payload (recorded by Dave at /checkup as {"tier":..., "field":"<arg>"}). We
# validate exactly that field and let NOTHING else ride along — a second string
# field could otherwise smuggle unreviewed code past a valid-looking one.
field = cfg.get("field")
if not isinstance(field, str) or not field:
    _block(f"the Studio tool '{short}' isn't fully set up — Dave must name its code field")
payload = tool_input.get(field)
if not isinstance(payload, str):
    _block("this code didn't go through the checker")

others = _all_strings(tool_input)
try:
    others.remove(payload)            # drop one instance of the field we validate
except ValueError:
    pass
for s in others:
    # No other field may carry an install marker or a blob big enough to be
    # code. The real guarantee is the one-exec-arg-per-artifact-tool rule in
    # studio-tools.json's _README; this length bound is defence in depth
    # (legit sibling args — ids, timeouts — are short).
    if "-- GB-INSTALL" in s or len(s) > 64:
        _block("this code didn't go through the checker")

if tier == "quarantine":
    # Model insertion, if ever automated: the parent MUST be the quarantine
    # (exact match, not "contains") or nothing is inserted.
    parent_want = cfg.get("parent", "ServerStorage/ToolboxQuarantine")
    if _norm_text(payload).strip() != parent_want:
        _block("a downloaded model can only go into the quarantine area first")
    sys.exit(0)

# tier == "artifact": the payload must be EXACTLY one install-wrapper, hash-approved.
if _FORBIDDEN.search(payload):
    _block("that code used something this framework never allows")

m = _TEMPLATE.fullmatch(_norm_text(payload).strip())
if not m or m.group("name1") != m.group("name2"):
    _block("this code didn't go through the checker")

source = m.group("source")
eq = m.group("eq")
# Luau closes a long string at the FIRST matching bracket, but the regex
# backtracks past an early closer. Reject any source containing this level's
# closer so the regex parse and Luau's parse cannot diverge (a real bypass:
# code after an early ]==] would execute while the hash still matched).
if "]" + eq + "]" in source:
    _block("this code didn't go through the checker")
if _FORBIDDEN.search(source):
    _block("that code used something this framework never allows")

service = m.group("service")
child_segs = _CHILD_SEG.findall(m.group("childpath"))
name = m.group("name1")
cls = m.group("class")
digest = hashlib.sha256(_norm(source)).hexdigest()

for t in _approved_targets():
    if t.get("sha256") == digest and _target_matches(t, service, child_segs, name, cls):
        sys.exit(0)                  # exactly this source, reviewed, for this target

_block("this code didn't go through the checker")
