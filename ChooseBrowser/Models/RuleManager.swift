import Foundation
import SwiftUI
import AppKit

class RuleManager: ObservableObject {
    @Published var rules: [BrowserRule] = []
    @Published var defaultBrowser: Browser = .safari {
        didSet {
            saveDefaultBrowser()
        }
    }
    
    // Persistent JSON file - can be shared between app and external scripts
    private var rulesFileURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("ChooseBrowser")
        
        // Create directory if needed
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        
        return appDir.appendingPathComponent("rules.json")
    }
    
    // Prevent infinite loop - track recently opened URLs
    private var recentlyOpened: [URL: Date] = [:]
    private let deduplicationInterval: TimeInterval = 2.0
    
    init() {
        loadRules()
        loadDefaultBrowser()
    }
    
    func handleURL(_ url: URL) {
        // Check if we already opened this URL recently (prevent loop)
        if let lastOpened = recentlyOpened[url] {
            if Date().timeIntervalSince(lastOpened) < deduplicationInterval {
                NSLog("⏭️ ChooseBrowser: Skipping duplicate URL (opened \(Date().timeIntervalSince(lastOpened))s ago)")
                return
            }
        }
        
        // Mark as opened
        recentlyOpened[url] = Date()
        
        // Clean old entries
        cleanupRecentlyOpened()
        
        // Local files (file://) → open directly in Safari (no domain rules apply)
        if url.isFileURL {
            NSLog("📄 ChooseBrowser: Local file detected, opening in Safari: \(url.path)")
            openInSafari(url)
            return
        }
        
        NSLog("🔍 ChooseBrowser: Checking rules for: \(url.host ?? "unknown")")
        
        if let rule = findMatchingRule(for: url) {
            NSLog("✅ ChooseBrowser: Found rule: \(rule.domain) -> \(rule.browser.rawValue)")
            openURL(url, with: rule.browser)
        } else {
            NSLog("⚠️ ChooseBrowser: No rule found, using default browser")
            openURLWithDefault(url)
        }
    }
    
    private func openInSafari(_ url: URL) {
        guard let safariURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Safari") else {
            NSLog("❌ ChooseBrowser: Safari not found")
            NSWorkspace.shared.open(url)
            return
        }
        let config = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.open([url], withApplicationAt: safariURL, configuration: config) { _, error in
            if let error = error {
                NSLog("❌ ChooseBrowser: Error opening file: \(error.localizedDescription)")
            }
        }
        let filename = url.lastPathComponent
        showNotification(title: "Opened in Safari", message: filename)
    }
    
    private func cleanupRecentlyOpened() {
        let now = Date()
        recentlyOpened = recentlyOpened.filter { now.timeIntervalSince($0.value) < 60 }
    }
    
    func findMatchingRule(for url: URL) -> BrowserRule? {
        guard let host = url.host else { return nil }
        
        return rules.first { rule in
            rule.isActive && matchesDomain(host, pattern: rule.domain)
        }
    }
    
    private func matchesDomain(_ host: String, pattern: String) -> Bool {
        // Exact match
        if host.lowercased() == pattern.lowercased() {
            return true
        }
        
        // Wildcard match (e.g., "*.google.com" matches "mail.google.com")
        if pattern.hasPrefix("*.") {
            let suffix = pattern.dropFirst(1) // ".google.com"
            if host.hasSuffix(suffix) {
                return true
            }
        }
        
        // Subdomain match (e.g., "google.com" matches "mail.google.com")
        if host.hasSuffix("." + pattern) {
            return true
        }
        
        return false
    }
    
    func openURL(_ url: URL, with browser: Browser) {
        // Tüm bundle ID'leri sırayla dene
        var resolvedAppURL: URL?
        var resolvedBundleID: String?
        
        for bundleID in browser.bundleIdentifiers {
            if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
                resolvedAppURL = appURL
                resolvedBundleID = bundleID
                break
            }
        }
        
        guard let appURL = resolvedAppURL, let bundleID = resolvedBundleID else {
            showNotification(title: "Browser Not Found", message: "\(browser.rawValue) is not installed")
            openURLWithDefault(url)
            return
        }
        
        let config = NSWorkspace.OpenConfiguration()
        config.createsNewApplicationInstance = false
        
        NSLog("🌐 ChooseBrowser: Opening \(url) in \(browser.rawValue) (bundle: \(bundleID))")
        
        NSWorkspace.shared.open([url], withApplicationAt: appURL, configuration: config) { _, error in
            if let error = error {
                NSLog("❌ ChooseBrowser: Error opening URL: \(error.localizedDescription)")
            }
        }
        
        showNotification(title: "Opened in \(browser.rawValue)", message: url.host ?? url.absoluteString)
    }
    
    func openURLWithDefault(_ url: URL) {
        NSLog("🔄 ChooseBrowser: Opening with default browser: \(defaultBrowser.rawValue)")
        openURL(url, with: defaultBrowser)
    }
    
    func addRule(domain: String, browser: Browser) {
        let rule = BrowserRule(domain: domain, browser: browser)
        rules.append(rule)
        saveRules()
    }
    
    func updateRule(_ rule: BrowserRule) {
        if let index = rules.firstIndex(where: { $0.id == rule.id }) {
            rules[index] = rule
            saveRules()
        }
    }
    
    func deleteRule(_ rule: BrowserRule) {
        rules.removeAll { $0.id == rule.id }
        saveRules()
    }
    
    func toggleRule(_ rule: BrowserRule) {
        if let index = rules.firstIndex(where: { $0.id == rule.id }) {
            rules[index].isActive.toggle()
            saveRules()
        }
    }
    
    private func loadRules() {
        guard FileManager.default.fileExists(atPath: rulesFileURL.path) else {
            NSLog("📋 No rules file found at: \(rulesFileURL.path)")
            return
        }
        
        do {
            let data = try Data(contentsOf: rulesFileURL)
            rules = try JSONDecoder().decode([BrowserRule].self, from: data)
            NSLog("📋 Loaded \(rules.count) rules from \(rulesFileURL.path)")
        } catch {
            NSLog("❌ Failed to load rules: \(error)")
        }
    }
    
    private func saveRules() {
        do {
            let data = try JSONEncoder().encode(rules)
            try data.write(to: rulesFileURL)
            NSLog("💾 Saved \(rules.count) rules to \(rulesFileURL.path)")
        } catch {
            NSLog("❌ Failed to save rules: \(error)")
        }
    }
    
    private func loadDefaultBrowser() {
        if let savedBrowser = UserDefaults.standard.string(forKey: "defaultBrowser"),
           let browser = Browser(rawValue: savedBrowser) {
            defaultBrowser = browser
            NSLog("⚙️ Loaded default browser: \(browser.rawValue)")
        }
    }
    
    private func saveDefaultBrowser() {
        UserDefaults.standard.set(defaultBrowser.rawValue, forKey: "defaultBrowser")
        NSLog("⚙️ Saved default browser: \(defaultBrowser.rawValue)")
    }
    
    func showNotification(title: String, message: String) {
        NotificationService.show(title: title, message: message)
    }
}
