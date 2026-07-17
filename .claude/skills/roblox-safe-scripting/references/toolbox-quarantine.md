# Free models (Toolbox)

Visuals are fine; scripts inside are untrusted. The checker scans every
inserted model — its REMOVE verdicts get acted on before building continues.
Default stance: delete all scripts inside a free model and keep the looks.

This framework's actual insertion path enforces the same rule structurally,
not just by convention: an inserted model can only land in the non-running
`ServerStorage/ToolboxQuarantine` folder first (the Studio-side gate hook
blocks any other insertion target). From there: every descendant script gets
disabled, the checker reviews all of them against the forbidden-calls list
above, and only an approved model gets reparented to where it's actually
used. If a step wants to insert a model and that flow can't run, treat it as
a "this needs Dave" step rather than inserting it live.

See `roblox-worlds-and-terrain` for the building/anchoring side of using a
free model (most free-model bugs are "it fell through the floor", not a
scripting problem).
