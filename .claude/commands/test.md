# /test — try out what was just built

Help the player SEE the latest step working in Roblox Studio, with their own
hands. Testing is clicking and playing, not reading code.

## The sequence

1. Find the most recently built, still-unchecked step (PROGRESS.md says what
   was last built; its box in GAME-PLAN.md is still `- [ ]`). Nothing pending?
   Say so and suggest /build.
2. Give them a short click-by-click test:
   - How to start: "Press the big blue ▶ Play button at the top of Studio."
   - What to do: 2-4 numbered actions in the game ("walk onto the yellow pad").
   - **What you should see:** the step's promised result, stated exactly.
   - How to stop: "Press the red ■ Stop button when you're done."
3. Ask them straight: "Did it work — did you see <the thing>?"
   - **Yes** → celebrate (one line, genuine). Tick the step's box in
     GAME-PLAN.md (`- [ ]` → `- [x]`). Update PROGRESS.md. Tell them what the
     NEXT step will be and that /build starts it. If that was the last step:
     big congratulations — the game is done, and /publish can put it on Roblox.
   - **No / something weird** → ask what they saw (their words are enough),
     then switch to the /fix flow with that description. Never make them feel
     it's their fault — "good catch, that's exactly why we test!"
