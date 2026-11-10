# macOS Exam Mode

A lightweight macOS automation utility designed to prepare a Mac for proctored examinations by temporarily closing unnecessary applications and restoring the previous workspace afterward.

Built primarily with **AppleScript** and integrated with **macOS Shortcuts**, the goal is to provide a simple, one-click way to switch between a regular working environment and a minimal examination environment.

## Features

### Implemented

- **Application Detection:** Identify currently running user applications.
- **Configurable Application Rules:** Support whitelists, blacklists and protected applications.
- **Workspace State Capture:** Record running applications and the original Focus state.
- **Graceful Application Termination:** Request applications to quit without force termination.
- **Focus Management:** Capture and restore the original Focus using macOS Shortcuts.
- **Workspace Restoration:** Relaunch previously running applications and reinstate previous focus mode.

### Planned

- **One-Click Automation:** Integrate the individual components into complete Start Exam Mode and Restore Workspace workflows.
- **Complete Workflow Validation:** Test the entire examination and restoration lifecycle.

### Focus Management

Exam Mode uses macOS Shortcuts to manage Focus states and Do Not Disturb.

#### Shortcuts

The following shortcuts are used:

| Shortcut | Responsibility |
|---|---|
| `Exam Mode - Capture Focus` | Retrieves the currently active Focus name. Returns `NONE` if no Focus is active. |
| `Enable DnD` | Enables Do Not Disturb. |
| `Restore Exam Mode Focus` | Restores the original Focus using the supplied Focus name. |

Shortcut exports are stored in `shortcuts/` and can be imported through the macOS Shortcuts app.

#### Focus State Capture

During workspace capture, the active Focus is recorded in
`state/workspace_snapshot.plist` under the root-level `originalFocus` key.

Examples:

- `Personal` — a named Focus was active.
- `Work` — another named Focus was active.
- `NONE` — no Focus was active.

#### Focus Restoration

`scripts/restore_focus.applescript` retrieves the saved
`originalFocus` value and passes it to the `Restore Exam Mode Focus` shortcut.

The restoration shortcut handles two cases:

- Named Focus: activates the previously active Focus.
- `NONE`: turns Do Not Disturb off.

Restoration is aborted if the workspace snapshot is missing or the
`originalFocus` value is missing or empty.

#### Dependencies

- macOS Shortcuts app.
- The three shortcuts listed above must be imported.
- Shortcut names must match the names referenced by the AppleScripts.

### Planned Features

- **Strict Exam Mode:** Gracefully quit non-essential applications while preserving macOS system processes.
- **Configurable Application Rules:** Maintain application whitelists and blacklists to customise which applications remain open or are targeted for closure.
- **Workspace State Capture:** Record which applications were running before entering Exam Mode.
- **Notification Management:** Enable Do Not Disturb while preserving the user's original notification setting.
- **Workspace Restoration:** Relaunch previously running applications after the examination.
- **One-Click Automation:** Provide separate macOS Shortcuts for entering and exiting Exam Mode.

### Initial Configuration

The initial whitelist consists of:

| Application | Bundle Identifier |
|---|---|
| Google Chrome | `com.google.Chrome` |
| Finder | `com.apple.finder` |

All other eligible user applications will be considered for graceful termination by default.

## How It Works

The utility is designed around two primary operations:

### Start Exam Mode

1. Capture the currently running applications and original Focus state.
2. Save the workspace snapshot.
3. Enable Do Not Disturb.
4. Identify applications protected by the configuration.
5. Gracefully quit non-whitelisted applications.
6. Report the outcome.

### Restore Workspace

1. Read the previously saved workspace state.
2. Relaunch applications that were running before Exam Mode.
3. Attempt to restore their previous windows and sessions where supported.
4. Restore the original Do Not Disturb setting.
5. Clear the saved session after successful restoration.

## Configuration

Application rules are maintained separately from the automation scripts in `config/apps.plist`.

The configuration supports:

- **Whitelist:** Applications that should remain running during Exam Mode.
- **Blacklist:** Applications explicitly designated for closure.
- **Always Protect:** Applications that must never be targeted for closure.
- **Strict Mode:** Applications not protected by the configuration are considered closure candidates.

The initial configuration uses strict mode, with Google Chrome and Finder included in the protected application rules.

## Restoration Behaviour

The utility aims to restore the user's previous working environment as closely as macOS and individual applications permit.

Application relaunching and window restoration are separate concerns. While previously running applications can generally be reopened, restoring their exact window arrangements, tabs and documents depends on each application's native session-restoration capabilities.

## Safety Considerations

- Applications will be asked to quit gracefully rather than forcefully terminated.
- Essential macOS processes and protected system applications will be excluded.
- Existing Exam Mode session data must not be overwritten by repeated activation.
- Unsaved work should be saved before entering Exam Mode.
- The utility will not interfere with examination software, proctoring mechanisms or security controls.

## Limitations

- Exact workspace restoration cannot be guaranteed across all applications.
- Applications that refuse to quit may remain running.
- Some applications may require additional permissions for AppleScript automation.
- macOS notification settings may require additional system permissions or integration.
- Applications launched after entering Exam Mode will not automatically become part of the original restoration snapshot.

## Technology

- **AppleScript:** Application detection, lifecycle management and workspace automation.
- **macOS Shortcuts:** Focus management and user-facing automation.
- **Property Lists:** Application configuration and persistent workspace state.

Python is not required for the intended implementation.

## Roadmap

- ✅ Establish project structure and documentation.
- ✅ Implement running application detection.
- ✅ Implement configurable application filtering.
- ✅ Implement workspace state capture.
- ✅ Implement graceful application termination.
- ✅ Implement Do Not Disturb management.
- ✅ Implement workspace restoration.
- [ ] Integrate with macOS Shortcuts.
- [ ] Test complete Exam Mode and restoration workflows.
- [ ] Finalise documentation and usage instructions.