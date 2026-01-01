import Foundation

/// Available URI schemes for email linking
enum URIScheme: String, CaseIterable {
    case hookmark = "hook"
    case applemail = "message"

    var displayName: String {
        switch self {
        case .hookmark:
            return "Hookmark (hook://email/...)"
        case .applemail:
            return "Apple Mail (message://...)"
        }
    }
}
