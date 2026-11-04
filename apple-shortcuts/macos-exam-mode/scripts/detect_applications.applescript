
-- Resolve project directory
set projectDirectory to POSIX path of (path to me)
set projectDirectory to do shell script "dirname " & quoted form of projectDirectory

-- Locate configuration
set configPath to projectDirectory & "/../config/apps.plist"

-- Load configuration
tell application "System Events"
	set configFile to property list file configPath
	
	set protectedBundleIDs to value of property list item "whitelist" of configFile
	set alwaysProtectBundleIDs to value of property list item "always_protect" of configFile
	set blacklistedBundleIDs to value of property list item "blacklist" of configFile
	set configMode to value of property list item "mode" of configFile
end tell



-- Collect running GUI applications
tell application "System Events"
	set runningApps to every application process whose background only is false
	
	set protectedCount to 0
	set closeCount to 0
	
	set appReport to {}
	
	repeat with appProcess in runningApps
		set appName to name of appProcess
		
		try
			set appBundleID to bundle identifier of appProcess
		on error
			set appBundleID to "Unknown"
		end try
		
		-- Classify application
		if appBundleID is in alwaysProtectBundleIDs then
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
		
		if appStatus is "PROTECTED" then
			set protectedCount to protectedCount + 1
		else if appStatus is "CLOSE" then
			set closeCount to closeCount + 1
		end if
		
		set end of appReport to appName & " | " & appBundleID & " | " & appStatus
	end repeat
	
	set totalApps to count of appReport
	set summary to "=== Exam Mode Application Report ===" & linefeed & "Total applications detected: " & totalApps & linefeed & "Protected applications: " & protectedCount & linefeed & "Closure candidates: " & closeCount
	set beginning of appReport to summary
	
end tell

-- Format output
set AppleScript's text item delimiters to linefeed
return appReport as text
