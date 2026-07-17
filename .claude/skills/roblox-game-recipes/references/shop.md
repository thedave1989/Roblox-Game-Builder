# Shop

- ProximityPrompt on a shop part → opens a simple GUI (client) → Buy click
  fires RemoteEvent with the item name (a string) → server looks the item up
  in ITS OWN price table, checks money, subtracts, grants. Client never sends
  a price. Unknown item name → ignore.
