import AppKit

/// Controller for the Settings window
@MainActor
final class SettingsWindowController {
    private var window: NSWindow?
    private var launchAtLoginCheckbox: NSButton?

    func showWindow() {
        if window == nil {
            createWindow()
        }

        // Refresh the checkbox state
        updateCheckboxState()

        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func createWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 100),
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
        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 100))

        // Launch at Login checkbox
        let checkbox = NSButton(checkboxWithTitle: "Launch at Login", target: self, action: #selector(launchAtLoginToggled))
        checkbox.frame = NSRect(x: 20, y: 40, width: 260, height: 20)
        contentView.addSubview(checkbox)

        self.launchAtLoginCheckbox = checkbox

        // Description label
        let descLabel = NSTextField(wrappingLabelWithString: "Automatically start Airmail2Hookmark when you log in.")
        descLabel.frame = NSRect(x: 20, y: 10, width: 260, height: 30)
        descLabel.font = NSFont.systemFont(ofSize: 11)
        descLabel.textColor = .secondaryLabelColor
        contentView.addSubview(descLabel)

        return contentView
    }

    private func updateCheckboxState() {
        launchAtLoginCheckbox?.state = LoginItemManager.shared.isEnabled ? .on : .off
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
}
