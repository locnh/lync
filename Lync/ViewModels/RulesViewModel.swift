import Foundation
import Combine

// View-model used by rule management views.
// Keeps a live list of installed browsers and convenience helpers for the UI.
final class RulesViewModel: ObservableObject {
    @Published var browsers: [Browser] = []

    init() {
        refreshBrowsers()
    }

    func refreshBrowsers() {
        // Run discovery off the main thread to avoid blocking the UI
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let found = BrowserDiscovery.shared.discoverBrowsers()
            DispatchQueue.main.async {
                self?.browsers = found
            }
        }
    }

    // Returns the display name for a given bundle ID, falling back to the ID itself
    func browserName(for bundleID: String) -> String {
        browsers.first(where: { $0.bundleID == bundleID })?.name ?? bundleID
    }

    // Returns whether a browser (by bundle ID) supports Chromium profiles
    func supportsProfiles(bundleID: String) -> Bool {
        browsers.first(where: { $0.bundleID == bundleID })?.supportsProfiles ?? false
    }
}
