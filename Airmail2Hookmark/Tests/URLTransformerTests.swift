//
//  URLTransformerTests.swift
//  Airmail2HookmarkTests
//
//  Unit tests for the URLTransformer service that converts
//  airmail: URLs to hook: or message: URLs.
//

import XCTest
@testable import Airmail2Hookmark

final class URLTransformerTests: XCTestCase {

    // MARK: - Hookmark Scheme Tests (Default)

    func testValidAirmailURLWithMessageIdReturnsCorrectHookURL() throws {
        // Given
        let airmailURL = URL(string: "airmail://message?messageid=ABC123")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL)

        // Then
        let hookURL = try result.get()
        XCTAssertEqual(hookURL.absoluteString, "hook://email/ABC123")
    }

    func testURLWithEncodedCharactersInMessageIdPreservesEncoding() throws {
        // Given: messageid contains URL-encoded characters
        let encodedMessageId = "AAMk%2BXYZ%3D%3D"
        let airmailURL = URL(string: "airmail://message?messageid=\(encodedMessageId)")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL)

        // Then: The encoding should be preserved in the output
        let hookURL = try result.get()
        XCTAssertEqual(hookURL.absoluteString, "hook://email/\(encodedMessageId)")
    }

    func testURLWithMailParameterIgnoresMailAndExtractsMessageId() throws {
        // Given: URL contains both mail and messageid parameters
        let airmailURL = URL(string: "airmail://message?mail=user%40example.com&messageid=MSG456")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL)

        // Then: mail parameter is ignored, messageid is used
        let hookURL = try result.get()
        XCTAssertEqual(hookURL.absoluteString, "hook://email/MSG456")
    }

    func testURLWithExtraParametersIgnoresThemAndExtractsMessageId() throws {
        // Given: URL contains extra unknown parameters
        let airmailURL = URL(string: "airmail://message?foo=bar&messageid=MSG789&baz=qux")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL)

        // Then: Extra parameters are ignored
        let hookURL = try result.get()
        XCTAssertEqual(hookURL.absoluteString, "hook://email/MSG789")
    }

    func testRealWorldExampleFromDocumentation() throws {
        // Given: Real-world example from CLAUDE.md
        let messageId = "AAMkADg1ZGM0ZGE3LWMxZDctNDBhOC04OWNhLTZhM2VlNjNhYzIxNQBGAAAAAADtYuK5T8IaS7TB7_AKKA9FBwBcJ6m9i2jPSbO7OUxjrFzMAAAAAAEMAABcJ6m9i2jPSbO7OUxjrFzMAAFRe7JEAAA%3D"
        let airmailURL = URL(string: "airmail://message?mail=joe%40user.com&messageid=\(messageId)")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL)

        // Then
        let hookURL = try result.get()
        XCTAssertEqual(hookURL.absoluteString, "hook://email/\(messageId)")
    }

    func testMessageIdFirstInQueryString() throws {
        // Given: messageid appears before mail parameter
        let airmailURL = URL(string: "airmail://message?messageid=FIRST123&mail=test%40test.com")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL)

        // Then
        let hookURL = try result.get()
        XCTAssertEqual(hookURL.absoluteString, "hook://email/FIRST123")
    }

    // MARK: - Error Cases

    func testMissingMessageIdParameterReturnsError() {
        // Given: URL without messageid parameter
        let airmailURL = URL(string: "airmail://message?mail=user%40example.com")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL)

        // Then
        switch result {
        case .success:
            XCTFail("Expected error for missing messageid parameter")
        case .failure(let error):
            XCTAssertEqual(error, .missingMessageId)
        }
    }

    func testEmptyMessageIdValueReturnsError() {
        // Given: messageid parameter exists but has empty value
        let airmailURL = URL(string: "airmail://message?messageid=")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL)

        // Then
        switch result {
        case .success:
            XCTFail("Expected error for empty messageid value")
        case .failure(let error):
            XCTAssertEqual(error, .emptyMessageId)
        }
    }

    func testInvalidURLFormatWithNoQueryStringReturnsError() {
        // Given: URL with no query parameters at all
        let airmailURL = URL(string: "airmail://message")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL)

        // Then
        switch result {
        case .success:
            XCTFail("Expected error for URL with no query string")
        case .failure(let error):
            XCTAssertEqual(error, .missingMessageId)
        }
    }

    func testNonAirmailSchemeReturnsError() {
        // Given: URL with different scheme
        let httpURL = URL(string: "https://example.com?messageid=ABC123")!

        // When
        let result = URLTransformer.transform(airmailURL: httpURL)

        // Then
        switch result {
        case .success:
            XCTFail("Expected error for non-airmail scheme")
        case .failure(let error):
            XCTAssertEqual(error, .invalidScheme)
        }
    }

    func testMailtoSchemeReturnsError() {
        // Given: mailto URL (similar but not airmail)
        let mailtoURL = URL(string: "mailto:user@example.com?messageid=ABC123")!

        // When
        let result = URLTransformer.transform(airmailURL: mailtoURL)

        // Then
        switch result {
        case .success:
            XCTFail("Expected error for mailto scheme")
        case .failure(let error):
            XCTAssertEqual(error, .invalidScheme)
        }
    }

    // MARK: - Edge Cases

    func testMultipleMessageIdParametersUsesFirst() throws {
        // Given: URL with multiple messageid parameters
        let airmailURL = URL(string: "airmail://message?messageid=FIRST&messageid=SECOND&messageid=THIRD")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL)

        // Then: Should use the first messageid value
        let hookURL = try result.get()
        XCTAssertEqual(hookURL.absoluteString, "hook://email/FIRST")
    }

    func testVeryLongMessageIdValueSucceeds() throws {
        // Given: Very long messageid (simulating real Exchange/Outlook message IDs)
        let longMessageId = String(repeating: "A", count: 500)
        let airmailURL = URL(string: "airmail://message?messageid=\(longMessageId)")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL)

        // Then
        let hookURL = try result.get()
        XCTAssertEqual(hookURL.absoluteString, "hook://email/\(longMessageId)")
    }

    func testMessageIdWithSpecialCharactersHandledCorrectly() throws {
        // Given: messageid with various special characters that are URL-safe
        let messageId = "MSG-123_456.789~test"
        let airmailURL = URL(string: "airmail://message?messageid=\(messageId)")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL)

        // Then
        let hookURL = try result.get()
        XCTAssertEqual(hookURL.absoluteString, "hook://email/\(messageId)")
    }

    func testURLEncodedSpecialCharactersPreserved() throws {
        // Given: messageid with URL-encoded special characters
        // %40 = @, %2F = /, %3D = =, %2B = +
        let encodedMessageId = "user%40domain%2Fpath%3Dvalue%2B1"
        let airmailURL = URL(string: "airmail://message?messageid=\(encodedMessageId)")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL)

        // Then: Encoding should be preserved
        let hookURL = try result.get()
        XCTAssertEqual(hookURL.absoluteString, "hook://email/\(encodedMessageId)")
    }

    func testMessageIdWithSpacesEncodedAsPlus() throws {
        // Given: messageid where spaces are encoded as + (form encoding)
        // Note: URLComponents typically uses %20 for spaces, but + is also valid
        let airmailURL = URL(string: "airmail://message?messageid=hello+world")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL)

        // Then: The + should be preserved or converted appropriately
        let hookURL = try result.get()
        // The exact handling depends on implementation; either preserve or decode
        XCTAssertTrue(
            hookURL.absoluteString == "hook://email/hello+world" ||
            hookURL.absoluteString == "hook://email/hello%20world" ||
            hookURL.absoluteString == "hook://email/hello%2Bworld" ||
            hookURL.absoluteString == "hook://email/hello world",
            "Expected + to be handled appropriately, got: \(hookURL.absoluteString)"
        )
    }

    func testMessageIdWithPercentEncodedPercent() throws {
        // Given: messageid containing %25 (a literal percent sign)
        let airmailURL = URL(string: "airmail://message?messageid=100%25complete")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL)

        // Then
        let hookURL = try result.get()
        XCTAssertEqual(hookURL.absoluteString, "hook://email/100%25complete")
    }

    func testCaseInsensitiveParameterNameHandling() {
        // Given: messageid parameter with different casing
        // Note: URL query parameter names are typically case-sensitive per RFC 3986
        // This test documents expected behavior
        let airmailURL = URL(string: "airmail://message?MESSAGEID=UPPER123")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL)

        // Then: Case-sensitive (standard behavior), this should fail
        switch result {
        case .success:
            XCTFail("Expected failure for uppercase MESSAGEID (case-sensitive)")
        case .failure(let error):
            XCTAssertEqual(error, .missingMessageId)
        }
    }

    func testWhitespaceOnlyMessageIdSucceeds() throws {
        // Given: messageid with only whitespace (URL-encoded)
        // Note: Whitespace is technically valid content for a messageid
        let airmailURL = URL(string: "airmail://message?messageid=%20%20%20")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL)

        // Then: Should succeed since there is content (whitespace)
        let hookURL = try result.get()
        XCTAssertTrue(hookURL.absoluteString.contains("hook://email/"))
    }

    func testAirmailSchemeWithDifferentHost() throws {
        // Given: airmail URL with different host path
        let airmailURL = URL(string: "airmail://otherthing?messageid=MSG123")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL)

        // Then: Should still work as long as messageid is present
        let hookURL = try result.get()
        XCTAssertEqual(hookURL.absoluteString, "hook://email/MSG123")
    }

    func testAirmailSchemeWithNoHost() throws {
        // Given: airmail URL with empty host
        let airmailURL = URL(string: "airmail://?messageid=MSG123")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL)

        // Then: Should still work as long as messageid is present
        let hookURL = try result.get()
        XCTAssertEqual(hookURL.absoluteString, "hook://email/MSG123")
    }

    // MARK: - Output URL Format Verification

    func testOutputURLHasCorrectScheme() throws {
        // Given
        let airmailURL = URL(string: "airmail://message?messageid=TEST")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL)

        // Then
        let hookURL = try result.get()
        XCTAssertEqual(hookURL.scheme, "hook")
    }

    func testOutputURLHasCorrectHost() throws {
        // Given
        let airmailURL = URL(string: "airmail://message?messageid=TEST")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL)

        // Then
        let hookURL = try result.get()
        XCTAssertEqual(hookURL.host, "email")
    }

    func testOutputURLHasMessageIdAsPath() throws {
        // Given
        let messageId = "TESTMSGID123"
        let airmailURL = URL(string: "airmail://message?messageid=\(messageId)")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL)

        // Then
        let hookURL = try result.get()
        XCTAssertEqual(hookURL.path, "/\(messageId)")
    }

    // MARK: - Apple Mail Scheme Tests

    func testAppleMailSchemeReturnsCorrectMessageURL() throws {
        // Given
        let airmailURL = URL(string: "airmail://message?messageid=ABC123")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL, scheme: .applemail)

        // Then
        let messageURL = try result.get()
        XCTAssertEqual(messageURL.absoluteString, "message://%3CABC123%3E")
    }

    func testAppleMailSchemeWithEncodedCharacters() throws {
        // Given: messageid contains URL-encoded characters
        let encodedMessageId = "AAMk%2BXYZ%3D%3D"
        let airmailURL = URL(string: "airmail://message?messageid=\(encodedMessageId)")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL, scheme: .applemail)

        // Then: The encoding should be preserved, wrapped in angle brackets
        let messageURL = try result.get()
        XCTAssertEqual(messageURL.absoluteString, "message://%3C\(encodedMessageId)%3E")
    }

    func testAppleMailSchemeWithMailParameter() throws {
        // Given: URL contains both mail and messageid parameters
        let airmailURL = URL(string: "airmail://message?mail=user%40example.com&messageid=MSG456")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL, scheme: .applemail)

        // Then: mail parameter is ignored, messageid is used
        let messageURL = try result.get()
        XCTAssertEqual(messageURL.absoluteString, "message://%3CMSG456%3E")
    }

    func testAppleMailSchemeRealWorldExample() throws {
        // Given: Real-world example from CLAUDE.md
        let messageId = "AAMkADg1ZGM0ZGE3LWMxZDctNDBhOC04OWNhLTZhM2VlNjNhYzIxNQBGAAAAAADtYuK5T8IaS7TB7_AKKA9FBwBcJ6m9i2jPSbO7OUxjrFzMAAAAAAEMAABcJ6m9i2jPSbO7OUxjrFzMAAFRe7JEAAA%3D"
        let airmailURL = URL(string: "airmail://message?mail=joe%40user.com&messageid=\(messageId)")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL, scheme: .applemail)

        // Then
        let messageURL = try result.get()
        XCTAssertEqual(messageURL.absoluteString, "message://%3C\(messageId)%3E")
    }

    func testAppleMailSchemeOutputHasCorrectScheme() throws {
        // Given
        let airmailURL = URL(string: "airmail://message?messageid=TEST")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL, scheme: .applemail)

        // Then
        let messageURL = try result.get()
        XCTAssertEqual(messageURL.scheme, "message")
    }

    func testAppleMailSchemeMissingMessageIdReturnsError() {
        // Given: URL without messageid parameter
        let airmailURL = URL(string: "airmail://message?mail=user%40example.com")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL, scheme: .applemail)

        // Then
        switch result {
        case .success:
            XCTFail("Expected error for missing messageid parameter")
        case .failure(let error):
            XCTAssertEqual(error, .missingMessageId)
        }
    }

    // MARK: - Explicit Hookmark Scheme Tests

    func testExplicitHookmarkSchemeReturnsCorrectURL() throws {
        // Given
        let airmailURL = URL(string: "airmail://message?messageid=ABC123")!

        // When
        let result = URLTransformer.transform(airmailURL: airmailURL, scheme: .hookmark)

        // Then
        let hookURL = try result.get()
        XCTAssertEqual(hookURL.absoluteString, "hook://email/ABC123")
    }

    func testDefaultSchemeMatchesExplicitHookmark() throws {
        // Given
        let airmailURL = URL(string: "airmail://message?messageid=ABC123")!

        // When
        let defaultResult = URLTransformer.transform(airmailURL: airmailURL)
        let explicitResult = URLTransformer.transform(airmailURL: airmailURL, scheme: .hookmark)

        // Then
        let defaultURL = try defaultResult.get()
        let explicitURL = try explicitResult.get()
        XCTAssertEqual(defaultURL.absoluteString, explicitURL.absoluteString)
    }
}
