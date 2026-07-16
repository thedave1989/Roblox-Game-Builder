#!/usr/bin/env python3
"""PreToolUse guard: refuse to run a command that would irreversibly destroy
the machine or its data.

Adapted for Roblox Game Builder from CCMAF's block-dangerous-commands.py
(github.com/drushegh/CCMAF). Changes from the donor: telemetry removed
(this framework ships none), Windows-native destructive tools added
(del/erase /s, PowerShell Remove-Item -Recurse, diskpart), and the block
message rewritten so a non-technical user knows what to do next.

Design — why it looks the way it does:

  This guard reasons about the *structure* of a command, never about
  substrings of its raw text. It splits the command line into simple
  commands with a quote-aware lexer, finds the program actually being run
  in each, and asks one question: "is a data-destroying tool being pointed,
  in a destructive mode, at a protected location?"

  It deliberately holds NO catalogue of example bad commands. It knows only
  two things, kept as small tables below:
    * PROTECTED locations worth guarding (filesystem/drive roots, the home
      directory, whole block devices); and
    * the TOOLS that can wipe them (recursive-force delete, low-level disk
      writers, filesystem formatters), plus the shell shapes that are
      destructive on their own (redirecting into a block device; a
      self-referential fork bomb).
  Judging the *program position* rather than the raw text is what stops it
  from blocking an innocent command that merely mentions a scary phrase in a
  commit message, a heredoc body, or a quoted argument.

  Scope and honesty: this is DEFENCE IN DEPTH, not a security boundary. It
  is heuristic and can be defeated by deliberate obfuscation — those are out
  of scope by design. It fails OPEN on input it cannot parse, because a
  guard that crashed the tool loop on a harness hiccup would be worse than
  the risk it mitigates.
"""
import json
import os
import re
import shlex
import sys

# --- Opt-out gate ----------------------------------------------------------
# Only an explicit CLAUDE_DISABLED_HOOKS entry naming "block-danger" turns
# this off — a deliberate override by whoever maintains the machine (Dave).
_disabled = os.environ.get("CLAUDE_DISABLED_HOOKS", "")
if "block-danger" in [t.strip() for t in _disabled.replace(",", " ").split()]:
    sys.exit(0)

# --- Read the event, failing open on anything we cannot judge -------------
try:
    data = json.load(sys.stdin)
except (ValueError, json.JSONDecodeError):
    sys.exit(0)
if not isinstance(data, dict):
    sys.exit(0)
tool_input = data.get("tool_input")
cmd = tool_input.get("command", "") if isinstance(tool_input, dict) else ""
if not isinstance(cmd, str) or not cmd.strip():
    sys.exit(0)


# --- What we protect: locations a destructive tool must never wipe wholesale
def _norm(token: str) -> str:
    """Strip surrounding quotes and normalise separators for comparison."""
    return token.strip().strip("\"'").replace("\\", "/")


_ROOTS = (
    re.compile(r"/+\*?$"),            # filesystem root: a lone slash, opt. glob
    re.compile(r"[A-Za-z]:/?\*?$"),   # a Windows drive root (C:\, F:/ …)
    # Git Bash / WSL / Cygwin drive mounts (`/c`, `/mnt/c`, `/cygdrive/c`).
    re.compile(r"/(mnt/|cygdrive/)?[A-Za-z]/?\*?$"),
)
_HOME = {"~", "~/", "$HOME", "${HOME}", "$HOME/", "${HOME}/",
         "$env:USERPROFILE", "$env:USERPROFILE/"}
# Whole block devices (raw disks / partitions), never individual files under them.
_BLOCK_DEVICE = re.compile(
    r"^/dev/(sd[a-z]+\d*|nvme\d+n\d+(p\d+)?|hd[a-z]+\d*|vd[a-z]+\d*"
    r"|disk\d+(s\d+)?|mmcblk\d+(p\d+)?)$"
)


def _is_block_device(token: str) -> bool:
    return bool(_BLOCK_DEVICE.match(_norm(token)))


def _is_protected_target(token: str) -> bool:
    t = _norm(token)
    if t in _HOME:
        return True
    # The .git directory IS the player's undo history — the substance behind
    # "you can't lose work". No recursive delete may ever point at it.
    stripped = t.rstrip("/*").rstrip("/")
    if stripped == ".git" or stripped.endswith("/.git") or "/.git/" in t:
        return True
    # Home-directory glob wipe: `rm -rf ~/*` destroys the home directory's
    # contents exactly as `rm -rf ~` would.
    if t.endswith("*"):
        base = t[:-1]
        if base.endswith("/"):
            base = base[:-1]
        if base in _HOME:
            return True
    if any(r.match(t) for r in _ROOTS):
        return True
    return _is_block_device(t)


# --- Parsing: split into simple commands, quote-aware -----------------------
_OPERATORS = {";", "&", "&&", "|", "||"}
_WRAPPERS = {"sudo", "doas", "command", "env", "nice", "nohup", "time",
             "timeout", "stdbuf", "setsid", "xargs"}


