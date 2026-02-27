import SwiftUI

// Displays the ordered list of routing rules with add / edit / delete / reorder support.
// Uses inline editing (swaps list ↔ editor) to avoid broken .sheet / .toolbar / NSApp.runModal
// inside Settings > TabView on macOS.
struct RulesView: View {
    @ObservedObject private var router = URLRouter.shared
    @StateObject private var vm = RulesViewModel()

    @State private var editingRule: Rule?
    @State private var isNewRule = false

    var body: some View {
        Group {
            if let rule = editingRule {
                RuleEditorView(
                    rule: rule,
                    isNew: isNewRule,
                    browsers: vm.browsers,
                    onSave: { saved in
                        if isNewRule {
                            router.addRule(saved)
                        } else {
                            router.updateRule(saved)
                        }
                        editingRule = nil
                    },
                    onCancel: {
                        editingRule = nil
                    }
                )
            } else {
                ruleListView
            }
        }
        .onAppear { vm.refreshBrowsers() }
    }

    // MARK: - Rule list

    private var ruleListView: some View {
        VStack(spacing: 0) {
            // Header bar
            HStack {
                Text("\(router.rules.count) rule\(router.rules.count == 1 ? "" : "s")")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                Spacer()
                Button {
                    vm.refreshBrowsers()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .help("Re-scan for installed browsers")

                Button {
                    editingRule = Rule()
                    isNewRule = true
                } label: {
                    Label("Add Rule", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.bar)

            Divider()

            if router.rules.isEmpty {
                emptyState
            } else {
                ruleList
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("No Rules Yet")
                .font(.title2.bold())
            Text("Add a rule to route specific URLs to a particular browser.\nRules are evaluated from top to bottom — the first match wins.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)
            Button("Add First Rule") {
                editingRule = Rule()
                isNewRule = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var ruleList: some View {
        List {
            ForEach(router.rules) { rule in
                RuleRowView(rule: rule, onEdit: {
                    editingRule = rule
                    isNewRule = false
                }, onDelete: {
                    if let idx = router.rules.firstIndex(where: { $0.id == rule.id }) {
                        router.removeRules(at: IndexSet(integer: idx))
                    }
                })
            }
            .onDelete { router.removeRules(at: $0) }
            .onMove  { router.moveRules(from: $0, to: $1) }
        }
        .listStyle(.inset)
    }
}

// MARK: - Rule Row

private struct RuleRowView: View {
    let rule: Rule
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var showDeleteConfirm = false

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(rule.isEnabled ? Color.green : Color.gray.opacity(0.5))
                .frame(width: 9, height: 9)

            VStack(alignment: .leading, spacing: 3) {
                Text(rule.name)
                    .font(.headline)

                HStack(spacing: 6) {
                    Label(rule.patternType.rawValue, systemImage: patternIcon)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(rule.pattern)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }

                HStack(spacing: 4) {
                    Image(systemName: "arrow.right")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(rule.browserName.isEmpty ? rule.browserBundleID : rule.browserName)
                        .font(.caption)
                        .foregroundStyle(.blue)
                    if let profile = rule.profileName {
                        Text("(\(profile))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Button("Edit") { onEdit() }
                .buttonStyle(.bordered)
                .controlSize(.small)

            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .alert("Delete Rule", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) { onDelete() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Delete \"\(rule.name)\"? This cannot be undone.")
            }
        }
        .padding(.vertical, 4)
        .opacity(rule.isEnabled ? 1 : 0.55)
    }

    private var patternIcon: String {
        switch rule.patternType {
        case .wildcard: return "asterisk"
        case .regex:    return "chevron.left.forwardslash.chevron.right"
        case .contains: return "text.magnifyingglass"
        }
    }
}

#Preview {
    RulesView()
        .frame(width: 600, height: 400)
}
