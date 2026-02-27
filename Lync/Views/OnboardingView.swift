import SwiftUI

// Shown on first launch to walk the user through making Lync their default browser
struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        VStack(spacing: 28) {
            // App icon / branding
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 80, height: 80)
                Image(systemName: "link")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 8) {
                Text("Welcome to Lync")
                    .font(.largeTitle).bold()
                Text("Route every link to exactly the right browser.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            GroupBox {
                VStack(alignment: .leading, spacing: 16) {
                    SetupStep(
                        number: 1,
                        title: "Set Lync as Default Browser",
                        description: "Open System Settings → Desktop & Dock → Default web browser → choose Lync."
                    )
                    Divider()
                    SetupStep(
                        number: 2,
                        title: "Add Routing Rules",
                        description: "Switch to the Rules tab and add patterns that direct specific URLs to specific browsers."
                    )
                    Divider()
                    SetupStep(
                        number: 3,
                        title: "Choose a Fallback Browser",
                        description: "In General settings, pick the browser Lync should use when no rule matches."
                    )
                }
                .padding(8)
            }
            .frame(maxWidth: 420)

            HStack(spacing: 12) {
                Button("Open System Settings") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.general") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.bordered)

                Button("Get Started") {
                    hasCompletedOnboarding = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(40)
        .frame(width: 520)
    }
}

// A single numbered step in the onboarding checklist
private struct SetupStep: View {
    let number: Int
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 26, height: 26)
                Text("\(number)")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
