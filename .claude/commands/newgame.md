# /newgame — plan a brand-new game

The player wants to start a game. Your job: get their idea out of their head
and into `game/GAME-PLAN.md`, then get them excited to build step 1.

## If a game already exists

`game/GAME-PLAN.md` already has a real game in it (not the placeholder)?
Ask first: "You already have **<game name>** going — do you want to REPLACE it
with a new game, or keep it? (Replacing doesn't delete your old game — I
keep copies of everything.)" Only continue if they choose to replace.

**On replace, archive before anything else** — otherwise the new game inherits
the old game's script files and the Builder trips over them:

    mkdir -p "game/archive/<old-game-name>-<date>"
    git mv game/scripts/*.luau "game/archive/<old-game-name>-<date>/" 2>/dev/null || true

Then reset GAME-PLAN.md to empty (the planner writes the new one from scratch
— a full replace is the one case where checked steps don't survive) and note
the archive location in PROGRESS.md.

## Step 1 — the interview (you do this, in this chat)

Use AskUserQuestion, at most 4 questions per round, concrete options they can
tap. Keep it to 2 rounds maximum. Find out:

- What KIND of game? (obby / tycoon / simulator / hangout / racing / their own words)
- What's it about — the theme, the world? (their words, any answer is right)
- What do you DO in it, moment to moment? (the fun loop)
- How do you win, or what do you work toward?

If they gave you a written spec already, don't re-ask what it answers — only
fill gaps. Reflect their idea back in one excited sentence and confirm you got
it right.

## Step 2 — hand it to the Game Planner

Spawn the `game-planner` agent (this is the ONE place Opus is used). Give it:
every interview answer verbatim, plus their written spec if they provided one.

**If the agent fails to start or errors** (Opus unavailable on their plan,
usage cap, anything): don't stall and don't retry more than once — write the
plan yourself in this chat, following game-planner.md's template and sizing
rules exactly. A good plan today beats a perfect plan never. Never surface
the model problem to the player; just make the plan.

## Step 3 — show them the plan

Read the finished `game/GAME-PLAN.md` and present it back SHORT: the game in
two sentences, then the Build List as a numbered "here's our road" list.
End with exactly one call to action: **"Ready? Type /build and we'll make
step 1 — <step 1 name>."**

Also update `game/PROGRESS.md`: game name, "planned on <date>", next = STEP-1.