def _simple_commands(command: str):
    """Yield token lists, one per simple command, respecting shell quoting."""
    for line in command.split("\n"):
        if not line.strip():
            continue
        lexer = shlex.shlex(line, posix=True, punctuation_chars=True)
        lexer.whitespace_split = True
        try:
            tokens = list(lexer)
        except ValueError:
            tokens = line.split()
        segment: list[str] = []
        for tok in tokens:
            if tok in _OPERATORS:
                if segment:
                    yield segment
                    segment = []
            else:
                segment.append(tok)
        if segment:
            yield segment


def _program_and_args(tokens):
    i = 0
    n = len(tokens)
    while i < n:
        tok = tokens[i]
        if re.match(r"^[A-Za-z_]\w*=", tok):     # inline env assignment
            i += 1
            continue
        if tok in _WRAPPERS:
            i += 1
            while i < n and (
                tokens[i].startswith("-")
                or re.match(r"^\d+(\.\d+)?[smhd]?$", tokens[i])
            ):
                i += 1
            continue
        break
    if i >= n:
        return None, []
    program = _norm(tokens[i]).rsplit("/", 1)[-1].lower()
    return program, tokens[i + 1:]


# --- Per-tool destructiveness rules ----------------------------------------
def _rm_wipes_protected(args) -> bool:
    """A recursive delete aimed at a protected location."""
    recursive = False
    targets = []
    for tok in args:
        if tok == "--recursive":
            recursive = True
        elif tok.startswith("--"):
            continue
        elif tok.startswith("-") and len(tok) > 1:
            if "r" in tok[1:].lower():     # -r, -R, -rf, -fr …
                recursive = True
        elif tok != "--":
            targets.append(tok)
    return recursive and any(_is_protected_target(t) for t in targets)


def _rmdir_wipes_protected(args) -> bool:
    """Windows rd/rmdir (or del/erase) removing a protected root recursively."""
    recursive = any(a.lower() in ("/s", "-r", "--recursive") for a in args)
    return recursive and any(_is_protected_target(a) for a in args)


def _remove_item_wipes_protected(args) -> bool:
    """PowerShell Remove-Item -Recurse aimed at a protected location."""
    recursive = any(a.lower().startswith("-recurse") or a.lower() == "-r"
                    for a in args)
    return recursive and any(_is_protected_target(a) for a in args)


def _targets_block_device(args) -> bool:
    """A low-level tool (disk writer / formatter) aimed at a whole device."""
    for tok in args:
        value = _norm(tok)
        if value.startswith("of="):   # dd-style output-file argument
            value = value[3:]
        if _is_block_device(value):
            return True
    return False


def _format_targets_root(args) -> bool:
    """Windows `format` aimed at a drive root."""
    return any(_is_protected_target(a) for a in args)


def _always(args) -> bool:
    """Tools with no safe use in this framework (whole-disk partitioners)."""
    return True


# program name -> predicate over its parsed arguments
_TOOL_RULES = {
    "rm": _rm_wipes_protected,
    "rmdir": _rmdir_wipes_protected,
    "rd": _rmdir_wipes_protected,
    "del": _rmdir_wipes_protected,
    "erase": _rmdir_wipes_protected,
    "remove-item": _remove_item_wipes_protected,
    "ri": _remove_item_wipes_protected,
    "dd": _targets_block_device,
    "mkfs": _targets_block_device,   # also mkfs.ext4 etc. (see dispatch below)
    "shred": _targets_block_device,
    "wipefs": _targets_block_device,
    "blkdiscard": _targets_block_device,
    "tee": _targets_block_device,    # tee's targets are all outputs
    "format": _format_targets_root,
    "diskpart": _always,             # never needed to build a Roblox game
}


# --- Whole-line shell shapes that are destructive regardless of program ----
def _redirects_into_device(tokens) -> bool:
    for a, b in zip(tokens, tokens[1:]):
        if a in (">", ">|", ">>") and _is_block_device(b):
            return True
    return False


_FORK_BOMB = re.compile(r"([^\s(){}|&;]+)\(\)\s*\{[^}]*\|\s*\1[^}]*&")
_QUOTED = re.compile(r"'[^']*'|\"[^\"]*\"")


def _is_fork_bomb(command: str) -> bool:
    return bool(_FORK_BOMB.search(_QUOTED.sub(" ", command)))


def _is_catastrophic(command: str) -> bool:
    if _is_fork_bomb(command):
        return True
    for tokens in _simple_commands(command):
        if _redirects_into_device(tokens):
            return True
        program, args = _program_and_args(tokens)
        if program is None:
            continue
        rule = _TOOL_RULES.get("mkfs" if program.startswith("mkfs") else program)
        if rule and rule(args):
            return True
    return False


if _is_catastrophic(cmd):
    # Truncate the echo: the command may embed something sensitive.
    shown = cmd if len(cmd) <= 200 else cmd[:200] + "…[truncated]"
    print(
        "BLOCKED: that command could permanently destroy files on this "
        f"computer, so it was not run: {shown}\n"
        "Nothing was changed. Find another way to do this that does not "
        "delete whole folders or drives. If you are stuck, stop and say: "
        "\"ask Dave to look at this — the safety guard blocked a command\".",
        file=sys.stderr,
    )
    sys.exit(2)
