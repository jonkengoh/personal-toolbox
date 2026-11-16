-- Locate local installation configuration
set configDirectory to POSIX path of (path to application support from user domain) & "MacOS Exam Mode"
set configPath to configDirectory & "/config.plist"

-- Load project directory
try
	set projectDirectory to do shell script "/usr/bin/defaults read " & quoted form of configPath & " projectDirectory"
on error
	error "macOS Exam Mode has not been configured. Please run setup_exam_mode.applescript first."
end try

-- Validate installation directory
set installationValid to do shell script "if [ -d " & quoted form of projectDirectory & " ] && [ -f " & quoted form of (projectDirectory & "/scripts/restore_workspace.applescript") & " ]; then echo yes; else echo no; fi"

if installationValid is not "yes" then
	error "The configured project directory is invalid or no longer accessible. Please run setup_exam_mode.applescript again."
end if

-- Locate scripts and state
set scriptsDirectory to projectDirectory & "/scripts"
set stateDirectory to projectDirectory & "/state"

set snapshotPath to stateDirectory & "/workspace_snapshot.plist"
set applicationRestorePath to scriptsDirectory & "/restore_applications.applescript"
set focusRestorePath to scriptsDirectory & "/restore_focus.applescript"

-- Validate required restoration scripts
set restorationScriptsValid to do shell script "if [ -f " & quoted form of applicationRestorePath & " ] && [ -f " & quoted form of focusRestorePath & " ]; then echo yes; else echo no; fi"

if restorationScriptsValid is not "yes" then
	error "One or more restoration scripts are missing. Please check your macOS Exam Mode installation."
end if

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