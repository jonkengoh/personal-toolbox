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

set AppleScript's text item delimiters to linefeed

set reportText to "=== Preflight Report ===" & linefeed & linefeed

set reportText to reportText & "APPLICATIONS TO CLOSE (" & (count of applicationsToClose) & "):" & linefeed
set reportText to reportText & (closeReport as text) & linefeed & linefeed

set reportText to reportText & "PROTECTED APPLICATIONS (" & (count of protectedApplications) & "):" & linefeed
set reportText to reportText & (protectedApplications as text) & linefeed & linefeed

set reportText to reportText & "SKIPPED APPLICATIONS (" & (count of skippedApplications) & "):" & linefeed
set reportText to reportText & (skippedApplications as text)

return reportText