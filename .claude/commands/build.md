# /build — build the next step of the game

Build EXACTLY ONE step: the first unchecked `- [ ] STEP-N` in
`game/GAME-PLAN.md`. Never more, even if asked to "build the rest" — explain
that one step at a time is how we keep the game safe and them in control.

No plan yet (GAME-PLAN.md is still the placeholder)? Point them to /newgame
and stop.

## The sequence

1. **Say what's next.** "Next up: STEP-N — <name>. Building it now…"
2. **The right agent writes it.** Is the step about LOOKS (a menu/UI screen,
   the sky or lighting, decorating an area) or MECHANICS (things that happen)?
   Spawn the `stylist` for looks, the `builder` for mechanics — give it the
   step text and the "what you'll see" line. Either way the files land in
   `game/scripts/`, and visual steps must follow `game/STYLE.md`.
3. **Checker checks it.** Spawn the `checker` agent on those files. If it says
   FIX NEEDED, send the fix list back to a fresh `builder` run (max 2 repair
   rounds; still failing → tell the player plainly: "This step is fighting me
   — ask Dave to look at this — tell him: checker keeps failing STEP-N", and
   stop. Never install a failing script.)
4. **Install into Studio.** For each script file, follow its `--[[ INSTALL ]]`
   block:
   - **Studio connected** (Roblox Studio MCP tools are available): create the
     object at its Where/Name/Type and set its source, via the MCP tools. If
     "Also needs" lists parts, create those too. Then tell the player what
     appeared and where.
   - **Studio NOT connected** (MCP tools missing or erroring): first say:
     "I can't see Roblox Studio right now. Is it open? If not, open it and
     your game, then try /build again." If it's open and still not working,
     fall back to guided copy-paste — for ONE file at a time: which window
     (Explorer), exactly what to right-click, Insert Object → which type,
     what to rename it, then "delete everything inside and paste what I give
     you". Show the code in one block. Confirm they did it before the next
     file.
5. **Wrap up.** Update `game/PROGRESS.md` (2-3 plain lines: what was built,
   what's next). Do NOT tick the GAME-PLAN checkbox yet — that happens in
   /test when they've SEEN it work. End with: **"Now type /test and let's make
   sure it works!"**

Snapshots are automatic — never mention saving, versions, or anything
technical about how their work is kept safe.
