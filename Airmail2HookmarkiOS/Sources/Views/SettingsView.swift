import SwiftUI

struct SettingsView: View {
    @State private var selectedScheme: URIScheme = PreferencesManager.shared.selectedScheme

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Output URL Scheme", selection: $selectedScheme) {
                        ForEach(URIScheme.allCases, id: \.self) { scheme in
                            Text(scheme.displayName).tag(scheme)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                    .onChange(of: selectedScheme) { newValue in
                        PreferencesManager.shared.selectedScheme = newValue
                    }
                } header: {
                    Text("Output URL Scheme")
                } footer: {
                    Text("Choose which app should open when you tap an Airmail link.")
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundColor(.secondary)
                    }

                    Text("Airmail2Hookmark redirects airmail:// URLs to your preferred email linking app, preserving your existing deep links after migrating away from Airmail.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Airmail2Hookmark")
        }
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif
