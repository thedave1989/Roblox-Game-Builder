# Load-safety (the #1 crash source)

- Things load in over time. Use `:WaitForChild("Name")` for anything a script
  needs at startup; use `:FindFirstChild("Name")` + a nil-check when the thing
  might legitimately not exist.
- New instances: set all properties first, set `.Parent` **last**.
- Use the `task` library: `task.wait(n)`, `task.spawn(fn)`, `task.defer(fn)`.
  Never a loop without a `task.wait()` inside.
