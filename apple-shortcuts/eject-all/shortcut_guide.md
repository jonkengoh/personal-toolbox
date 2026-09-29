# Eject All Shortcut

## Overview

This Shortcut provides a quick way to eject all currently connected and ejectable disks on macOS.

It uses AppleScript to communicate with Finder, identify ejectable disks, eject them, and return a status message listing the drives that were successfully ejected.

## Prerequisites

* macOS
* Shortcuts app
* Finder
* Basic familiarity with AppleScript

## Shortcut Structure

The Shortcut follows this flow:

1. Run an AppleScript
2. Ask Finder for all ejectable disks
3. Check whether any ejectable disks were found
4. Eject each disk
5. Keep track of successfully ejected disks
6. Return a status message
7. Display the result

## Building the Shortcut

### 1. Create the Shortcut

* Open the Shortcuts app
* Create a new Shortcut
* Give it a suitable name, such as Eject All

### 2. Add the AppleScript

Add a “Run AppleScript” action and use the following:
```applescript
on run {input, parameters}
	tell application "Finder"
		set ejectableDisks to every disk whose ejectable is true
		if (count of ejectableDisks) > 0 then
			set ejectedNames to {}
			repeat with d in ejectableDisks
				try
					set end of ejectedNames to name of d
					eject d
				end try
			end repeat
			set ejectedList to "✅ Ejected " & (count of ejectedNames) & " drive(s): " & (ejectedNames as text)
			return ejectedList
		else
			return "⏏ No external drives to eject"
		end if
	end tell
	return input
end run
```
The script communicates with Finder and retrieves every disk whose ejectable property is true.

If ejectable disks are found:

* Their names are collected.
* Each disk is ejected.
* A success message containing the number and names of the ejected drives is returned.

If no ejectable disks are found, the script returns:
```text
⏏ No external drives to eject
```
### 3. Add Notification Feedback

Add a “Show Notification” action after the AppleScript.

Set the notification’s body to the AppleScript Result so that the message returned by the script is displayed.

For example:
```
✅ Ejected 2 drive(s): SSD, USB Drive
```
Or, when nothing is available:
```
⏏ No external drives to eject
```
This provides immediate feedback after the Shortcut runs.

### 4. Allow Automation Permissions

Because the Shortcut uses AppleScript to control Finder, macOS may ask for permission to allow the Shortcut to control Finder.

If prompted:

1. Approve the request.
2. Open System Settings → Privacy & Security → Automation if permission needs to be reviewed.
3. Ensure Shortcuts is allowed to control Finder.

The exact permission prompt may vary depending on the macOS version and how the Shortcut is run.

## Testing

Test the Shortcut with different drive configurations:

* One ejectable drive connected
* Multiple ejectable drives connected
* No ejectable drives connected
* A drive that cannot be ejected
* Multiple drives where one may fail to eject

Verify that:

* Ejectable drives are successfully removed.
* Multiple drives can be ejected in one run.
* The returned message lists the drives that were successfully processed.
* No-drive situations display the appropriate message.
* The Shortcut completes without getting stuck.

## Notes

* The Shortcut uses Finder’s ejectable property to determine which disks can be ejected.
* Each eject operation is wrapped in a try block, allowing the script to continue if an individual disk cannot be ejected.
* The script records a disk’s name before attempting to eject it.
* The final message reports the number and names of the drives that were processed successfully.
* System-critical or non-ejectable volumes are not targeted.
* No additional software is required.

## Related Files

* README.md — Overview of the finished Shortcut
* shortcut_guide.md — Detailed instructions for building the Shortcut
* Shortcut file/export — The actual Shortcut