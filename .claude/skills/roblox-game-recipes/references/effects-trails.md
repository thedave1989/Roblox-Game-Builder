# Effects: Trails (dash streaks, projectile trails, pet flourishes)

```lua
local trail = Instance.new("Trail")
trail.Attachment0 = attachment0   -- two Attachments on the same part/model
trail.Attachment1 = attachment1
trail.Color = ColorSequence.new(Color3.new(1, 1, 1))
trail.Lifetime = 0.5
trail.Parent = part
```

A Trail needs two `Attachment` instances (placed a little apart on the thing
that's moving) to know which direction to draw the ribbon between —
`Attachment0`/`Attachment1`. `Lifetime`, `Color`, `Transparency` (a
NumberSequence) shape how it fades.

## Client-cosmetic vs server-authoritative

Trails are cosmetic — nothing about collision or scoring depends on the
ribbon itself. If other players should see it too (a thrown projectile's
trail, a visible speed power-up), create it server-side (or as part of the
object's normal server-authored install) so it replicates and looks the
same to everyone. A trail meant only for the owning player's own view can be
attached client-side instead — cheaper, and no one else needs to see it.
