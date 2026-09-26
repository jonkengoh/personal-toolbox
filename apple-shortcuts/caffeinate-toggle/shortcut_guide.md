# Caffeinate Toggle Shortcut

## Overview

This shortcut provides a quick way to toggle `caffeinate` on macOS, preventing the Mac from going to sleep while it is enabled.

## Prerequisites

- macOS
- Shortcuts app
- Basic familiarity with shell commands

## Shortcut Structure

The Shortcut follows this flow:

1. Check whether `caffeinate` is running
2. If it is running, terminate it
3. If it isn't running, start it
4. Display the current state using a notification

## Building the Shortcut

### 1. Create the Shortcut

- Open the **Shortcuts** app
- Create a new Shortcut
- Give it a suitable name, such as `Caffeinate Toggle`

### 2. Add the Shell Script

Add a "**Run Shell Script**" action and use the following:

```zsh
if pgrep caffeinate >/dev/null; then
  pkill caffeinate
  echo "Sleep allowed again ✅"
else
  caffeinate -dimsu &
  echo "Mac will stay awake ☕"
fi
```

The script checks whether a caffeinate process is already running.

* If one is found, pkill terminates it.
* If one isn’t found, caffeinate is started in the background.
* The script outputs a message describing the new state.

### 3. Add Notification Feedback

Add a "**Show Notification**" action after the shell script.

Set the notification’s body to the Shell Script Result so that the message from the shell script is displayed.

This provides quick feedback when the Shortcut is run:

* Mac will stay awake ☕
* Sleep allowed again ✅

### 4. Allow Shell Permissions

1. Click the Info button on the right side of the Shortcut.
2. Select Privacy.
3. Ensure the required Notification and Shell permissions are enabled.

## Testing

Test both states:

* Caffeinate starts when it is not running
* Caffeinate stops when it is running
* The correct notification is displayed
* Running the Shortcut repeatedly correctly toggles the state

## Notes

* caffeinate is a built-in macOS command.
* The & runs caffeinate in the background so that the Shortcut can finish and display its notification.
* The Shortcut toggles the caffeinate process rather than changing macOS sleep settings.

Related Files

* README.md — Overview of the finished Shortcut
* Shortcut file/export — The actual Shortcut