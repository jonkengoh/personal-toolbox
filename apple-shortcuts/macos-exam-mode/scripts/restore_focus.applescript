-- Resolve project directory
set projectDirectory to POSIX path of (path to me)
set projectDirectory to do shell script "dirname " & quoted form of projectDirectory

-- Locate workspace snapshot
set stateDirectory to projectDirectory & "/../state"
set snapshotPath to stateDirectory & "/workspace_snapshot.plist"


-- Verify that a snapshot exists
if (do shell script "test -f " & quoted form of snapshotPath & " && echo exists || echo missing") is "missing" then
	error "No workspace snapshot was found. Nothing to restore."
end if

-- Read original Focus
try
	set originalFocus to do shell script "/usr/libexec/PlistBuddy -c " & quoted form of "Print :originalFocus" & " " & quoted form of snapshotPath
on error
	error "The workspace snapshot does not contain a valid originalFocus value. Focus restoration was aborted."
end try

-- Validate original Focus value
if originalFocus is "" then
	error "The originalFocus value is empty. Focus restoration was aborted."
end if

-- Restore original Focus
do shell script "printf %s " & quoted form of originalFocus & " | shortcuts run " & quoted form of "Restore Exam Mode Focus"

return originalFocus

