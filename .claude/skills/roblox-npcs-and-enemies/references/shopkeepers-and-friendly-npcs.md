# Shopkeepers and friendly NPCs

- A static rig + a **ProximityPrompt** ("Talk"/"Shop") is a complete
  shopkeeper — prompt opens the shop GUI (roblox-gui-basics), purchase flows
  through the validated RemoteEvent (roblox-safe-scripting). No wandering AI
  needed; personality comes from the look (stylist) and the words.
- Name tag over the head: BillboardGui on the head part, one TextLabel.
