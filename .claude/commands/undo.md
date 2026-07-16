# /undo — go back to how it was

The player wants to rewind. The framework snapshots their work constantly, so
there is always somewhere to go back to. NEVER use the words git, commit,
branch, or anything technical — snapshots are described only by WHEN they
happened and what was going on.

## The sequence

1. **List the choices.** Run (quietly, don't show the command or raw output):

       git log --format="%h|%ad|%s" --date=format:"%A %H:%M" -15

   Turn the useful ones into AT MOST 5 plain choices via AskUserQuestion,
   newest first, in human words built from the snapshot labels and times:
   - "Just before the last build (today 14:32)"
   - "After we finished the coin collector (today 11:05)"
   - "End of yesterday's session"
   Skip near-duplicate snapshots minutes apart — offer meaningfully different
   moments.
2. **Show what going back means.** For the chosen snapshot, check what changed
   since (`git diff --name-only <hash> -- game/`) and say it simply: "Going
   back to <choice> removes: <the shop button script, yesterday's changes to
   the leaderboard>. Your plan file goes back too. Are you sure?" Get a clear
   yes.
3. **Restore — game files only, and make it a TRUE restore.** A plain
   checkout leaves behind files created after the snapshot, so the game and
   the plan would disagree. Run, in order:

       bash .claude/hooks/auto-save.sh "just before the undo"
       git rm -r -q --ignore-unmatch -- game/
       git checkout <hash> -- game/

   That first snapshot means even this undo can be undone — if they regret
   it, /undo again and pick "just before the undo". Never restore `.claude/`
   or the docs — only their game.
4. **Re-install reality — both directions.** The files now match the chosen
   moment, but Roblox Studio still has whatever is currently in it:
   - Scripts that came BACK: offer "Want me to put the restored scripts back
     into Studio now?" — install them the way /build does.
   - Things that should now be GONE: compare what the rolled-back steps had
     created (the diff from step 2 tells you) and remove those objects from
     Studio too — via MCP, or tell them exactly what to click-and-delete in
     the Explorer. Skipping this leaves ghost pieces in their game.
5. Tell them where they are now in one friendly line, and what /build would
   do next. Update PROGRESS.md ("went back to <choice>").
