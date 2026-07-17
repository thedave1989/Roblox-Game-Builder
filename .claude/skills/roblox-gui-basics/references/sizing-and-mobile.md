# Sizing that works on phones (most Roblox kids play on phones)

- `UDim2` is `(xScale, xOffset, yScale, yOffset)`. Use **Scale** for panel
  size/position (`UDim2.fromScale(0.25, 0.1)`); Offset-only UI is invisible-
  tiny or screen-eating on other devices.
- `AnchorPoint` pins the element by its centre/corner:
  centre-screen = `AnchorPoint (0.5, 0.5)` + `Position fromScale(0.5, 0.5)`.
  Top-right HUD = `AnchorPoint (1, 0)` + `Position fromScale(0.98, 0.02)`.
- `TextScaled = true` on every label/button; add `UITextSizeConstraint`
  (MaxTextSize ~40) so text can't get comically huge.
- Rows/grids of items (shop!) → `UIListLayout` / `UIGridLayout` inside a
  Frame — never hand-position ten buttons.
- Buttons: use `.Activated` (fires for tap AND click), not MouseButton1Click.

## Safe areas (don't hide behind the phone's own UI)

- Roblox's own top bar (menu, chat, leaderboard icons) and, on phones, the
  notch/status bar and on-screen home-indicator all live at the very edges
  of the screen. Never anchor an element flush to a screen edge or corner —
  leave a margin (roughly 5–8% of screen size, in Scale) on every side so
  nothing important sits under them.
- If a HUD element genuinely must hug the top (a persistent counter), test
  it feels clear of Roblox's own top bar rather than assuming a fixed pixel
  offset works everywhere — screens vary too much for one Offset number to
  be safe on all of them. `GuiService` exposes the current top-bar inset if
  a step needs to dodge it precisely; treat the exact property name as
  worth confirming in Studio's autocomplete rather than copying blind.

## Touch-sized controls

- Make every tappable thing big enough for a thumb, not a mouse pointer.
  Rule of thumb: no button should render smaller than roughly 8% of the
  screen's shorter side on a phone — when unsure, go bigger, not smaller.
- Space buttons apart with `UIPadding`/gaps in the `UIListLayout` so a
  slightly-off tap can't hit the wrong one — this matters far more on touch
  than it looks like it should on a PC screen.
- Avoid small icon-only buttons with no label; a chunky button with a short
  word reads faster and is easier to aim a thumb at.
