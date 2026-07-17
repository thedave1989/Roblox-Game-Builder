# Obby (obstacle course)

- **Checkpoints** — one SpawnLocation per stage. On Touched, set the player's
  `RespawnLocation` (or store their stage in an IntValue/attribute and
  teleport on respawn). Track `leaderstats.Stage`. Gotcha: debounce, and only
  move the stage *forward* (touching checkpoint 2 after 5 must not reset you).
- **Kill brick** — Touched → `Humanoid.Health = 0`. One script can serve every
  kill brick: tag them with CollectionService ("KillBrick") and loop the tag.
- **Moving/disappearing platforms** — TweenService between two positions, or a
  loop toggling `CanCollide`+`Transparency` with `task.wait()`. Anchor them.
- **Finish line** — Touched → celebrate (confetti = particles), award a win to
  leaderstats, teleport back to lobby.
