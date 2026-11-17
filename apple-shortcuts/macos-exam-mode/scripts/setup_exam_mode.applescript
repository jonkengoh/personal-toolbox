on run {input, parameters} -- Select or receive project directory
	set selectedFolder to choose folder with prompt "Select your macOS Exam Mode project folder."
	
	set projectDirectory to POSIX path of selectedFolder
	set directoryExists to do shell script "if [ -d " & quoted form of projectDirectory & " ]; then echo yes; else echo no; fi"
	
	if directoryExists is not "yes" then
		error "The selected project directory does not exist."
	end if
	set projectDirectory to do shell script "cd " & quoted form of projectDirectory & " && pwd"
	
	-- Validate required project files
	set validationResult to do shell script "if [ -f " & quoted form of (projectDirectory & "/scripts/start_exam_mode.applescript") & " ] && [ -f " & quoted form of (projectDirectory & "/scripts/restore_workspace.applescript") & " ] && [ -f " & quoted form of (projectDirectory & "/config/apps.plist") & " ]; then echo valid; else echo invalid; fi"
	
	if validationResult is not "valid" then
		error "The selected folder does not appear to be a valid macOS Exam Mode installation. Please select the macos-exam-mode project folder."
	end if
	
	-- Define local configuration paths
	set configDirectory to POSIX path of (path to application support from user domain) & "MacOS Exam Mode"
	set configPath to configDirectory & "/config.plist"
	
	-- Create configuration directory
	do shell script "mkdir -p " & quoted form of configDirectory
	
	-- Save project directory
	do shell script "/usr/bin/defaults write " & quoted form of configPath & " projectDirectory -string " & quoted form of projectDirectory
	
	-- Verify saved configuration
	set savedProjectDirectory to do shell script "/usr/bin/defaults read " & quoted form of configPath & " projectDirectory"
	
	if savedProjectDirectory is not projectDirectory then
		error "Installation configuration could not be verified."
	end if
	
	-- Confirm successful setup
	display dialog "macOS Exam Mode has been configured successfully." & return & return & "Project location:" & return & projectDirectory buttons {"OK"} default button "OK" with icon note
	return input
end run