
# macOS Exam Mode

A lightweight macOS automation utility designed to prepare a Mac for proctored examinations by temporarily closing unnecessary applications and restoring the previous workspace afterward.

Built primarily with **AppleScript** and integrated with **macOS Shortcuts**, the utility provides a simple way to switch between a regular working environment and a minimal examination environment.

The project is designed around a portable installation architecture, allowing users to configure the project directory on their own Mac without relying on hardcoded installation paths.

## Features

### Implemented

- **Application Detection:** Identify currently running user applications.
- **Configurable Application Rules:** Support whitelists, blacklists and protected applications.
- **Workspace State Capture:** Record running applications and the original Focus state.
- **Graceful Application Termination:** Request applications to quit without force termination.
- **Focus Management:** Capture and restore the original Focus using macOS Shortcuts.
- **Workspace Restoration:** Relaunch previously running applications and restore the original Focus.
- **Exam Mode Orchestration:** Integrate workspace capture, application termination and Focus management into a complete activation workflow.
- **Portable Installation:** Allow users to select their project directory and store its location in macOS Application Support.
- **User-Facing Shortcuts:** Provide separate Setup Exam Mode, Start Exam Mode and Restore Workspace shortcuts.

### Future Improvements

- **Installation Portability:** Further streamline distribution and setup for other Macs.
- **Workflow Validation:** Expand testing across different macOS versions, application behaviours and failure scenarios.
- **User Experience:** Improve status reporting and error handling within the Shortcuts interface.



## Architecture

macOS Exam Mode separates user-facing automation, application logic and machine-specific configuration into distinct components.

### Project Structure

```text
macos-exam-mode/
├── config/
│   └── apps.plist
├── scripts/
│   ├── detect_applications.applescript
│   ├── test_config.applescript
│   ├── capture_workspace.applescript
│   ├── terminate_applications.applescript
│   ├── restore_focus.applescript
│   ├── restore_applications.applescript
│   ├── restore_workspace.applescript
│   ├── start_exam_mode.applescript
│   └── setup_exam_mode.applescript
├── shortcuts/
│   ├── Setup Exam Mode.shortcut
│   ├── Start Exam Mode.shortcut
│   ├── Restore Workspace.shortcut
│   ├── Exam Mode - Capture Focus.shortcut
│   ├── Enable DnD.shortcut
│   └── Restore Exam Mode Focus.shortcut
└── state/
    └── workspace_snapshot.plist
```

The project is organised into three main components:

- **Configuration:** Defines application handling rules.
- **Scripts:** Contains the AppleScript implementation for application detection, workspace management and Exam Mode orchestration.
- **Shortcuts:** Provides user-facing automation and Focus management integration.

The `state/` directory stores runtime workspace snapshots and is not intended to contain committed session data.

### Installation Configuration

The project supports portable installation through a local configuration file stored outside the repository:

`~/Library/Application Support/MacOS Exam Mode/config.plist`

This file stores the configured project directory using the `projectDirectory` key.

The Setup Exam Mode shortcut:

1. Prompts the user to select the project directory.
2. Validates the selected installation.
3. Creates the Application Support configuration directory if necessary.
4. Saves and verifies the project directory.

Subsequent user-facing shortcuts read this configuration to locate and execute their respective AppleScript engines.

This allows the project directory to be relocated without requiring hardcoded paths in the Start Exam Mode and Restore Workspace shortcuts.

### Configuration Separation

The project uses two distinct configuration locations:

| Location | Responsibility |
|---|---|
| `config/apps.plist` | Defines application handling rules shared by the project. |
| `~/Library/Application Support/MacOS Exam Mode/config.plist` | Stores the local installation path for the current Mac. |

The Application Support configuration is generated locally during setup and should not be committed to the repository.


## Installation

### Prerequisites

- A Mac running macOS with the Shortcuts app.
- AppleScript and Shortcuts automation permissions.
- The macOS Exam Mode project files.
- The required Focus-management shortcuts imported into macOS Shortcuts.

