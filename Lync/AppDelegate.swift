import Cocoa

// kInternetEventClass / kAEGetURL raw values — avoids importing the Carbon framework
private let kInternetEventClassValue: AEEventClass = 0x4755524C  // 'GURL'
private let kAEGetURLValue:           AEEventID    = 0x4755524C  // 'GURL'
private let keyDirectObjectValue:     AEKeyword    = 0x2D2D2D2D  // '----'

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide from the Dock — Lync lives in the menu bar only
        NSApp.setActivationPolicy(.accessory)

        // Register to receive the "open URL" Apple Event that macOS sends to
        // whichever app is currently set as the Default Web Browser
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleGetURLEvent(_:withReplyEvent:)),
            forEventClass: kInternetEventClassValue,
            andEventID: kAEGetURLValue
        )

        // Show the settings / onboarding window automatically on first launch
        let hasLaunched = UserDefaults.standard.bool(forKey: "com.lync.hasLaunchedBefore")
        if !hasLaunched {
            UserDefaults.standard.set(true, forKey: "com.lync.hasLaunchedBefore")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }

    // Called by macOS when a Handoff activity from another device arrives
    func application(
        _ application: NSApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([any NSUserActivityRestoring]) -> Void
    ) -> Bool {
        guard
            userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL
        else {
            return false
        }

        URLRouter.shared.route(url: url)
        return true
    }

    // Called by macOS for every http/https link clicked in other applications
    @objc func handleGetURLEvent(
        _ event: NSAppleEventDescriptor,
        withReplyEvent replyEvent: NSAppleEventDescriptor
    ) {
        guard
            let urlString = event.paramDescriptor(forKeyword: keyDirectObjectValue)?.stringValue,
            let url = URL(string: urlString)
        else {
            return
        }

        URLRouter.shared.route(url: url)
    }
}
