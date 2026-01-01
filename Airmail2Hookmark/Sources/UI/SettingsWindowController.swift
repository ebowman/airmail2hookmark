import AppKit

/// Controller for the Settings window
@MainActor
final class SettingsWindowController {
    private var window: NSWindow?
    private var launchAtLoginCheckbox: NSButton?
    private var hookmarkRadio: NSButton?
    private var applemailRadio: NSButton?

    func showWindow() {
        if window == nil {
            createWindow()
        }

        // Refresh the UI state
        updateCheckboxState()
        updateRadioState()

        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func createWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 180),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        window.title = "Settings"
        window.isReleasedWhenClosed = false
        window.contentView = createContentView()

        self.window = window
    }

    private func createContentView() -> NSView {
        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 180))

        // Launch at Login checkbox
        let checkbox = NSButton(checkboxWithTitle: "Launch at Login", target: self, action: #selector(launchAtLoginToggled))
        checkbox.frame = NSRect(x: 20, y: 140, width: 260, height: 20)
        contentView.addSubview(checkbox)
        self.launchAtLoginCheckbox = checkbox

        // Description label for Launch at Login
        let descLabel = NSTextField(wrappingLabelWithString: "Automatically start Airmail2Hookmark when you log in.")
        descLabel.frame = NSRect(x: 20, y: 110, width: 260, height: 30)
        descLabel.font = NSFont.systemFont(ofSize: 11)
        descLabel.textColor = .secondaryLabelColor
        contentView.addSubview(descLabel)

        // Separator
        let separator = NSBox()
        separator.boxType = .separator
        separator.frame = NSRect(x: 20, y: 95, width: 260, height: 1)
        contentView.addSubview(separator)

        // Output URL Scheme label
        let schemeLabel = NSTextField(labelWithString: "Output URL Scheme:")
        schemeLabel.frame = NSRect(x: 20, y: 65, width: 260, height: 20)
        schemeLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        contentView.addSubview(schemeLabel)

        // Hookmark radio button
        let hookmarkRadio = NSButton(radioButtonWithTitle: URIScheme.hookmark.displayName, target: self, action: #selector(schemeChanged))
        hookmarkRadio.frame = NSRect(x: 20, y: 40, width: 260, height: 20)
        hookmarkRadio.tag = 0
        contentView.addSubview(hookmarkRadio)
        self.hookmarkRadio = hookmarkRadio

        // Apple Mail radio button
        let applemailRadio = NSButton(radioButtonWithTitle: URIScheme.applemail.displayName, target: self, action: #selector(schemeChanged))
        applemailRadio.frame = NSRect(x: 20, y: 15, width: 260, height: 20)
        applemailRadio.tag = 1
        contentView.addSubview(applemailRadio)
        self.applemailRadio = applemailRadio

        return contentView
    }

    private func updateCheckboxState() {
        launchAtLoginCheckbox?.state = LoginItemManager.shared.isEnabled ? .on : .off
    }

    private func updateRadioState() {
        let currentScheme = PreferencesManager.shared.selectedScheme
        hookmarkRadio?.state = currentScheme == .hookmark ? .on : .off
        applemailRadio?.state = currentScheme == .applemail ? .on : .off
    }

    @objc private func launchAtLoginToggled(_ sender: NSButton) {
        let shouldEnable = sender.state == .on

        do {
            try LoginItemManager.shared.setEnabled(shouldEnable)
        } catch {
            // Revert the checkbox if the operation failed
            sender.state = shouldEnable ? .off : .on

            // Show error alert
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = "Unable to Update Login Item"
            alert.informativeText = "Failed to \(shouldEnable ? "enable" : "disable") launch at login: \(error.localizedDescription)"
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }

    @objc private func schemeChanged(_ sender: NSButton) {
        let selectedScheme: URIScheme = sender.tag == 0 ? .hookmark : .applemail
        PreferencesManager.shared.selectedScheme = selectedScheme
        updateRadioState()
    }
}
