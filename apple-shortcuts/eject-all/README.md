# 💾 Eject All

A small macOS Shortcut for quickly ejecting all connected disks and drives.

## What It Does

The shortcut ejects all currently connected and ejectable disks/drives from the Mac.

This is useful when you want to safely disconnect multiple external drives or other mounted disks without manually ejecting each one.

## Requirements

* macOS
* Shortcuts
* zsh / Terminal access

## How It Works

The Shortcut runs a zsh command that identifies all currently mounted ejectable disks and ejects them.

This allows multiple connected disks to be safely ejected with a single shortcut.

## Usage

Run the Shortcut whenever you want to eject all connected disks/drives.

The shortcut can be launched from:

* Shortcuts
* Spotlight
* Siri
* A keyboard shortcut
* The dock, if added there

## Notes

The shortcut only ejects disks that macOS allows to be ejected. System-critical volumes and other non-ejectable volumes are not affected.

No additional software is required.