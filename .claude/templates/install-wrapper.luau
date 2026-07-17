-- GB-INSTALL v1  —  the ONE canonical install wrapper for Roblox Game Builder.
--
-- WHY THIS FILE EXISTS
--   A checker-approved script lives on disk as game/scripts/<name>.<suffix>.luau.
--   To get it INTO Studio through the MCP's run_code tool, the framework must
--   wrap it in a little Luau that finds/creates the Instance and sets its
--   Source. That wrapper means the run_code payload can never be byte-identical
--   to the reviewed file — so a naive "does the payload equal the approved
--   file?" check would reject every legitimate install.
--
--   The fix: EVERY install is emitted from THIS template and nothing else. The
--   Studio gate (.claude/hooks/studio-gate.py) matches the whole run_code
--   payload against this exact shape, extracts <SOURCE>, and compares only that
--   against the approved file's hash. Anything that isn't this template —
--   extra statements, a hand-written install, a tweaked wrapper — is blocked.
--
-- THE TEMPLATE (the emitter fills the <...> holes; the gate verifies them):
--   <SERVICE>    one of: ServerScriptService, ReplicatedStorage, StarterPlayer,
--                StarterGui, ServerStorage, Workspace
--   <CHILD_PATH> zero or more :WaitForChild("segment") steps; segment chars
--                are letters, digits, space, underscore, hyphen
--   <NAME>       the Instance name; letters, digits, underscore, hyphen
--   <CLASS>      one of: Script, LocalScript, ModuleScript
--   <EQ>         the Luau long-bracket level: the SHORTEST run of '=' that does
--                NOT appear as ]===]-style closer inside <SOURCE> (so the source
--                can contain ]] without breaking out of the string)
--   <SOURCE>     the exact bytes of the approved game/scripts/<name> file
--
-- Install is idempotent: an existing child of the same name is destroyed first,
-- so re-running a build replaces rather than duplicates.
--
-- IF YOU EDIT THIS FILE you MUST update studio-gate.py's matcher to match, or
-- the self-test (tests/run-tests.sh, "template drift" row) will fail on purpose.

-- GB-INSTALL v1
local parent = game:GetService("<SERVICE>")<CHILD_PATH>
local old = parent:FindFirstChild("<NAME>")
if old then old:Destroy() end
local s = Instance.new("<CLASS>")
s.Name = "<NAME>"
s.Source = [<EQ>[<SOURCE>]<EQ>]
s.Parent = parent
