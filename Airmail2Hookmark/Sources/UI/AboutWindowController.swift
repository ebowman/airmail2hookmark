import AppKit

/// Controller for the About window
@MainActor
final class AboutWindowController {
    private var window: NSWindow?

    func showWindow() {
        if window == nil {
            createWindow()
        }

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

        window.title = "About Airmail2Hookmark"
        window.isReleasedWhenClosed = false
        window.contentView = createContentView()

        self.window = window
    }

    private func createContentView() -> NSView {
        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 180))

        // App icon
        let iconView = NSImageView(frame: NSRect(x: 125, y: 110, width: 50, height: 50))
        if let appIcon = NSImage(named: NSImage.applicationIconName) {
            iconView.image = appIcon
        }
        contentView.addSubview(iconView)

        // App name
        let nameLabel = NSTextField(labelWithString: "Airmail2Hookmark")
        nameLabel.frame = NSRect(x: 0, y: 80, width: 300, height: 24)
        nameLabel.alignment = .center
        nameLabel.font = NSFont.boldSystemFont(ofSize: 16)
        contentView.addSubview(nameLabel)

        // Version
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        let versionLabel = NSTextField(labelWithString: "Version \(version) (\(build))")
        versionLabel.frame = NSRect(x: 0, y: 55, width: 300, height: 20)
        versionLabel.alignment = .center
        versionLabel.font = NSFont.systemFont(ofSize: 12)
        versionLabel.textColor = .secondaryLabelColor
        contentView.addSubview(versionLabel)

        // Description
        let descLabel = NSTextField(labelWithString: "Redirects Airmail URLs to Hookmark")
        descLabel.frame = NSRect(x: 0, y: 30, width: 300, height: 20)
        descLabel.alignment = .center
        descLabel.font = NSFont.systemFont(ofSize: 11)
        descLabel.textColor = .tertiaryLabelColor
        contentView.addSubview(descLabel)

        // Copyright
        let year = Calendar.current.component(.year, from: Date())
        let copyrightLabel = NSTextField(labelWithString: "Copyright (c) \(year)")
        copyrightLabel.frame = NSRect(x: 0, y: 10, width: 300, height: 16)
        copyrightLabel.alignment = .center
        copyrightLabel.font = NSFont.systemFont(ofSize: 10)
        copyrightLabel.textColor = .tertiaryLabelColor
        contentView.addSubview(copyrightLabel)

        return contentView
    }
}
