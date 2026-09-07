# Activity Logger

An Apple Shortcut for frictionless daily activity logging.

## Purpose

Log activities throughout the day by recording only the
time and activity description. The Shortcut automatically
calculates activity durations based on when the next
activity is logged. Notes will be created in a folder named
"Daily Logs"

## Example

1300 - 1330: [Working on project]
1330 - 1405: [Lunch]
1405 - 1520: [Video editing]

## Usage

1. Run the Shortcut when starting your first activity.
2. Run it again when the activity ends.
3. Enter the activity description.
4. Choose whether to immediately start another activity.

## Current implementation

- Uses Apple Notes for storage
- Uses timestamp-based state detection
- Creates a finalised log at the end for genAI prompt