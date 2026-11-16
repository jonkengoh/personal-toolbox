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
set installationValid to do shell script "if [ -f " & quoted form of (projectDirectory & "/scripts/start_exam_mode.applescript") & " ]; then echo yes; else echo no; fi"

if installationValid is not "yes" then
    error "The configured project directory is invalid or no longer accessible. Please run setup_exam_mode.applescript again."
end if

-- Locate scripts and state
set scriptsDirectory to projectDirectory & "/scripts"
set stateDirectory to projectDirectory & "/state"

set snapshotPath to stateDirectory & "/workspace_snapshot.plist"

set captureScriptPath to scriptsDirectory & "/capture_workspace.applescript"
set terminationScriptPath to scriptsDirectory & "/terminate_applications.applescript"

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