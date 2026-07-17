# Collectibles (coins, gems, eggs)

- Coin = anchored part, slow spin tween. Touched → +1 server-side, coin
  vanishes (`CanCollide=false, Transparency=1`), reappears after `task.wait(10)`.
  Debounce per-coin. Never destroy-and-clone when hide-and-show works.
- Spawning many: one template in ServerStorage, `:Clone()` to marked spots.
