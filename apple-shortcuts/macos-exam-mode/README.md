# macOS Exam Mode

A lightweight macOS automation utility designed to prepare a Mac for proctored examinations by temporarily closing unnecessary applications and restoring the previous workspace afterward.

Built primarily with **AppleScript** and integrated with **macOS Shortcuts**, the goal is to provide a simple, one-click way to switch between a regular working environment and a minimal examination environment.

## Features

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

1. Capture the currently running applications.
2. Save the original workspace state.
3. Identify applications protected by the configuration.
4. Gracefully quit non-whitelisted applications.
5. Enable Do Not Disturb.
6. Report the outcome.

### Restore Workspace

1. Read the previously saved workspace state.
2. Relaunch applications that were running before Exam Mode.
3. Attempt to restore their previous windows and sessions where supported.
4. Restore the original Do Not Disturb setting.
5. Clear the saved session after successful restoration.

## Configuration

Application rules will be maintained separately from the automation scripts.

The intended configuration will support:

- **Whitelist:** Applications that should remain running during Exam Mode.
- **Blacklist:** Applications explicitly designated for closure.
- **Strict Mode:** Applications not protected by the configuration are considered closure candidates.

The initial implementation will prioritise a strict default configuration with the ability to customise application rules.

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
- **macOS Shortcuts:** One-click user interface.
- **Property Lists / Configuration Files:** Persistent application configuration and session state.

Python is not required for the intended implementation.

## Roadmap

- [ ] Establish project structure and documentation.
- [ ] Implement running application detection.
- [ ] Implement configurable application filtering.
- [ ] Implement workspace state capture.
- [ ] Implement graceful application termination.
- [ ] Implement workspace restoration.
- [ ] Implement Do Not Disturb management.
- [ ] Integrate with macOS Shortcuts.
- [ ] Test complete Exam Mode and restoration workflows.
- [ ] Finalise documentation and usage instructions.