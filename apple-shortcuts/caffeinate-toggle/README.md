# ☕ Caffeinate Toggle

A small macOS Shortcut for quickly toggling the caffeinate command on and off.

## What It Does

The shortcut toggles a caffeinate process:

* Off → On: Starts caffeinate, preventing the Mac from going to sleep.
* On → Off: Stops the existing caffeinate process.

This is useful when you need to temporarily keep your Mac awake without changing the system’s sleep settings.

## Requirements

* macOS
* Shortcuts
* zsh / Terminal access

## How It Works

The Shortcut runs a zsh command that checks whether caffeinate is currently running.

If it is running, the process is terminated.

If it is not running, a new caffeinate process is started.

## Usage

Run the Shortcut whenever you want to toggle the state.

The shortcut can be launched from:

* Shortcuts
* Spotlight
* Siri
* A keyboard shortcut
* The dock, if added there

## Notes

caffeinate is a built-in macOS command, so no additional software is required.