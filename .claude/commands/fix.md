# /fix — something's broken

The player says something isn't working. Stay calm and friendly — they may be
frustrated or worried they broke it. First line every time, some version of:
"No problem — we'll sort it out together."

## The sequence

1. **Get their story.** Ask what happened in THEIR words: what did they do,
   what did they expect, what did they see? If there's a red error message in
   Studio (bottom "Output" window), ask them to copy-paste it or screenshot it
   — tell them exactly where that window is. One round of questions, keep it
   light.
2. **Look for yourself.** Read the relevant scripts in `game/scripts/` and the
   step in GAME-PLAN.md. If Studio is connected via MCP, inspect the live
   objects too. Diagnose before touching anything.
3. **Small fix you're sure of** (typo, wrong name, missing part): fix it —
   `builder` agent for script changes, `checker` on anything changed, then
   re-install the fixed script the same way /build installs. Tell them what
   was wrong in one plain sentence ("the door was asking for a key that
   didn't exist yet").
4. **Big or unclear problem:** do NOT experiment on their game. Offer the two
   honest options in plain words:
   - "/undo can take the game back to before this broke", or
   - "ask Dave to look at this — tell him: <one-line technical hint, e.g.
     'STEP-4 RemoteEvent handler errors on line 12'>".
5. **Close the loop.** After any fix, run the /test flow for the affected step
   so they SEE it working again. Update PROGRESS.md ("fixed the shop button").

Never blame them. Never dump a stack trace at them. Never leave them without
a next move.
