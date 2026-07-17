# Materials and colours

`game/STYLE.md` is the law for looks (per `roblox-luau-basics` /
`roblox-gui-basics` conventions) — never invent a colour or material that
isn't in its tables.

- Parts: `.Material` (an `Enum.Material` — Grass, Sand, Rock, Concrete,
  Wood, Plastic, Neon, and many more) plus `.Color` (a `Color3`).
- Terrain uses the same material enum but its colour is set per-material on
  the Terrain object itself (painting Grass terrain a different green than
  the default, for example), not per-part `.Color` — confirm the exact
  current method name in Studio's autocomplete before relying on one, since
  Terrain's material-colour API is one of the more Studio-version-sensitive
  corners of this skill.
- Keep the palette small (STYLE.md already caps this at 3–5 colours) —
  terrain and parts obeying the same few colours is what makes a world feel
  designed instead of random.
