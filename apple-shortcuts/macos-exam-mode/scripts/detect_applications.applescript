
-- Protected applications
property protectedBundleIDs : {"com.google.Chrome", "com.apple.finder"}

-- Collect running GUI applications
tell application "System Events"
	set runningApps to every application process whose background only is false
	
	set appReport to {}
	
	repeat with appProcess in runningApps
		set appName to name of appProcess
		
		try
			set appBundleID to bundle identifier of appProcess
		on error
			set appBundleID to "Unknown"
		end try
		
		-- Classify application
		if appBundleID is in protectedBundleIDs then
			set appStatus to "PROTECTED"
		else
			set appStatus to "UNCLASSIFIED"
		end if
		
		set end of appReport to Â
			appName & " | " & appBundleID & " | " & appStatus
	end repeat
	
	set totalApps to count of appReport
	set summary to "Total applications detected: " & totalApps
	set beginning of appReport to summary
	
end tell

-- Format output
set AppleScript's text item delimiters to linefeed
return appReport as text
