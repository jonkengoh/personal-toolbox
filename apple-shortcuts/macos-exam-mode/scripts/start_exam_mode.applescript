-- Resolve project directory
set projectDirectory to POSIX path of (path to me)
set projectDirectory to do shell script "dirname " & quoted form of projectDirectory

-- Locate scripts and state
set stateDirectory to projectDirectory & "/../state"
set snapshotPath to stateDirectory & "/workspace_snapshot.plist"

set captureScriptPath to projectDirectory & "/capture_workspace.applescript"
set terminationScriptPath to projectDirectory & "/terminate_applications.applescript"

-- Check for an existing workspace snapshot
set snapshotExists to (do shell script "if [ -e " & quoted form of snapshotPath & " ]; then echo yes; else echo no; fi")

if snapshotExists is "yes" then
	error "An existing workspace snapshot was found. Restore or clear the previous session before starting Exam Mode."
end if

-- Capture current workspace
try
	set captureResult to run script (POSIX file captureScriptPath)
on error errMessage number errNumber
	error "Workspace capture failed. Exam Mode was not started." & linefeed & errMessage & " (" & errNumber & ")"
end try


-- Terminate eligible applications
try
	set terminationResult to run script (POSIX file terminationScriptPath)
on error errMessage number errNumber
	error "Application termination failed. The workspace snapshot has been preserved." & linefeed & errMessage & " (" & errNumber & ")"
end try


-- Handle cancellation
if terminationResult starts with "CANCELLED:" then
	try
		do shell script "rm " & quoted form of snapshotPath
	on error errMessage number errNumber
		error "Exam Mode was cancelled, but the workspace snapshot could not be removed. Please check the state directory manually." & linefeed & errMessage & " (" & errNumber & ")"
	end try
	
	return terminationResult & linefeed & "Workspace snapshot: removed."
end if


-- Enable Do Not Disturb
try
	set focusResult to do shell script "shortcuts run " & quoted form of "Enable DnD"
on error errMessage number errNumber
	error "Applications were processed, but Do Not Disturb could not be enabled. The workspace snapshot has been preserved." & linefeed & errMessage & " (" & errNumber & ")"
end try


-- Build final report
return "Exam Mode enabled successfully." & return & return & "=== Workspace Capture ===" & return & captureResult & return & return & "=== Application Termination ===" & return & terminationResult & return & return & "=== Focus Management ===" & return & focusResult & return & return & "Workspace snapshot: preserved for restoration."