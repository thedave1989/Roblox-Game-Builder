# Red errors in the Output window

| Error text (pattern) | Usual cause | Fix |
| --- | --- | --- |
| `attempt to index nil with '<Name>'` | Dot-access on something not loaded yet, or a typo'd/renamed object | `WaitForChild`; check exact spelling AND capitals against Explorer |
| `Infinite yield possible on ...WaitForChild("X")` | "X" doesn't exist where the script looks — wrong name, wrong parent, or never created | Find where X really is (or create it); names must match exactly |
| `X is not a valid member of Y` | Same family: wrong name/path, or the script ran before X existed | Fix the name or WaitForChild |
| `attempt to perform arithmetic on nil` | A Value object read before set, or `FindFirstChild` miss used as a number | Nil-check first; make the server create the value before anyone reads it |
| `attempt to compare nil` / `attempt to call a nil value` | Calling/comparing something misspelled or not required properly | Check spelling; check the module actually returns the function |
| `<name> is not a valid Service` | Typo in `GetService` | Exact service name, e.g. "TweenService" not "TweenServce" |
| `expected ')' (to close '(' ...)` / `'end' expected` | Broken bracket/end pairing after a hand edit | Re-emit the whole file from the canonical copy in `game/scripts/` — don't patch brackets by hand |
| `DataStore request was throttled/rejected` | Saving too often, or Studio API access off | Save on leave + interval only; tick Game Settings → Security → Studio API access |
| `HTTP 403/blocked` on a DataStore call in Studio | Studio API access not enabled for this place | Same toggle as above; must be a SAVED/published place |
