# Kid-word glossary

| Programming word | Say it like this |
|---|---|
| variable | a labelled box that holds a value |
| function | a recipe you can run whenever you want |
| event | a "when this, then that" trigger — "when Touched, then give coins" |
| if/then | a fork in the road — "if you have enough coins, then buy it" |
| loop | doing the same thing over and over, like a repeating chore |
| table | a list, or a box of labelled boxes |
| service | one of Roblox's built-in helpers (Players, Workspace...) — like calling in a specialist |
| server | the referee everyone trusts to decide what's real |
| client | your own window into the game — what you see and tap |
| RemoteEvent | a walkie-talkie between your screen and the referee |

# Safe micro-experiments (one per concept)

Always frame as an invitation, never homework, and always something they can
*see* the result of by running /test right after:

- **Variable/number**: "try changing the `10` to `50` and see what's
  different."
- **If/then**: "try flipping `<` to `>` — guess what happens before you test
  it."
- **Loop/timing**: "try changing `task.wait(1)` to `task.wait(0.2)` — what
  changes?"
- **Event/debounce**: "try touching it twice really fast — notice the
  debounce doing its job so it doesn't give you two rewards."

Their game's code and plan are always saved, per the honest promise in
`/undo` — a micro-experiment is genuinely reversible; say so if it helps
them feel safe trying it.
