import Foundation

/// Errors that can occur during URL transformation
enum URLTransformError: Error, Equatable {
    case invalidScheme
    case missingMessageId
    case emptyMessageId
    case invalidURLConstruction
}

/// Transforms Airmail URLs to Hookmark or Apple Mail URLs
enum URLTransformer {
    /// Transforms an airmail: URL to a hook://email/ or message:// URL
    ///
    /// Input format: `airmail://message?mail={email}&messageid={id}`
    /// Output formats:
    /// - Hookmark: `hook://email/{id}`
    /// - Apple Mail: `message://%3C{id}%3E`
    ///
    /// - Parameters:
    ///   - airmailURL: The airmail URL to transform
    ///   - scheme: The target URI scheme (defaults to Hookmark)
    /// - Returns: A Result containing either the transformed URL or an error
    static func transform(airmailURL: URL, scheme: URIScheme = .hookmark) -> Result<URL, URLTransformError> {
        // Validate scheme
        guard airmailURL.scheme?.lowercased() == "airmail" else {
            return .failure(.invalidScheme)
        }

        // Parse query parameters
        guard let components = URLComponents(url: airmailURL, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return .failure(.missingMessageId)
        }

        // Find messageid parameter
        guard let messageIdItem = queryItems.first(where: { $0.name == "messageid" }) else {
            return .failure(.missingMessageId)
        }

        // Validate messageid is not empty
        guard let messageId = messageIdItem.value, !messageId.isEmpty else {
            return .failure(.emptyMessageId)
        }

        // Construct output URL based on selected scheme
        // The messageid is already URL-encoded from the original URL, so we use it as-is
        let outputURLString: String
        switch scheme {
        case .hookmark:
            outputURLString = "hook://email/\(messageId)"
        case .applemail:
            // Apple Mail message: scheme uses angle brackets around the message ID
            outputURLString = "message://%3C\(messageId)%3E"
        }

        guard let outputURL = URL(string: outputURLString) else {
            return .failure(.invalidURLConstruction)
        }

        return .success(outputURL)
    }
}
