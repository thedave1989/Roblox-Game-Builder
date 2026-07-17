---
name: roblox-safe-scripting
description: Security and data-safety rules — server authority, RemoteEvent validation, saving with native DataStores, and the forbidden-call list. Read for any step involving money, saving, remotes, or anything a player could cheat. For agents, never shown to the player.
---

# Roblox Safe Scripting

Exploiters run their own code on the client. Anything the client controls,
a cheater controls. These rules keep the game honest and the save data safe.

## Server authority (the one big rule)

Money, health, scores, inventory, purchases, win conditions: the **server**
owns them. A LocalScript may *ask* and *display* — never *decide*.

- Client changes its own leaderstats? Cosmetic — the server copy is unchanged.
  So the server must be the only writer, or the display lies.
- Never trust position/speed claims from the client for rewards ("I touched
  the finish") — verify server-side (server sees Touched too).

## Reference cards — load the one the step needs

| Load when the step... | Card |
|---|---|
| Adds or changes a RemoteEvent/RemoteFunction handler | [references/remotes-and-validation.md](references/remotes-and-validation.md) |
| Saves or loads player progress with DataStores | [references/saving-with-datastores.md](references/saving-with-datastores.md) |
| You need the exact forbidden-call list, or why it exists | [references/forbidden-calls-policy.md](references/forbidden-calls-policy.md) |
| A Toolbox/free model just got inserted | [references/toolbox-quarantine.md](references/toolbox-quarantine.md) |
