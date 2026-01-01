import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon - we're a menu bar only app
        NSApp.setActivationPolicy(.accessory)

        // Initialize the status bar controller
        statusBarController = StatusBarController()
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Cleanup if needed
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            handleAirmailURL(url)
        }
    }

    private func handleAirmailURL(_ url: URL) {
        let selectedScheme = PreferencesManager.shared.selectedScheme
        let result = URLTransformer.transform(airmailURL: url, scheme: selectedScheme)

        switch result {
        case .success(let outputURL):
            NSWorkspace.shared.open(outputURL)

        case .failure(let error):
            showErrorAlert(for: error, originalURL: url)
        }
    }

    private func showErrorAlert(for error: URLTransformError, originalURL: URL) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Unable to Transform URL"

        switch error {
        case .invalidScheme:
            alert.informativeText = "The URL does not use the airmail: scheme.\n\nReceived: \(originalURL.absoluteString)"
        case .missingMessageId:
            alert.informativeText = "The airmail URL is missing the required 'messageid' parameter.\n\nReceived: \(originalURL.absoluteString)"
        case .emptyMessageId:
            alert.informativeText = "The airmail URL has an empty 'messageid' parameter.\n\nReceived: \(originalURL.absoluteString)"
        case .invalidURLConstruction:
            alert.informativeText = "Failed to construct the Hookmark URL.\n\nOriginal: \(originalURL.absoluteString)"
        }

        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
