import SwiftUI
import UIKit

@main
struct Airmail2HookmarkiOSApp: App {
    @State private var errorMessage: String?
    @State private var showError = false

    var body: some Scene {
        WindowGroup {
            SettingsView()
                .onOpenURL { url in
                    handleIncomingURL(url)
                }
                .alert("Unable to Transform URL", isPresented: $showError) {
                    Button("OK") { }
                } message: {
                    Text(errorMessage ?? "Unknown error")
                }
        }
    }

    private func handleIncomingURL(_ url: URL) {
        let selectedScheme = PreferencesManager.shared.selectedScheme
        let result = URLTransformer.transform(airmailURL: url, scheme: selectedScheme)

        switch result {
        case .success(let outputURL):
            UIApplication.shared.open(outputURL) { success in
                if !success {
                    DispatchQueue.main.async {
                        errorMessage = "Could not open the URL. Is \(selectedScheme == .hookmark ? "Hookmark" : "Mail") installed?"
                        showError = true
                    }
                }
            }

        case .failure(let error):
            errorMessage = errorDescription(for: error, originalURL: url)
            showError = true
        }
    }

    private func errorDescription(for error: URLTransformError, originalURL: URL) -> String {
        switch error {
        case .invalidScheme:
            return "The URL does not use the airmail: scheme.\n\nReceived: \(originalURL.absoluteString)"
        case .missingMessageId:
            return "The airmail URL is missing the required 'messageid' parameter.\n\nReceived: \(originalURL.absoluteString)"
        case .emptyMessageId:
            return "The airmail URL has an empty 'messageid' parameter.\n\nReceived: \(originalURL.absoluteString)"
        case .invalidURLConstruction:
            return "Failed to construct the output URL.\n\nOriginal: \(originalURL.absoluteString)"
        }
    }
}
