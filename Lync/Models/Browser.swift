import AppKit

// Represents an installed browser on the system
struct Browser: Identifiable, Hashable {
    let id: String        // Unique identifier — same as bundleID
    let name: String
    let bundleID: String

    // Chromium-family browsers support --profile-directory launch argument
    var supportsProfiles: Bool {
        let profileBrowsers: Set<String> = [
            "com.google.Chrome",
            "com.google.Chrome.beta",
            "com.google.Chrome.canary",
            "com.brave.Browser",
            "com.brave.Browser.beta",
            "com.brave.Browser.nightly",
            "com.microsoft.edgemac",
            "com.microsoft.edgemac.Beta",
            "com.microsoft.edgemac.Dev",
            "com.microsoft.edgemac.Canary",
            "com.vivaldi.Vivaldi",
            "com.operasoftware.Opera",
        ]
        return profileBrowsers.contains(bundleID)
    }

    // Retrieve the app icon for use in the UI
    var icon: NSImage? {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            return nil
        }
        return NSWorkspace.shared.icon(forFile: appURL.path)
    }
}
