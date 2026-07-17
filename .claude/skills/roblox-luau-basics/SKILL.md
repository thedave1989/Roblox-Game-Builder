---
name: roblox-luau-basics
description: Core Luau + Roblox Studio patterns — script types and where they live, services, events, leaderstats, and load-safety. Read before writing ANY script. For agents, never shown to the player.
---

# Roblox Luau Basics

The ground rules for every script this framework writes. When code you're
about to write disagrees with this file, this file wins.

## Script types and where they go

| Suffix (our files)  | Studio object | Runs on | Standard home |
| ------------------- | ------------- | ------- | ------------- |
| `.server.luau`      | Script        | server  | ServerScriptService |
| `.client.luau`      | LocalScript   | player's device | StarterPlayer > StarterPlayerScripts (or StarterGui for UI code) |
| `.module.luau`      | ModuleScript  | whoever requires it | ReplicatedStorage (shared) or ServerScriptService (server-only) |

- Game logic, money, saving → server Scripts. Camera, input, GUI → LocalScripts.
- RemoteEvents/RemoteFunctions and shared ModuleScripts live in **ReplicatedStorage**.
- Anything the client must never see (secret values, server modules) → **ServerStorage** / ServerScriptService.

## Services

Always `local Players = game:GetService("Players")` — never `game.Players`
dot-access. Common ones: Players, Workspace, ReplicatedStorage, ServerStorage,
TweenService, DataStoreService, RunService, UserInputService (client),
CollectionService.

## Reference cards — load the one the step needs

| Load when the step... | Card |
|---|---|
| Reads or creates anything at startup (`WaitForChild`, the `task` library, Instance.new ordering) | [references/load-safety.md](references/load-safety.md) |
| Wires PlayerAdded/CharacterAdded, a Touched handler, or a clickable | [references/events.md](references/events.md) |
| Needs a score/counter the player sees | [references/leaderstats.md](references/leaderstats.md) |
| Tweens something, or you want the naming/anchoring/attribute habits | [references/polish-and-habits.md](references/polish-and-habits.md) |
