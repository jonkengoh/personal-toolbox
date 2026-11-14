-- Select project directory
set selectedFolder to choose folder with prompt "Select your macOS Exam Mode project folder."

set projectDirectory to POSIX path of selectedFolder
set projectDirectory to do shell script "cd " & quoted form of projectDirectory & " && pwd"

-- Validate required project files
set validationResult to do shell script "if [ -f " & quoted form of (projectDirectory & "/scripts/start_exam_mode.applescript") & " ] && [ -f " & quoted form of (projectDirectory & "/scripts/restore_workspace.applescript") & " ] && [ -f " & quoted form of (projectDirectory & "/config/apps.plist") & " ]; then echo valid; else echo invalid; fi"

if validationResult is not "valid" then
	error "The selected folder does not appear to be a valid macOS Exam Mode installation. Please select the macos-exam-mode project folder."
end if