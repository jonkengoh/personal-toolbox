-- Resolve project directory
set projectDirectory to POSIX path of (path to me)
set projectDirectory to do shell script "dirname " & quoted form of projectDirectory

-- Locate state directory
set stateDirectory to projectDirectory & "/../state"

set snapshotPath to stateDirectory & "/workspace_snapshot.plist"

if (do shell script "test -e " & quoted form of snapshotPath & " && echo exists || echo missing") is "exists" then
	error "An existing workspace snapshot was found. Restore or clear the previous session before starting another."
end if

set workspaceSnapshot to {}

set capturedAt to do shell script "date -u +%Y-%m-%dT%H:%M:%SZ"
set originalFocus to do shell script "shortcuts run " & quoted form of "Exam Mode - Capture Focus"

tell application "System Events"
	set runningApps to every application process whose background only is false
	
	repeat with appProcess in runningApps
		set appName to name of appProcess
		
		try
			set appBundleID to bundle identifier of appProcess
		on error
			set appBundleID to "Unknown"
		end try
		
		set appRecord to {name:appName, bundleID:appBundleID}
		set end of workspaceSnapshot to appRecord
	end repeat
end tell

tell application "System Events"
	set parentDictionary to make new property list item with properties {kind:record}
	set snapshotFile to make new property list file with properties {contents:parentDictionary, name:snapshotPath}
	make new property list item at end of property list items of snapshotFile with properties {name:"capturedAt", value:capturedAt}
	make new property list item at end of property list items of snapshotFile with properties {name:"originalFocus", value:originalFocus}
	set applicationsArray to make new property list item at end of property list items of snapshotFile with properties {name:"runningApplications", kind:list}
	
	repeat with appRecord in workspaceSnapshot
		set appDictionary to make new property list item at end of property list items of applicationsArray with properties {kind:record}
		
		make new property list item at end of property list items of appDictionary with properties {name:"name", value:(name of appRecord)}
		make new property list item at end of property list items of appDictionary with properties {name:"bundleID", value:(bundleID of appRecord)}
	end repeat
end tell

set snapshotReport to {}

repeat with appRecord in workspaceSnapshot
	set end of snapshotReport to (name of appRecord) & " | " & (bundleID of appRecord)
end repeat

set AppleScript's text item delimiters to linefeed
return snapshotReport as text