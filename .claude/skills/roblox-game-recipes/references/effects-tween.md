# Effects: Tween (smooth movement/colour/size)

```lua
local TweenService = game:GetService("TweenService")
local info = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tween = TweenService:Create(part, info, {
    Position = target.Position,
    Transparency = 0.5,
})
tween:Play()
```

`TweenInfo.new(time, easingStyle, easingDirection, repeatCount, reverses,
delayTime)` — any property that accepts a plain value (Position, Size,
Color, Transparency, CFrame...) can be tweened this way. 0.2–0.5s reads as
"snappy"; 1s+ reads as "grand".

## Client-cosmetic vs server-authoritative

Ask: **does what a player can walk on/through/collide with change while
this tweens?** If yes (a moving platform, a door that blocks a path) — the
**server** must create and play the tween, same as any world object with
gameplay consequences (roblox-safe-scripting's server-authority rule).
Client-side physics can't be trusted to agree with everyone else.

If no (a coin's idle spin, a torch's colour pulse, a button's press-scale on
a GUI) — it's pure decoration with no gameplay riding on it, so it can run
client-side, or just as easily server-side if it's simplest to write there.
Purely cosmetic tweens don't need to be perfectly synced between players.
