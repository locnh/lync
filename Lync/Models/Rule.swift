import Foundation

// Supported pattern matching strategies for routing rules
enum PatternType: String, Codable, CaseIterable {
    case wildcard = "Wildcard"
    case regex    = "Regex"
    case contains = "Contains"
}

// A single routing rule that maps a URL pattern to a target browser (and optional profile)
struct Rule: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var pattern: String
    var patternType: PatternType
    // Bundle ID of the browser that should open matching URLs
    var browserBundleID: String
    // Human-readable browser name cached for display (avoids live lookups)
    var browserName: String
    // Optional Chromium profile directory name (e.g. "Default", "Profile 1", "Work")
    var profileName: String?
    var isEnabled: Bool

    init(
        id: UUID = UUID(),
        name: String = "",
        pattern: String = "",
        patternType: PatternType = .wildcard,
        browserBundleID: String = "",
        browserName: String = "",
        profileName: String? = nil,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.pattern = pattern
        self.patternType = patternType
        self.browserBundleID = browserBundleID
        self.browserName = browserName
        self.profileName = profileName
        self.isEnabled = isEnabled
    }

    // Returns true when this rule's pattern matches the given URL
    func matches(url: URL) -> Bool {
        guard isEnabled else { return false }
        let urlString = url.absoluteString
        switch patternType {
        case .wildcard: return matchesWildcard(urlString)
        case .regex:    return matchesRegex(urlString)
        case .contains: return urlString.localizedCaseInsensitiveContains(pattern)
        }
    }

    // Converts a glob wildcard pattern (*,?) into a regular expression
    private func matchesWildcard(_ string: String) -> Bool {
        let escaped = NSRegularExpression.escapedPattern(for: pattern)
            .replacingOccurrences(of: "\\*", with: ".*")
            .replacingOccurrences(of: "\\?", with: ".")
        let regexPattern = "^" + escaped + "$"
        return (try? NSRegularExpression(pattern: regexPattern, options: .caseInsensitive))
            .map { $0.firstMatch(in: string, range: NSRange(string.startIndex..., in: string)) != nil }
            ?? false
    }

    private func matchesRegex(_ string: String) -> Bool {
        return (try? NSRegularExpression(pattern: pattern, options: .caseInsensitive))
            .map { $0.firstMatch(in: string, range: NSRange(string.startIndex..., in: string)) != nil }
            ?? false
    }
}
