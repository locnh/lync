import AppKit
import CoreServices

// Discovers all browsers installed on the system using LaunchServices
final class BrowserDiscovery {
    static let shared = BrowserDiscovery()
    private init() {}

    // Returns a deduplicated, alphabetically sorted list of installed browsers
    func discoverBrowsers() -> [Browser] {
        var bundleIDs = Set<String>()

        // Ask LaunchServices for every registered handler of http and https
        for scheme in ["http", "https"] {
            if let cfArray = LSCopyAllHandlersForURLScheme(scheme as CFString) {
                let handlers = cfArray.takeRetainedValue() as? [String] ?? []
                bundleIDs.formUnion(handlers)
            }
        }

        // Seed with known browsers in case they are installed but not yet registered
        let knownBundleIDs: Set<String> = [
            "com.apple.Safari",
            "com.google.Chrome",
            "com.google.Chrome.beta",
            "org.mozilla.firefox",
            "org.mozilla.firefoxdeveloperedition",
            "com.microsoft.edgemac",
            "com.brave.Browser",
            "com.operasoftware.Opera",
            "com.vivaldi.Vivaldi",
            "company.thebrowser.Browser",  // Arc
        ]
        bundleIDs.formUnion(knownBundleIDs)

        var browsers: [Browser] = []
        for bundleID in bundleIDs {
            // Only include apps that are actually installed
            guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
                continue
            }
            let bundle = Bundle(url: appURL)
            let displayName = bundle?.infoDictionary?["CFBundleDisplayName"] as? String
                ?? bundle?.infoDictionary?["CFBundleName"] as? String
                ?? bundleID
            browsers.append(Browser(id: bundleID, name: displayName, bundleID: bundleID))
        }

        return browsers.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
