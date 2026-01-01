import Foundation

/// Manages user preferences using UserDefaults
/// Note: UserDefaults is thread-safe, so no @MainActor needed
final class PreferencesManager {
    static let shared = PreferencesManager()

    private let defaults = UserDefaults.standard
    private let selectedSchemeKey = "selectedURIScheme"

    private init() {}

    /// The currently selected URI scheme for email links
    var selectedScheme: URIScheme {
        get {
            guard let rawValue = defaults.string(forKey: selectedSchemeKey),
                  let scheme = URIScheme(rawValue: rawValue) else {
                return .hookmark // Default to Hookmark
            }
            return scheme
        }
        set {
            defaults.set(newValue.rawValue, forKey: selectedSchemeKey)
        }
    }
}
