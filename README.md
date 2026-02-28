# Lync

A lightweight macOS menu bar utility that intercepts every link you click and routes it to the right browser — or the right browser profile — based on rules you define.

Inspired by [Velja](https://sindresorhus.com/velja).

![macOS](https://img.shields.io/badge/macOS-14.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.10-orange)
![License](https://img.shields.io/badge/license-MIT-green)
![Version](https://img.shields.io/badge/version-1.0.0-purple)

---

## Features

- **Universal Link Routing** — registers as your Default Web Browser and intercepts all `http`/`https` clicks system-wide
- **Three match modes** — Wildcard (`*.zoom.us/*`), Regex, or Contains
- **Browser Profile Support** — route URLs to a specific Chromium profile (Chrome, Brave, Edge, Vivaldi) via `--profile-directory`
- **Privacy Shield** — strips `utm_*`, `fbclid`, `gclid`, and 25+ other tracking parameters before opening
- **Global Fallback** — choose which browser handles URLs that match no rule
- **Drag-to-reorder rules** — priority is evaluated top to bottom; first match wins
- **macOS Handoff** — URLs handed off from iPhone/iPad pass through the same routing engine
- **Menu bar only** — no Dock icon, lives quietly in your menu bar

---

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 14.0 or later

---

## Getting Started

### 1. Clone and open

```bash
git clone https://github.com/locnh/lync.git
cd Lync
open Lync.xcodeproj
```

### 2. Build & Run

Press `Cmd+R` in Xcode, or from the terminal:

```bash
xcodebuild -project Lync.xcodeproj -scheme Lync -configuration Debug build
open ~/Library/Developer/Xcode/DerivedData/Lync-*/Build/Products/Debug/Lync.app
```

### 3. Set as Default Browser

Go to **System Settings → Desktop & Dock → Default web browser → Lync**.

---

## Project Structure

```
Lync/
├── Lync.xcodeproj/
└── Lync/
    ├── LyncApp.swift           # @main — MenuBarExtra + Settings scenes
    ├── AppDelegate.swift       # Apple Event handler (kAEGetURL interception)
    ├── Info.plist              # CFBundleURLTypes for http/https, LSUIElement
    ├── Lync.entitlements       # App Sandbox disabled
    ├── Assets.xcassets/
    ├── Models/
    │   ├── Rule.swift          # Routing rule model (Codable)
    │   └── Browser.swift       # Installed browser model
    ├── Services/
    │   ├── URLRouter.swift         # Core routing engine + UserDefaults persistence
    │   ├── BrowserDiscovery.swift  # Finds browsers via NSWorkspace
    │   └── URLCleaner.swift        # Strips tracking query parameters
    ├── ViewModels/
    │   └── RulesViewModel.swift
    └── Views/
        ├── MenuBarView.swift       # Popover with stats & quick toggles
        ├── SettingsView.swift      # Tabbed settings window (Rules, General, Setup Guide, About)
        ├── RulesView.swift         # Rule list with reorder & delete
        ├── RuleEditorView.swift    # Inline add / edit rule editor
        └── OnboardingView.swift    # First-launch setup guide
```

---

## How Routing Works

1. You click any link in any app on your Mac
2. macOS sends a `kAEGetURL` Apple Event to Lync (the registered default browser)
3. Lync optionally strips tracking parameters
4. Rules are evaluated **top to bottom** — the first matching rule wins
5. The URL is opened in the rule's target browser (and profile, if specified)
6. If no rule matches, the **fallback browser** opens the URL

---

## Adding Rules

| Field          | Description                                                   |
| -------------- | ------------------------------------------------------------- |
| **Name**       | Human-readable label for the rule                             |
| **Match Type** | Wildcard, Regex, or Contains                                  |
| **Pattern**    | The URL pattern to match against                              |
| **Browser**    | Target browser (auto-discovered from your system)             |
| **Profile**    | Chromium profile directory name (e.g. `Default`, `Profile 1`) |

### Pattern examples

| Type     | Pattern                         | Matches            |
| -------- | ------------------------------- | ------------------ |
| Wildcard | `*.github.com/*`                | Any GitHub URL     |
| Wildcard | `meet.google.com/*`             | Google Meet links  |
| Regex    | `https://(www\.)?notion\.so/.*` | Notion pages       |
| Contains | `zoom.us/j/`                    | Zoom meeting links |

---

## Browser Profile Support

For Chromium-based browsers (Chrome, Brave, Edge, Vivaldi), you can route URLs to a specific profile by entering the **profile directory name** — not the display name.

To find your profile directory name:
1. Open Chrome and go to `chrome://version`
2. Look at **Profile Path** — the last folder segment is the directory name (e.g. `Default`, `Profile 1`, `Work`)

---

## Privacy Shield

When enabled, Lync removes the following parameter families from every URL before opening it:

- **UTM** — `utm_source`, `utm_medium`, `utm_campaign`, `utm_content`, `utm_term`, …
- **Facebook** — `fbclid`, `fb_ref`, `fb_source`, …
- **Google Ads** — `gclid`, `gclsrc`, `gbraid`, `wbraid`, `dclid`
- **Microsoft Ads** — `msclkid`
- **HubSpot** — `hsa_*`
- **Mailchimp** — `mc_cid`, `mc_eid`
- **TikTok / Pinterest / Twitter** — `ttclid`, `epik`, `twclid`
- And more…

---

## Architecture

Lync follows **MVVM**:

| Layer          | Responsibility                                                 |
| -------------- | -------------------------------------------------------------- |
| **Models**     | `Rule`, `Browser` — pure data, `Codable`                       |
| **Services**   | `URLRouter`, `BrowserDiscovery`, `URLCleaner` — business logic |
| **ViewModels** | `RulesViewModel` — bridges services to views                   |
| **Views**      | SwiftUI views — purely declarative, no logic                   |

State is held in `URLRouter.shared` (an `ObservableObject` singleton) and persisted to `UserDefaults` as JSON.

---

## Credits

* Prompt: Gemini
* Icon design: Grok
* Code and document: Claude Sonnet
* Publisher: locnh

---

## License

[MIT](LICENSE) © 2026 locnh
