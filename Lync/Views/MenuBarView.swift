import SwiftUI

// Content displayed inside the menu bar popover
struct MenuBarView: View {
    @ObservedObject private var router = URLRouter.shared
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: "link.circle.fill")
                    .foregroundStyle(.blue)
                Text("Lync")
                    .font(.headline)
                Spacer()
                // Status dot
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)
                    .help("Lync is active")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            Divider()

            // Quick stats
            VStack(alignment: .leading, spacing: 6) {
                statRow(
                    icon: "list.bullet",
                    label: "Active Rules",
                    value: "\(router.rules.filter { $0.isEnabled }.count) / \(router.rules.count)"
                )
                statRow(
                    icon: "globe",
                    label: "Fallback",
                    value: fallbackName
                )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            // Quick toggle for tracking parameter stripping
            Toggle(isOn: Binding(
                get: { router.stripTrackingParams },
                set: { router.stripTrackingParams = $0; router.save() }
            )) {
                Label("Strip Tracking Params", systemImage: "shield")
            }
            .toggleStyle(.checkbox)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            // Actions
            Button {
                openSettings()
                NSApp.activate(ignoringOtherApps: true)
            } label: {
                Label("Open Settings…", systemImage: "gear")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
            .hoverEffect()

            Button {
                NSApp.terminate(nil)
            } label: {
                Label("Quit Lync", systemImage: "power")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
            .hoverEffect()
        }
        .frame(width: 240)
        .padding(.vertical, 4)
    }

    private var fallbackName: String {
        // Quick lookup without a full BrowserDiscovery scan
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: router.fallbackBrowserID),
           let name = Bundle(url: appURL)?.infoDictionary?["CFBundleName"] as? String {
            return name
        }
        return router.fallbackBrowserID
    }

    private func statRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.primary)
        }
    }
}

// Simple hover-highlight effect for menu-like rows
private extension View {
    func hoverEffect() -> some View {
        self.modifier(HoverHighlightModifier())
    }
}

private struct HoverHighlightModifier: ViewModifier {
    @State private var isHovered = false

    func body(content: Content) -> some View {
        content
            .background(isHovered ? Color.accentColor.opacity(0.15) : Color.clear)
            .cornerRadius(6)
            .onHover { isHovered = $0 }
    }
}

#Preview {
    MenuBarView()
}
