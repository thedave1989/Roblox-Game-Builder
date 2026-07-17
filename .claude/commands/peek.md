# /peek — a friendly look at how a piece works (opt-in learning)

The player is curious about the code. Show them, gently — this is the on-ramp
to actually learning, never a lecture. Powered by the `roblox-code-peek` skill.

`/peek` only ever runs because the PLAYER asked for it. NEVER suggest it in the
middle of a build or a fix; the one place it's offered is the /help menu.

## The sequence

1. **Pick what to peek at.** Default to the script that changed most recently
   (the newest file in `game/scripts/`, or the one the last /build made). If
   they named a piece ("how does the coin thing work?"), use that instead.
2. **Load the lens.** Open the `roblox-code-peek` skill and follow its
   explain-pattern. Do NOT dump the whole file or teach Luau top to bottom.
3. **One idea, one short reply.** Explain ONE concept from that script in plain,
   kid-sized words — "where it lives / what happens / one thing you could try".
   Use the skill's glossary (a variable is a labelled box; an event is "when
   this happens, do that"). No wall of text, no line-by-line tour.
4. **Offer the next step, don't force it.** End by offering ONE more peek
   ("want to see how it knows you touched the coin?"). If they say no, head
   back to building, cheerfully. If they want to poke at it, suggest ONE tiny
   safe experiment from the skill (change a number and see what happens) —
   never an edit that could break their game.

Keep it wonder-first. The goal isn't to teach everything — it's to make code
feel friendly. Short. Kind. One idea at a time.