### Setup

1. Download or clone the repository.
2. Ensure the `macos-exam-mode` project directory is stored in a location where it can remain accessible.
3. Import the provided `.shortcut` files from the `shortcuts/` directory into the macOS Shortcuts app.
4. Run **Setup Exam Mode**.
5. Select the `macos-exam-mode` project directory when prompted.
6. Confirm that the setup process reports successful configuration.

The setup process validates the selected project directory and saves its location to:

`~/Library/Application Support/MacOS Exam Mode/config.plist`

If the project directory is moved, run Setup Exam Mode again and select its new location.

### Permissions and Automation

macOS may request permissions when the scripts and shortcuts interact with other applications or manage Focus settings.

Grant the necessary permissions when prompted. Depending on the macOS version and security settings, additional permissions may need to be configured through System Settings.


## Usage

The utility provides three primary user-facing shortcuts.

### Setup Exam Mode

Run this shortcut when installing the project for the first time or when its directory has been moved.

- Select the project directory.
- The installation is validated.
- The local project path is saved in Application Support.
- A confirmation dialog indicates successful setup.

### Start Exam Mode

Run this shortcut before beginning an examination.

The activation workflow:

1. Checks that an existing workspace snapshot will not be overwritten.
2. Captures currently running applications and the original Focus state.
3. Saves the workspace snapshot.
4. Identifies applications eligible for termination.
5. Requests confirmation before closing applications.
6. Gracefully terminates eligible applications.
7. Enables Do Not Disturb after successful application termination.
8. Reports the activation outcome.

If activation is cancelled, the newly created snapshot is removed because no termination requests have been issued.

If termination or Focus activation fails, the snapshot is preserved to support recovery.

### Restore Workspace

Run this shortcut after the examination to restore the previous working environment.

The restoration workflow:

1. Reads the saved workspace snapshot.
2. Relaunches applications that were running before Exam Mode.
3. Restores the original Focus state.
4. Removes the workspace snapshot after successful restoration.
5. Reports the restoration outcome.

If application or Focus restoration fails, the snapshot is preserved so restoration can be retried.



## Focus Management

macOS Exam Mode uses three helper shortcuts to capture, enable and restore macOS Focus states. These operate alongside the three primary user-facing shortcuts.

### Helper Shortcuts

| Shortcut | Responsibility |
|---|---|
| `Exam Mode - Capture Focus` | Retrieves the name of the currently active Focus. Returns `NONE` if no Focus is active. |
| `Enable DnD` | Enables Do Not Disturb. |
| `Restore Exam Mode Focus` | Restores the previously active Focus, or turns Do Not Disturb off if the saved value is `NONE`. |

These helper shortcuts are stored in the `shortcuts/` directory and must be imported into the macOS Shortcuts app. Their names must remain consistent with the references used by the AppleScripts.

### Focus State Capture

During workspace capture, the current Focus state is retrieved using `Exam Mode - Capture Focus`.

The resulting value is stored in the `originalFocus` field of the workspace snapshot:

`state/workspace_snapshot.plist`

If no Focus is active, the value `NONE` is stored instead.

### Focus Restoration

During workspace restoration, `restore_focus.applescript` reads the saved `originalFocus` value and passes it to the `Restore Exam Mode Focus` shortcut.

- If a Focus name was saved, the corresponding Focus is activated.
- If `NONE` was saved, Do Not Disturb is turned off.

This allows the utility to return the Mac to its previous Focus state after an examination.

### Dependencies

Focus management depends on:

- The macOS Shortcuts app.
- The three helper shortcuts being imported and available.
- macOS permissions allowing the scripts and shortcuts to manage Focus settings.


## Configuration

Application handling rules are defined in:

`config/apps.plist`

This file controls which applications are kept running, which are targeted for termination and which are protected from being closed.

