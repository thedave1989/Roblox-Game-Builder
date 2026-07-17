# Server cost caps (non-negotiable)

- **Hard cap the count.** A spawner keeps at most N alive (count the tag;
  6–10 enemies is plenty for a first game). Spawner loop: if under cap and
  `task.wait(5)` passed, clone one.
- Decision loops run at `task.wait(0.25)`-ish, never Heartbeat.
- Idle NPCs (no player within aggro range) should do nothing — skip the
  whole body, don't pathfind to no one.
- `SetNetworkOwner(nil)` on the HumanoidRootPart after spawning — keeps the
  server in charge of physics so enemies don't stutter or get exploited.
- Despawn or freeze everything when no players are near the area.
