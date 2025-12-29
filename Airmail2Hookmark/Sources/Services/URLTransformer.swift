import Foundation

/// Errors that can occur during URL transformation
enum URLTransformError: Error, Equatable {
    case invalidScheme
    case missingMessageId
    case emptyMessageId
    case invalidURLConstruction
}

/// Transforms Airmail URLs to Hookmark URLs
enum URLTransformer {
    /// Transforms an airmail: URL to a hook://email/ URL
    ///
    /// Input format: `airmail://message?mail={email}&messageid={id}`
    /// Output format: `hook://email/{id}`
    ///
    /// - Parameter airmailURL: The airmail URL to transform
    /// - Returns: A Result containing either the transformed Hookmark URL or an error
    static func transform(airmailURL: URL) -> Result<URL, URLTransformError> {
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

        // Construct Hookmark URL
        // The messageid is already URL-encoded from the original URL, so we use it as-is
        let hookmarkURLString = "hook://email/\(messageId)"

        guard let hookmarkURL = URL(string: hookmarkURLString) else {
            return .failure(.invalidURLConstruction)
        }

        return .success(hookmarkURL)
    }
}
