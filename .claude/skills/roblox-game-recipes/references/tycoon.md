# Tycoon

- **Dropper** — server loop: clone a small part above a conveyor every few
  seconds, `Debris:AddItem(part, 30)` so drops can't pile up forever.
- **Collector** — Touched at the conveyor end → add the drop's value to the
  owner's money, destroy the drop.
- **Buy button** — Touched by the owner → server checks money ≥ price →
  subtract, make the purchased thing visible/real. Price and money live
  server-side only.
- **Owner door** — Touched → walk through only if `player == plot.Owner`.
- Start with ONE plot single-player; multi-plot claiming is an "Ideas for
  later" upgrade, not step 1.
