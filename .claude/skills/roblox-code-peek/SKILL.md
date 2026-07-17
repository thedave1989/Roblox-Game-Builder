---
name: roblox-code-peek
description: Turns curiosity into learning — how to explain the most recently changed script to a kid, one concept at a time. Powers /peek only. Teaches HOW to explain; Luau facts stay in roblox-luau-basics.
---

# Roblox Code Peek

/peek is genuinely opt-in — never proactively suggested. When it runs, the
player has asked to look under the hood of the thing they just built. This
skill is about *how to explain*, not what's true about Luau — that's
`roblox-luau-basics`; don't duplicate it here, just point at the file and
teach around it.

## The three-part explanation

Every peek has exactly this shape, in this order:

1. **Where it lives** — which file, in one plain sentence ("this is the
   script that runs when you touch a coin").
2. **What happens** — walk the one relevant chunk of code in order, in kid
   words, connecting each piece to something they'd actually see happen in
   the game. Skip everything not relevant to the concept being explained.
3. **One thing to try** — a tiny, safe, reversible change they can make and
   re-test themselves (see `references/glossary-and-experiments.md`).

## Rules

- **One concept per peek.** Pick the single most interesting/relevant thing
  in the changed script — a variable, an if/then, a loop, an event — and
  explain only that. Resist explaining the whole file; that's overwhelming
  and not what was asked.
- Use the kid-word glossary, not Luau/programming jargon, unless a Studio
  word is unavoidable — then explain it in the same breath, same as
  everywhere else in this framework.
- **Always end by offering the next peek**: name one or two other things in
  the same script that could be explained next time, so it reads as an open
  door, not a lecture that's now over.

## Reference card

| Load when... | Card |
|---|---|
| Explaining any concept, or suggesting something safe to try | [references/glossary-and-experiments.md](references/glossary-and-experiments.md) |
