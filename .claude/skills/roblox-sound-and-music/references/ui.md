# UI sounds (clicks, purchase chimes, error buzzes)

```lua
-- LocalScript inside the button's ScreenGui
local sound = script.Parent:WaitForChild("ClickSound")
button.Activated:Connect(function()
    sound:Play()
end)
```

- Feedback sounds (a button click, a "bought it!" chime, an "can't afford
  that" buzz) are per-player cosmetic — nothing about them needs server
  authority, so playing them straight from a LocalScript on the interaction
  is fine and simplest.
- **Conservative default volume**: start UI sounds around `Volume = 0.3–0.5`,
  never 1.0. A sudden loud sound through headphones is a bad first
  impression, and a kid rarely thinks to turn it down first.
- Keep one Sound instance per button, reused every press — don't
  `Instance.new("Sound")` fresh on every click.
