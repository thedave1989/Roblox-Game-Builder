# Free models and world performance

## The quarantine rule for free models

Toolbox/free models are treated as hostile data, same as anywhere else in
this framework — see `roblox-safe-scripting`'s toolbox-quarantine card for
the full flow (insertion only into `ServerStorage/ToolboxQuarantine`,
scripts disabled and checker-reviewed before anything moves). The
world-building-specific gotcha on top of that: an inserted model is
frequently **not anchored**, so once it's approved and placed, check it
doesn't fall through the floor the same way any hand-placed part would.

## Streaming and performance basics

- `Workspace.StreamingEnabled` lets parts far from a player stream out on
  their machine (mainly a client-side/rendering concern) — worth turning on
  for a large explorable world, but treat exact current behaviour as worth
  confirming rather than assumed, since streaming mechanics have evolved.
- Prefer simple Parts/MeshParts over big Unions where a simple shape does
  the job — Unions are noticeably more expensive to render and simulate.
- Avoid thousands of tiny individual parts where one larger textured part
  would look the same; part count adds up faster than it looks like it
  should for a first-time builder.
