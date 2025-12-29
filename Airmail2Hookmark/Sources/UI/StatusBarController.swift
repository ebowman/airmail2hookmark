import AppKit

/// Manages the menu bar status item and its menu
@MainActor
final class StatusBarController {
    private var statusItem: NSStatusItem?
    private var aboutWindowController: AboutWindowController?
    private var settingsWindowController: SettingsWindowController?

    init() {
        setupStatusItem()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            // Use a mail-related SF Symbol
            if let image = NSImage(systemSymbolName: "envelope.arrow.triangle.branch", accessibilityDescription: "Airmail2Hookmark") {
                image.isTemplate = true
                button.image = image
            } else {
                // Fallback to text if symbol not available
                button.title = "A2H"
            }
        }

        statusItem?.menu = createMenu()
    }

    private func createMenu() -> NSMenu {
        let menu = NSMenu()

        // About item
        let aboutItem = NSMenuItem(
            title: "About Airmail2Hookmark",
            action: #selector(showAbout),
            keyEquivalent: ""
        )
        aboutItem.target = self
        menu.addItem(aboutItem)

        menu.addItem(NSMenuItem.separator())

        // Settings item
        let settingsItem = NSMenuItem(
            title: "Settings...",
            action: #selector(showSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        // Quit item
        let quitItem = NSMenuItem(
            title: "Quit Airmail2Hookmark",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    @objc private func showAbout() {
        if aboutWindowController == nil {
            aboutWindowController = AboutWindowController()
        }
        aboutWindowController?.showWindow()
    }

    @objc private func showSettings() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController()
        }
        settingsWindowController?.showWindow()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
