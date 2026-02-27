import SwiftUI

@main
struct LyncApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // SF Symbol renders as a template image automatically — adapts to
        // dark/light menu bar and any tinted bar colour macOS applies.
        MenuBarExtra {
            MenuBarView()
        } label: {
            Image(systemName: "link")
                    .imageScale(.large)
                    .symbolRenderingMode(.hierarchical)
        }
        .menuBarExtraStyle(.window)

        // Settings window — Cmd+, or "Open Settings…" from the popover
        Settings {
            SettingsView()
        }
    }
}
