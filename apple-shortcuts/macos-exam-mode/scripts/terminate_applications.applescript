-- Resolve project directory
set projectDirectory to POSIX path of (path to me)
set projectDirectory to do shell script "dirname " & quoted form of projectDirectory

-- Locate configuration and snapshot
set configPath to projectDirectory & "/../config/apps.plist"
set snapshotPath to projectDirectory & "/../state/workspace_snapshot.plist"

-- Load configuration
tell application "System Events"
	set configFile to property list file configPath
	
	set preserveSystemApps to value of property list item "preserve_system_apps" of configFile
	set protectedBundleIDs to value of property list item "whitelist" of configFile
	set alwaysProtectBundleIDs to value of property list item "always_protect" of configFile
	set blacklistedBundleIDs to value of property list item "blacklist" of configFile
	set configMode to value of property list item "mode" of configFile
end tell

-- Load workspace snapshot
tell application "System Events"
	set snapshotFile to property list file snapshotPath
	set runningApplications to value of property list item "runningApplications" of snapshotFile
end tell

if runningApplications is missing value then
	error "Workspace snapshot is invalid or missing its application list."
end if

if (count of runningApplications) is 0 then
	error "Workspace snapshot contains no applications."
end if

set systemProtectedBundleIDs to {"com.apple.dock", "com.apple.systemuiserver", "com.apple.controlcenter", "com.apple.WindowServer"}
set applicationsToClose to {}
set closeReport to {}
set protectedApplications to {}
set skippedApplications to {}
set quitTimeoutSeconds to 10

repeat with appRecord in runningApplications
	set appName to |name| of contents of appRecord
	set appBundleID to bundleID of contents of appRecord
	
	-- Skip applications with unidentified bundle IDs
	if appBundleID is "Unknown" or appBundleID is "" then
		set end of skippedApplications to appName & " | Missing bundle identifier"
		
	else
		-- Classify application
		if appBundleID is in alwaysProtectBundleIDs then
			set appStatus to "PROTECTED"
		else if preserveSystemApps and appBundleID is in systemProtectedBundleIDs then
			set appStatus to "PROTECTED"
		else if appBundleID is in blacklistedBundleIDs then
			set appStatus to "CLOSE"
		else if appBundleID is in protectedBundleIDs then
			set appStatus to "PROTECTED"
		else if configMode is "strict" then
			set appStatus to "CLOSE"
		else
			set appStatus to "UNCLASSIFIED"
		end if
		
		-- Collect application by classification
		if appStatus is "CLOSE" then
			set end of applicationsToClose to {appName:appName, bundleID:appBundleID}
			set end of closeReport to appName & " | " & appBundleID
		else
			set end of protectedApplications to appName & " | " & appStatus
		end if
	end if
end repeat


if (count of applicationsToClose) is 0 then
	return "No applications need to be closed. Exam Mode is ready."
end if

set AppleScript's text item delimiters to linefeed
set closeReportText to closeReport as text

set reportText to "=== Preflight Report ===" & linefeed & linefeed

set reportText to reportText & "APPLICATIONS TO CLOSE (" & (count of applicationsToClose) & "):" & linefeed
set reportText to reportText & (closeReport as text) & linefeed & linefeed

set reportText to reportText & "PROTECTED APPLICATIONS (" & (count of protectedApplications) & "):" & linefeed
set reportText to reportText & (protectedApplications as text) & linefeed & linefeed

set reportText to reportText & "SKIPPED APPLICATIONS (" & (count of skippedApplications) & "):" & linefeed
set reportText to reportText & (skippedApplications as text)

set dialogMessage to "Exam Mode is ready to close " & (count of applicationsToClose) & " application(s)." & return & return & closeReportText & return & return & "Save all unsaved work before continuing. Applications may present their own save prompts. Do not proceed if you have unsaved work you cannot safely recover."

try
	set dialogResult to display dialog dialogMessage buttons {"Cancel", "Continue"} default button "Cancel" cancel button "Cancel" with icon caution
on error number -128
	return "CANCELLED: Exam Mode cancelled. No applications were asked to quit."
end try

if button returned of dialogResult is not "Continue" then
	return "CANCELLED: Exam Mode cancelled. No applications were asked to quit."
end if

set liveCheckReport to {}
set terminationReport to {}
set terminationFailures to {}

repeat with appRecord in applicationsToClose
	set appName to appName of appRecord
	set appBundleID to bundleID of appRecord
	
	set lookupSucceeded to true
	
	try
		tell application "System Events"
			set matchingProcesses to (every application process whose bundle identifier is appBundleID)
		end tell
		
		set appIsRunning to (count of matchingProcesses) > 0
		
	on error errMessage number errNumber
		set lookupSucceeded to false
		set end of liveCheckReport to appName & " | Lookup failed: " & errMessage & " (" & errNumber & ")"
		set end of terminationReport to appName & " | Skipped - running state unknown"
		set end of terminationFailures to appName & " | Lookup failed"
	end try
	
	if lookupSucceeded then
		if appIsRunning then
			set end of liveCheckReport to appName & " | Still running"
			
			set quitRequestSucceeded to true
			
			try
				tell application id appBundleID to quit
			on error errMessage number errNumber
				set quitRequestSucceeded to false
				set end of terminationReport to appName & " | Quit request failed: " & errMessage & " (" & errNumber & ")"
				set end of terminationFailures to appName & " | Quit request failed"
			end try
			
			if quitRequestSucceeded then
				set verificationSucceeded to true
				set appStillRunning to true
				set elapsedSeconds to 0
				
				repeat while appStillRunning and elapsedSeconds < quitTimeoutSeconds
					delay 1
					set elapsedSeconds to elapsedSeconds + 1
					
					try
						tell application "System Events"
							set remainingProcesses to (every application process whose bundle identifier is appBundleID)
						end tell
						
						set appStillRunning to (count of remainingProcesses) > 0
						
					on error errMessage number errNumber
						set verificationSucceeded to false
						set end of terminationReport to appName & " | Verification failed: " & errMessage & " (" & errNumber & ")"
						set end of terminationFailures to appName & " | Verification failed"
						set appStillRunning to false
					end try
				end repeat
				
				if verificationSucceeded then
					if appStillRunning is false then
						set end of terminationReport to appName & " | Successfully closed"
					else
						set end of terminationReport to appName & " | Still running after timeout (" & quitTimeoutSeconds & " seconds)"
						set end of terminationFailures to appName & " | Still running after timeout"
					end if
				end if
			end if
			
		else
			set end of liveCheckReport to appName & " | Already closed"
			set end of terminationReport to appName & " | Skipped - already closed"
		end if
	end if
end repeat

set AppleScript's text item delimiters to linefeed
set liveCheckText to liveCheckReport as text
set terminationText to terminationReport as text

set fullReport to reportText & return & return & "=== Live Application Check ===" & return & liveCheckText & return & return & "=== Termination Report ===" & return & terminationText

if (count of terminationFailures) > 0 then
    error "Termination was incomplete. The workspace snapshot has been preserved." & return & return & fullReport
end if

return fullReport