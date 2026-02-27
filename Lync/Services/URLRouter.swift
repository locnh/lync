import AppKit
import Combine

// Central routing engine.  Holds the ordered rule list and dispatches incoming
// URLs to the appropriate browser.  Also acts as the single source of truth for
// persisted settings so SwiftUI views can observe it directly.
final class URLRouter: ObservableObject {
    static let shared = URLRouter()

    @Published var rules: [Rule] = []
    @Published var fallbackBrowserID: String = "com.apple.Safari"
    @Published var stripTrackingParams: Bool = true

    // UserDefaults keys
    private let rulesKey       = "com.lync.rules"
    private let fallbackKey    = "com.lync.fallbackBrowser"
    private let stripKey       = "com.lync.stripTracking"

    private init() {
        load()
    }

    // MARK: - Routing

    // Entry point called by AppDelegate for every intercepted URL open event
    func route(url: URL) {
        var target = url

        if stripTrackingParams {
            target = URLCleaner.shared.clean(url)
        }

        // Walk rules in priority order (top to bottom)
        for rule in rules where rule.isEnabled {
            if rule.matches(url: target) {
                open(url: target, browserBundleID: rule.browserBundleID, profileName: rule.profileName)
                return
            }
        }

        // No rule matched — use the global fallback browser
        open(url: target, browserBundleID: fallbackBrowserID, profileName: nil)
    }

    // Opens a URL in the specified browser, optionally with a Chromium profile
    private func open(url: URL, browserBundleID: String, profileName: String?) {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: browserBundleID) else {
            // Browser not found — fall back to system default
            NSWorkspace.shared.open(url)
            return
        }

        let config = NSWorkspace.OpenConfiguration()

        // Pass --profile-directory for Chromium-family browsers when a profile is specified.
        // Note: if the browser is already running, the existing instance will receive the argument
        // and switch to / create the matching profile window.
        if let profile = profileName, !profile.isEmpty {
            config.arguments = ["--profile-directory=\(profile)"]
        }

        NSWorkspace.shared.open([url], withApplicationAt: appURL, configuration: config) { _, error in
            if let error = error {
                print("[Lync] Failed to open URL \(url): \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Rule Management

    func addRule(_ rule: Rule) {
        rules.append(rule)
        save()
    }

    func updateRule(_ rule: Rule) {
        guard let index = rules.firstIndex(where: { $0.id == rule.id }) else { return }
        rules[index] = rule
        save()
    }

    func removeRules(at offsets: IndexSet) {
        rules.remove(atOffsets: offsets)
        save()
    }

    func moveRules(from source: IndexSet, to destination: Int) {
        rules.move(fromOffsets: source, toOffset: destination)
        save()
    }

    // MARK: - Persistence

    func save() {
        if let data = try? JSONEncoder().encode(rules) {
            UserDefaults.standard.set(data, forKey: rulesKey)
        }
        UserDefaults.standard.set(fallbackBrowserID, forKey: fallbackKey)
        UserDefaults.standard.set(stripTrackingParams, forKey: stripKey)
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: rulesKey),
           let decoded = try? JSONDecoder().decode([Rule].self, from: data) {
            rules = decoded
        }
        if let fallback = UserDefaults.standard.string(forKey: fallbackKey) {
            fallbackBrowserID = fallback
        }
        // Default stripTrackingParams to true on first launch
        if UserDefaults.standard.object(forKey: stripKey) != nil {
            stripTrackingParams = UserDefaults.standard.bool(forKey: stripKey)
        }
    }
}
