import SwiftUI

// Inline editor for creating / editing a rule.
// Shown in-place inside RulesView (no sheets, no windows, no modals).
struct RuleEditorView: View {
    let isNew: Bool
    let browsers: [Browser]
    let onSave: (Rule) -> Void
    let onCancel: () -> Void

    @State private var editedRule: Rule

    init(rule: Rule, isNew: Bool, browsers: [Browser],
         onSave: @escaping (Rule) -> Void, onCancel: @escaping () -> Void) {
        self._editedRule = State(initialValue: rule)
        self.isNew = isNew
        self.browsers = browsers
        self.onSave = onSave
        self.onCancel = onCancel
    }

    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Button(action: onCancel) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
                Spacer()
                Text(isNew ? "New Rule" : "Edit Rule")
                    .font(.headline)
                Spacer()
                // Invisible spacer to balance the Back button
                Button("Back") {}
                    .hidden()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.bar)

            Divider()

            // Editor form
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // ── Rule Details ──
                    GroupBox("Rule Details") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Name")
                                .font(.subheadline.bold())
                            TextField("e.g. Work GitHub", text: $editedRule.name)
                                .textFieldStyle(.roundedBorder)

                            Text("Match Type")
                                .font(.subheadline.bold())
                            Picker("", selection: $editedRule.patternType) {
                                ForEach(PatternType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                            .labelsHidden()

                            Text("Pattern")
                                .font(.subheadline.bold())
                            TextField("e.g. github.com", text: $editedRule.pattern)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(.body, design: .monospaced))

                            Text(patternHint)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(8)
                    }

                    // ── Browser ──
                    GroupBox("Target Browser") {
                        VStack(alignment: .leading, spacing: 8) {
                            if browsers.isEmpty {
                                HStack {
                                    ProgressView().controlSize(.small)
                                    Text("Discovering browsers…").foregroundStyle(.secondary)
                                }
                                .padding(8)
                            } else {
                                browserGrid
                            }

                            // Profile field for Chromium browsers
                            if let browser = browsers.first(where: { $0.bundleID == editedRule.browserBundleID }),
                               browser.supportsProfiles {
                                Divider()
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Profile Directory (optional)")
                                        .font(.subheadline.bold())
                                    TextField(
                                        "e.g. Default, Profile 1",
                                        text: Binding(
                                            get: { editedRule.profileName ?? "" },
                                            set: { editedRule.profileName = $0.isEmpty ? nil : $0 }
                                        )
                                    )
                                    .textFieldStyle(.roundedBorder)
                                    Text("Find it at chrome://version → Profile Path.")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 8)
                                .padding(.bottom, 8)
                            }
                        }
                    }

                    // ── Enabled ──
                    GroupBox {
                        Toggle("Enable this rule", isOn: $editedRule.isEnabled)
                            .padding(4)
                    }
                }
                .padding(16)
            }

            Divider()

            // Action buttons
            HStack {
                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button(isNew ? "Add Rule" : "Save Changes") {
                    onSave(editedRule)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(editedRule.name.isEmpty || editedRule.pattern.isEmpty || editedRule.browserBundleID.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .onAppear {
            // Auto-select first browser for new rules
            if editedRule.browserBundleID.isEmpty, let first = browsers.first {
                editedRule.browserBundleID = first.bundleID
                editedRule.browserName = first.name
            }
        }
    }

    // MARK: - Browser grid

    private var browserGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 8)], spacing: 8) {
            ForEach(browsers) { browser in
                let isSelected = editedRule.browserBundleID == browser.bundleID
                Button {
                    editedRule.browserBundleID = browser.bundleID
                    editedRule.browserName = browser.name
                } label: {
                    HStack(spacing: 8) {
                        if let icon = browser.icon {
                            Image(nsImage: icon)
                                .resizable()
                                .frame(width: 24, height: 24)
                        } else {
                            Image(systemName: "globe")
                                .frame(width: 24, height: 24)
                        }
                        Text(browser.name)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .font(.callout)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
    }

    // MARK: - Hint text

    private var patternHint: String {
        switch editedRule.patternType {
        case .wildcard:
            return "Wildcards: * matches any sequence, ? matches one character.\nExamples: *.github.com/*, docs.google.com/document/*"
        case .regex:
            return "Standard regular expression (case-insensitive).\nExample: https://(www\\.)?notion\\.so/.*"
        case .contains:
            return "Matches any URL that contains this text (case-insensitive).\nExample: zoom.us/j/"
        }
    }
}

#Preview {
    RuleEditorView(
        rule: Rule(), isNew: true, browsers: [],
        onSave: { _ in }, onCancel: {}
    )
    .frame(width: 600, height: 500)
}
