# /build — build the next step of the game

Build EXACTLY ONE step: the first unchecked `- [ ] STEP-N` in
`game/GAME-PLAN.md`. Never more, even if asked to "build the rest" — explain
that one step at a time is how we keep the game safe and them in control.

No plan yet (GAME-PLAN.md is still the placeholder)? Point them to /newgame
and stop.

Spawn budget: 2 (one writer, then the checker). Never more per /build.

## The sequence

1. **Say what's next.** "Next up: STEP-N — <name>. Building it now…"
2. **Pick the writer and its ONE skill card.** Is the step about LOOKS (a
   menu/UI screen, the sky or lighting, decorating an area) or MECHANICS
   (things that happen)? That decides `stylist` vs `builder`. Then open the
   best-fit skill's `SKILL.md` index (`roblox-game-recipes` for a known
   mechanic, `roblox-gui-basics` for anything on screen,
   `roblox-npcs-and-enemies` for anything that moves or fights,
   `roblox-safe-scripting` for money / saving / remotes; `roblox-luau-basics`
   when none fit better) and pick the ONE reference card it points to for this
   step. Spawn the writer with everything it needs pasted straight into the
   prompt: the step text, the "what you'll see" line, and that one card's
   content (the specific card, not the whole skill). Don't make the spawn go re-read GAME-PLAN.md or
   PROGRESS.md itself — you already have them, hand over exactly what's
   needed. Either way the files land in `game/scripts/`, and visual steps
   must follow `game/STYLE.md`.
3. **Checker checks it — contents inline, not a re-read.** Spawn the
   `checker` agent with the proposed file(s)' full contents pasted into the
   prompt, plus the step text and "what you'll see" line — the checker
   shouldn't need to cold-read GAME-PLAN.md or PROGRESS.md either. If it
   says FIX NEEDED, send the fix list back to a fresh `builder` run (max 2
   repair rounds; still failing → tell the player plainly: "This step is
   fighting me — ask Dave to look at this — tell him: checker keeps failing
   STEP-N", and stop. Never install a failing script.)
4. **Record the approval, then install.** Once the checker says PASS:
   a. For each approved file, read its `--[[ INSTALL ]]` block. `Where`
      gives you the service (and, if it names a nested spot — e.g.
      "StarterGui > MainMenu" — the parts after the service become, in
      order, the folders the install has to `WaitForChild` through). `Name`
      and `Type` map straight across (`Type` is the install's `--class`:
      Script/LocalScript/ModuleScript).
   b. Record it, quietly (never show this command or its output to the
      player), so the Studio gate will actually let the install through:

          python .claude/hooks/record-approval.py --step <STEP-N-name> \
            --artifact game/scripts/<file> --service <Service> \
            --name <Name> --class <Script|LocalScript|ModuleScript> \
            [--child <Folder> ...]

   c. **Studio connected, and `run_code` isn't Dave-gated.** Build the
      install payload from `.claude/templates/install-wrapper.luau` — fill
      `<SERVICE>`, `<CHILD_PATH>` (one `:WaitForChild("...")` per folder
      from step (a)), `<NAME>`, `<CLASS>`, and `<SOURCE>` with the EXACT
      bytes of the approved file (copy it byte-for-byte — don't retype or
      reformat it, even whitespace changes fail the hash check; pick
      `<EQ>` per the template's own header comment). Run that payload
      through the MCP `run_code` tool. The Studio gate re-checks it against
      the approval you just recorded before it's allowed to run. If it
      comes back rejected, do NOT retry with a hand-written variant — drop
      straight to the guided copy-paste fallback below. (The install template
      carries SCRIPTS only — if "Also needs" lists parts/objects, those are
      made by the player through the guided Explorer walkthrough in step d,
      never by hand-authored run_code.) Where the MCP offers a
      way to read a script's Source back, do one quick re-read after
      installing to confirm it matches — a nice-to-have check, not a
      blocker if the tool isn't there. Then tell the player what appeared
      and where.
   d. **Studio NOT connected, OR the install got rejected** (this also
      covers `run_code` still sitting at Dave-gated in
      `.claude/studio-tools.json` until Dave's run the `/checkup` gate
      canary): if Studio looks closed, say so plainly first — "I can't see
      Roblox Studio right now. Is it open? If not, open it and your game,
      then try /build again." Otherwise, quietly fall back to guided
      copy-paste — for ONE file at a time: which window (Explorer), exactly
      what to right-click, Insert Object → which type, what to rename it,
      then "delete everything inside and paste what I give you". Show the
      code in one block (the plain approved file — never the install
      wrapper). Confirm they did it before the next file.
5. **Wrap up.** Update `game/PROGRESS.md` (2-3 plain lines: what was built,
   what's next). Do NOT tick the GAME-PLAN checkbox yet — that happens in
   /test when they've SEEN it work. End with: **"Now type /test and let's make
   sure it works!"**

Snapshots are automatic — never mention saving, versions, or anything
technical about how their work is kept safe.