### Application Rules

The configuration supports the following rules:

| Setting | Responsibility |
|---|---|
| `mode` | Determines how applications without explicit rules are handled. |
| `whitelist` | Lists applications that should remain running. |
| `blacklist` | Lists applications that should be targeted for termination. |
| `always_protect` | Lists applications that must never be targeted for termination. |
| `preserve_system_apps` | Controls whether macOS system applications and processes are protected. |

### Rule Evaluation Priority

When determining how an application should be handled, the utility applies the following priority:

1. **Always Protect:** Applications explicitly listed in `always_protect` are never targeted for termination.
2. **System Protection:** When `preserve_system_apps` is enabled, protected macOS system applications and processes are excluded.
3. **Blacklist:** Applications listed in `blacklist` are targeted for termination.
4. **Whitelist:** Applications listed in `whitelist` are kept running.
5. **Strict Mode:** When `mode` is set to `strict`, otherwise unclassified applications are targeted for termination.

This priority ensures that explicit protection takes precedence over ordinary application rules.

### Default Application Rules

The initial configuration includes:

| Application | Bundle Identifier | Rule |
|---|---|---|
| Google Chrome | `com.google.Chrome` | Whitelisted |
| Finder | `com.apple.finder` | Whitelisted and always protected |

The default configuration uses strict mode, meaning applications without an explicit rule are generally targeted for termination, subject to system protection and the rule priority described above.

Users can modify `apps.plist` to suit their own examination requirements.



## How It Works

The utility coordinates several AppleScript engines to capture, modify and restore the Mac's workspace.

The primary entry points are:

- `start_exam_mode.applescript`
- `restore_workspace.applescript`

These scripts use the configured project directory to locate the supporting scripts, configuration and workspace state.

### Start Exam Mode

The Start Exam Mode workflow is coordinated by `start_exam_mode.applescript`.

1. **Installation Validation:** Reads the local Application Support configuration and verifies that the project directory and required scripts are available.
2. **Snapshot Validation:** Checks whether a previous workspace snapshot already exists. Existing snapshots are never overwritten.
3. **Workspace Capture:** Runs `capture_workspace.applescript` to record currently running applications and the original Focus state.
4. **Application Filtering:** Uses the application configuration to determine which applications are eligible for termination.
5. **User Confirmation:** Requests confirmation before proceeding with application termination.
6. **Application Termination:** Runs `terminate_applications.applescript`, requesting eligible applications to quit gracefully.
7. **Focus Management:** Enables Do Not Disturb after successful application termination.

If the user cancels before termination begins, the newly created snapshot is removed.

If application termination or Focus activation fails, the snapshot is retained to support recovery.

### Restore Workspace

The Restore Workspace workflow is coordinated by `restore_workspace.applescript`.

1. **Installation Validation:** Reads the local Application Support configuration and verifies that the required restoration scripts are available.
2. **Snapshot Validation:** Checks that a workspace snapshot exists and can be read.
3. **Application Restoration:** Runs `restore_applications.applescript` to relaunch applications recorded in the snapshot.
4. **Focus Restoration:** Runs `restore_focus.applescript` to restore the original Focus state.
5. **Snapshot Cleanup:** Deletes the snapshot only after both application and Focus restoration succeed.

Applications that are already running are skipped rather than launched again.

If either application restoration or Focus restoration fails, the snapshot is preserved so the user can retry restoration.



## Restoration Behaviour

macOS Exam Mode restores the workspace using the application and Focus information captured when Exam Mode was activated.

### Application Restoration

The utility records the applications that were running before Exam Mode began, including their names and bundle identifiers.

During restoration:

- Applications recorded in the snapshot are relaunched if they are not already running.
- Applications that are already running are skipped.
- Applications launched after Exam Mode was activated are not automatically closed.
- The utility does not attempt to recreate the exact state of individual application windows, documents or browser tabs.

