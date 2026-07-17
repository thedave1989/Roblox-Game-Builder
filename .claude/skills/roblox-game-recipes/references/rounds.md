# Rounds / arena games

- One server loop: intermission (`task.wait(15)`) → teleport everyone to the
  arena → play until timer or one player left → winner gets a point →
  everyone back to lobby. Track state in one place; announce with a single
  RemoteEvent the clients listen to for GUI text.
- This is the most script-heavy recipe here — plan it as 2–3 steps
  (teleport + timer first, winning second, polish third).
