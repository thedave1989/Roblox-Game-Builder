# Terrain editor — sculpting the ground by hand

Studio's built-in Terrain Editor (a toolbar/tab, generally reached from the
Home ribbon) is a **mouse/brush tool** — it is not something the Studio MCP
tools can drive. This is genuinely hand-sculpting territory: the child does
the dragging, this framework explains in plain words which button to click
and what to expect. The MCP side of a "build the world" step is placing
scriptable pieces (a SpawnLocation, a trigger part, a kill-brick) into a
terrain the child (or a generated preset) already shaped.

Tools the child will see in some form (exact names/menu placement can move
between Studio versions — confirm against the live toolbar before quoting a
name as gospel):

- **Generate** — a one-click procedural landscape from presets (hills,
  mountains, canyons, islands...) — the fastest way to get "a world" at all.
- **Edit/Sculpt** — grow or erode terrain by dragging a brush.
- **Smooth** — softens sharp edges the other tools leave behind.
- **Flatten** — makes an area level, useful before placing a building.
- **Paint** — changes material without changing the shape (see
  materials-and-style.md).
- **Region/Position** tools — move or resize the whole terrain block.

## Water and lava

- **Water** is a real Terrain material with its own properties on
  `workspace.Terrain` (colour, transparency, wave size/speed, reflectance) —
  painting/sculpting Water terrain gives genuine swim physics.
- **Lava is not a magic built-in danger material.** There's no equivalent
  "instant death terrain" — a lava look is normally just Terrain or a Part
  coloured/lit like lava, made dangerous with an ordinary script (the
  kill-brick pattern in `roblox-game-recipes`). Don't let a child assume
  colouring something orange makes it hurt on its own.

_verified: 2026-07-17 — Terrain Editor tool names, menu location, and the
exact Terrain water-property names move between Studio versions; confirm at
create.roblox.com/docs/studio before quoting a specific button/menu path._