The restoration of documents, windows and sessions depends on the individual application's own behaviour.

### Snapshot Management

The workspace snapshot is stored at:

`state/workspace_snapshot.plist`

The snapshot contains:

- `capturedAt`: The time the workspace was captured.
- `originalFocus`: The Focus state active before Exam Mode.
- `runningApplications`: The applications that were running at capture time.

The snapshot is retained until restoration completes successfully.

If application restoration or Focus restoration fails, the snapshot is preserved so that restoration can be attempted again.

This also means an existing snapshot prevents another Exam Mode activation from overwriting the saved workspace.

### Recovery Considerations

If restoration fails:

1. Review any error reported by the shortcut.
2. Check whether the affected applications or Focus settings can be restored manually.
3. Retry Restore Workspace while the snapshot remains available.

The snapshot acts as a recovery reference and is only deleted after both application and Focus restoration succeed.



## Safety Considerations

macOS Exam Mode is designed to minimise disruption to the user's working environment.

The following safeguards are implemented:

- **Graceful Termination:** Applications are asked to quit normally. The utility does not force-quit applications.
- **User Confirmation:** Application termination requires explicit confirmation before proceeding.
- **Snapshot Protection:** Existing workspace snapshots are never overwritten.
- **Protected Applications:** Applications listed in `always_protect` are excluded from termination.
- **System Protection:** macOS system applications and processes can be protected through `preserve_system_apps`.
- **Failure Recovery:** Workspace snapshots are retained when application termination, Focus activation or restoration fails.
- **Conservative Restoration:** Applications that are already running are not launched again.

### Before Activating Exam Mode

Users should:

- Save all unsaved work.
- Close any applications that should not be part of the examination environment.
- Verify the application rules in `config/apps.plist`.
- Ensure the project directory remains accessible.

Although the utility requests applications to quit gracefully, it cannot guarantee that every application will save its state or restore its previous session.



## Limitations

macOS Exam Mode automates application termination and workspace restoration, but it does not provide complete control over the macOS environment.

Known limitations include:

- **Application Session Recovery:** The utility records running applications, not their complete internal state. Window layouts, open documents and browser tabs depend on each application's own session-restoration behaviour.
- **Unsaved Work:** Graceful termination does not guarantee that unsaved work will be preserved. Applications may display their own save prompts or prevent termination.
- **Newly Launched Applications:** Applications launched after Exam Mode begins are not included in the original workspace snapshot and are not automatically closed during restoration.
- **Focus Dependencies:** Focus management relies on macOS Shortcuts and the availability of the required helper shortcuts.
- **Application Compatibility:** Different applications may respond differently to AppleScript termination and relaunch requests.
- **Permissions:** macOS privacy and automation permissions may affect whether scripts can interact with applications or manage Focus settings.
- **Installation Location:** If the project directory is moved, Setup Exam Mode must be run again to update the locally stored project path.

The utility is intended to provide a convenient and recoverable transition between normal usage and an examination environment, rather than guarantee a perfectly identical restoration of every aspect of the previous session.



## Technology

- **AppleScript:** Core automation logic for application detection, termination, workspace capture and restoration.
- **macOS Shortcuts:** User-facing workflows and integration with macOS Focus settings.
- **Property Lists (plist):** Structured storage for application configuration, installation settings and workspace snapshots.
- **macOS Application Support:** Stores machine-specific installation configuration outside the project repository.
- **Git:** Version control and project change tracking.



## Roadmap

Potential future improvements include:

- **Broader Compatibility Testing:** Validate behaviour across different macOS versions and application types.
- **Improved Error Reporting:** Provide clearer diagnostic information when application termination, Focus management or restoration fails.
- **Distribution and Installation:** Further streamline setup and distribution for users on other Macs.
- **Expanded Recovery Testing:** Test additional failure scenarios to improve the reliability of workspace restoration.
- **User Experience:** Refine shortcut notifications and status reporting.
