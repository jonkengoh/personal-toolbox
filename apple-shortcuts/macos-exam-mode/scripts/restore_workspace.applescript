-- Resolve project directory
set projectDirectory to POSIX path of (path to me)
set projectDirectory to do shell script "dirname " & quoted form of projectDirectory

-- Locate scripts and workspace snapshot
set scriptsDirectory to projectDirectory
set stateDirectory to projectDirectory & "/../state"
set snapshotPath to stateDirectory & "/workspace_snapshot.plist"

set applicationRestorePath to scriptsDirectory & "/restore_applications.applescript"
set focusRestorePath to scriptsDirectory & "/restore_focus.applescript"

-- Verify that a snapshot exists
if (do shell script "test -f " & quoted form of snapshotPath & " && echo exists || echo missing") is "missing" then
    error "No workspace snapshot was found. Nothing to restore."
end if

-- Restore captured applications
try
    set applicationRestoreResult to run script (POSIX file applicationRestorePath)
on error errMessage number errNumber
    error "Application restoration failed. The workspace snapshot has been preserved." & linefeed & errMessage & " (" & errNumber & ")"
end try

-- Restore original Focus
try
    set focusRestoreResult to run script (POSIX file focusRestorePath)
on error errMessage number errNumber
    error "Focus restoration failed. The workspace snapshot has been preserved." & linefeed & errMessage & " (" & errNumber & ")"
end try

-- Remove the workspace snapshot after successful restoration
try
    do shell script "rm " & quoted form of snapshotPath
on error errMessage number errNumber
    error "Workspace restoration succeeded, but the snapshot could not be removed. Please check the state directory manually." & linefeed & errMessage & " (" & errNumber & ")"
end try

return "Workspace restoration successful." & linefeed & "Applications:" & linefeed & applicationRestoreResult & linefeed & "Original Focus: " & focusRestoreResult & linefeed & "Workspace snapshot: removed."