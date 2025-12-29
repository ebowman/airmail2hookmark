import Foundation
import ServiceManagement

/// Manages the app's login item status using SMAppService (macOS 13+)
@MainActor
final class LoginItemManager: ObservableObject {
    static let shared = LoginItemManager()

    @Published private(set) var isEnabled: Bool

    private init() {
        self.isEnabled = SMAppService.mainApp.status == .enabled
    }

    /// Enables or disables launching the app at login
    /// - Parameter enabled: Whether the app should launch at login
    /// - Throws: An error if the operation fails
    func setEnabled(_ enabled: Bool) throws {
        if enabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }

        // Update the published state
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    /// Refreshes the current status from the system
    func refresh() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }
}
