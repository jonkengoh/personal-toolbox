-- Resolve project directory
set projectDirectory to POSIX path of (path to me)
set projectDirectory to do shell script "dirname " & quoted form of projectDirectory

-- Locate workspace snapshot
set stateDirectory to projectDirectory & "/../state"
set snapshotPath to stateDirectory & "/workspace_snapshot.plist"

-- Verify that a snapshot exists
if (do shell script "test -f " & quoted form of snapshotPath & " && echo exists || echo missing") is "missing" then
	error "No workspace snapshot was found. Nothing to restore."
end if

-- Read captured applications
tell application "System Events"
	set snapshotFile to property list file snapshotPath
	set applicationsItem to property list item "runningApplications" of snapshotFile
	set applicationItems to every property list item of applicationsItem
end tell

-- Build application report
set applicationReport to {}
set restorationFailures to {}

repeat with applicationItem in applicationItems

    -- Extract application information
    tell application "System Events"
        set appName to value of property list item "name" of applicationItem
        set appBundleID to value of property list item "bundleID" of applicationItem

        -- Check whether the application is currently running
        set matchingProcesses to (every application process whose bundle identifier is appBundleID)
    end tell

    if (count of matchingProcesses) > 0 then
        set appStatus to "ALREADY RUNNING"

    else
        try
            -- Request application launch
            tell application id appBundleID
                launch
            end tell

            -- Wait for the application process to appear
            set appStarted to false
            set elapsedSeconds to 0
            set launchTimeoutSeconds to 10

            repeat while appStarted is false and elapsedSeconds < launchTimeoutSeconds
                delay 1
                set elapsedSeconds to elapsedSeconds + 1

                tell application "System Events"
                    set matchingProcesses to (every application process whose bundle identifier is appBundleID)
                end tell

                if (count of matchingProcesses) > 0 then
                    set appStarted to true
                end if
            end repeat

            if appStarted then
                set appStatus to "SUCCESSFULLY LAUNCHED"
            else
                set appStatus to "LAUNCH TIMEOUT (" & launchTimeoutSeconds & " seconds)"
            end if

        on error errMessage number errNumber
            set appStatus to "LAUNCH FAILED: " & errMessage & " (" & errNumber & ")"
        end try
    end if

    if appStatus starts with "LAUNCH FAILED" or appStatus starts with "LAUNCH TIMEOUT" then
        set end of restorationFailures to appName & " | " & appStatus
    end if

    set end of applicationReport to appName & " | " & appBundleID & " | " & appStatus

end repeat

-- Format report
set AppleScript's text item delimiters to linefeed
set reportText to applicationReport as text
set AppleScript's text item delimiters to ""

if (count of restorationFailures) > 0 then
    set AppleScript's text item delimiters to linefeed
    set failureText to restorationFailures as text
    set AppleScript's text item delimiters to ""

    error "Some applications could not be restored:" & linefeed & failureText
end if

return reportText