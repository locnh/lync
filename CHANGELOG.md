# Changelog

All notable changes to Lync will be documented in this file.

## [1.0.0] - 2026-02-28

### Initial Release

#### Core Features
- **Universal Link Router** — intercepts every `http`/`https` click system-wide and routes it to a specific browser or browser profile based on user-defined rules
- **Rule Engine** — ordered rule list evaluated top-to-bottom; first match wins. Supports three match types:
  - **Contains** — matches any URL containing the given text (case-insensitive)
  - **Wildcard** — `*` matches any sequence, `?` matches one character
  - **Regex** — full regular expression support (case-insensitive)
- **Browser Discovery** — automatically detects all installed browsers via `NSWorkspace`
- **Chromium Profile Routing** — route URLs to a specific Chrome, Brave, or Edge profile using `--profile-directory`
- **Fallback Browser** — configurable default browser used when no rule matches
- **Tracking Parameter Stripping** — removes 25+ tracking params (`utm_*`, `fbclid`, `gclid`, etc.) before opening URLs
- **Rule Management** — add, edit, delete, reorder rules via an inline editor in Settings
- **macOS Handoff** — URLs handed off from iPhone/iPad pass through the routing engine

#### App
- Runs as a menu-bar utility (`LSUIElement`) — no Dock icon
- Registered as a Default Web Browser (`LSHandlerRank = Owner`) — appears in System Settings → Desktop & Dock → Default web browser
- Menu bar icon with Dark Mode support via template image rendering
- First-launch onboarding opens Settings automatically
- App Sandbox disabled to allow browser launching and Apple Event reception

#### Technical
- Built with SwiftUI + AppKit on macOS 14.0+
- URL interception via `NSAppleEventManager` (`kInternetEventClass` / `kAEGetURL`)
- Rule persistence via `UserDefaults` (JSON-encoded)
- Bundle ID: `com.locnh.lync.app`
