import SwiftUI

// Main settings window — tabbed interface for Rules, General, Setup Guide, About
struct SettingsView: View {
    var body: some View {
        TabView {
            RulesView()
                .tabItem { Label("Rules", systemImage: "list.bullet") }

            GeneralSettingsView()
                .tabItem { Label("General", systemImage: "gear") }

            OnboardingView()
                .tabItem { Label("Setup Guide", systemImage: "questionmark.circle") }

            AboutView()
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(width: 640, height: 520)
    }
}

// MARK: - General Settings Tab

private struct GeneralSettingsView: View {
    @ObservedObject private var router = URLRouter.shared
    @StateObject private var vm = RulesViewModel()

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    if vm.browsers.isEmpty {
                        HStack {
                            ProgressView().controlSize(.small)
                            Text("Discovering browsers…").foregroundStyle(.secondary)
                        }
                    } else {
                        Picker("Default Browser", selection: $router.fallbackBrowserID) {
                            ForEach(vm.browsers) { browser in
                                HStack(spacing: 6) {
                                    if let icon = browser.icon {
                                        Image(nsImage: icon)
                                            .resizable()
                                            .frame(width: 16, height: 16)
                                    }
                                    Text(browser.name)
                                }
                                .tag(browser.bundleID)
                            }
                        }
                        .onChange(of: router.fallbackBrowserID) { _, _ in router.save() }
                    }

                    Text("Lync opens URLs in this browser when no routing rule matches.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Fallback Browser")
            }

            Section {
                Toggle("Strip Tracking Parameters", isOn: $router.stripTrackingParams)
                    .onChange(of: router.stripTrackingParams) { _, _ in router.save() }

                Text("Removes utm_*, fbclid, gclid, and other analytics tokens from URLs before opening them.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Privacy")
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { vm.refreshBrowsers() }
    }
}

// MARK: - About Tab

private struct AboutView: View {
    private let repoURL = URL(string: "https://github.com/locnh/lync")!

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // App icon + name
            VStack(spacing: 12) {
                if let icon = NSApp.applicationIconImage {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 80, height: 80)
                }

                Text("Lync")
                    .font(.largeTitle.bold())

                Text("Universal Link Router")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Version info
            VStack(spacing: 6) {
                Text("Version \(appVersion) (Build \(buildNumber))")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Text("Requires macOS 14.0 or later")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Divider()
                .frame(maxWidth: 320)

            // Description
            Text("Lync intercepts every http/https link you click and routes it to the right browser or profile — automatically, based on rules you define.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 400)

            // Links
            HStack(spacing: 20) {
                Link(destination: repoURL) {
                    Label("GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                }

                Link(destination: repoURL.appendingPathComponent("issues")) {
                    Label("Report an Issue", systemImage: "exclamationmark.bubble")
                }

                Link(destination: repoURL.appendingPathComponent("releases")) {
                    Label("Releases", systemImage: "tag")
                }
            }
            .font(.callout)

            Spacer()

            // Copyright
            Text("MIT License · \(copyrightYear) locnh")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }

    private var copyrightYear: String {
        let year = Calendar.current.component(.year, from: Date())
        return String(year)
    }
}

#Preview {
    SettingsView()
}
