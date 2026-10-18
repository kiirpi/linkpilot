import SwiftUI
import AppKit

@main
struct ChooseBrowserApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Ana menü - sadece Quit için
        MenuBarExtra("ChooseBrowser", systemImage: "arrow.triangle.branch") {
            MenuBarView()
                .environmentObject(appDelegate.ruleManager)
        }
        .menuBarExtraStyle(.window)
        
        // Settings window - menubar'dan açılır
        Window("ChooseBrowser Settings", id: "settings") {
            SettingsView()
                .environmentObject(appDelegate.ruleManager)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 500, height: 400)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    let ruleManager = RuleManager()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Register as URL scheme handler
        let eventManager = NSAppleEventManager.shared()
        eventManager.setEventHandler(
            self,
            andSelector: #selector(handleURLEvent(_:withReply:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
        
        // Activate app so it shows in System Preferences > Default Browser
        NSApp.activate(ignoringOtherApps: true)
        
        // Register with LaunchServices as HTTP/HTTPS handler
        registerAsBrowser()
        
        ruleManager.showNotification(title: "ChooseBrowser Active", message: "URL routing is now active. Add rules from the menu bar icon.")
    }
    
    func registerAsBrowser() {
        guard let bundleId = Bundle.main.bundleIdentifier else { return }
        LSSetDefaultHandlerForURLScheme("http" as CFString, bundleId as CFString)
        LSSetDefaultHandlerForURLScheme("https" as CFString, bundleId as CFString)
        LSSetDefaultRoleHandlerForContentType("public.html" as CFString, .all, bundleId as CFString)
    }
    
    @objc func handleURLEvent(_ event: NSAppleEventDescriptor, withReply reply: NSAppleEventDescriptor) {
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
              let url = URL(string: urlString) else {
            NSLog("❌ ChooseBrowser: Invalid URL event")
            return
        }
        
        NSLog("✅ ChooseBrowser: Received URL: \(url)")
        ruleManager.handleURL(url)
    }
}
