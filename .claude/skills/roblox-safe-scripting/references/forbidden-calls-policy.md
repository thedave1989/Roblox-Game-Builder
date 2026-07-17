# Forbidden — never write, never let through

This is **this framework's own safety policy**, not a blanket Roblox platform
restriction — a generic Roblox script is technically permitted to use several
of these APIs. We forbid them here because a 10-year-old and their checker
can't safely audit what code fetched from elsewhere, or code that hides its
own logic, would actually do. Mirrors the checker's blocklist; the builder
must never produce these:

- `require(<asset id number>)` — runs marketplace code sight-unseen. The #1
  backdoor vector in free models.
- `loadstring(...)` — executes strings as code.
- `getfenv` / `setfenv` — environment tampering, and deoptimizes Luau.
- `HttpService` requests — this framework's games don't call the internet.
- Obfuscated code (long unreadable strings, byte arrays that decode to code):
  treat as hostile, delete.

If a real feature ever needs one of these (an HTTP call to a leaderboard
service, say), that's a "stop and ask Dave" moment — a deliberate,
Dave-approved exception — never something the builder quietly works around.
