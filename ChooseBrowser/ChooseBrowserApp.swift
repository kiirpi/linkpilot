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
        
        // Register for document open events (file:// URLs, HTML files from Finder)
        eventManager.setEventHandler(
            self,
            andSelector: #selector(handleOpenDocumentsEvent(_:withReply:)),
            forEventClass: AEEventClass(kCoreEventClass),
            andEventID: AEEventID(kAEOpenDocuments)
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
    
    @objc func handleOpenDocumentsEvent(_ event: NSAppleEventDescriptor, withReply reply: NSAppleEventDescriptor) {
        // kAEOpenDocuments event contains a list of file URLs
        guard let fileList = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject)) else {
            NSLog("❌ ChooseBrowser: No files in open documents event")
            return
        }
        
        // Handle single file or list of files
        if fileList.descriptorType == AEEventID(typeUTF8Text) || fileList.descriptorType == AEEventID(typeFileURL) {
            if let urlString = fileList.stringValue, let url = URL(string: urlString) {
                NSLog("📂 ChooseBrowser: Received file: \(url.path)")
                ruleManager.handleURL(url)
            }
        } else if fileList.descriptorType == AEEventID(typeAEList) {
            for i in 1...Int(fileList.numberOfItems) {
                if let item = itemDescriptor(in: fileList, at: i),
                   let urlString = item.stringValue,
                   let url = URL(string: urlString) {
                    NSLog("📂 ChooseBrowser: Received file: \(url.path)")
                    ruleManager.handleURL(url)
                }
            }
        }
    }
    
    private func itemDescriptor(in list: NSAppleEventDescriptor, at index: Int) -> NSAppleEventDescriptor? {
        return list.atIndex(index)
    }
    
    // Document open handler — Finder'dan veya `open file.html` ile açılan dosyalar
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        let url = URL(fileURLWithPath: filename)
        NSLog("📂 ChooseBrowser: Received file (delegate): \(url.path)")
        ruleManager.handleURL(url)
        return true
    }
    
    // Birden fazla dosya açma desteği
    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        for filename in filenames {
            let url = URL(fileURLWithPath: filename)
            NSLog("📂 ChooseBrowser: Received file (delegate): \(url.path)")
            ruleManager.handleURL(url)
        }
    }
}
