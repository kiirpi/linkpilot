import Foundation

struct BrowserRule: Identifiable, Codable {
    let id: UUID
    var domain: String
    var browser: Browser
    var isActive: Bool
    
    init(id: UUID = UUID(), domain: String, browser: Browser, isActive: Bool = true) {
        self.id = id
        self.domain = domain
        self.browser = browser
        self.isActive = isActive
    }
}

enum Browser: String, Codable, CaseIterable {
    case safari = "Safari"
    case chrome = "Google Chrome"
    case firefox = "Firefox"
    case firefoxDev = "Firefox Developer Edition"
    case edge = "Microsoft Edge"
    case arc = "Arc"
    case brave = "Brave Browser"
    
    /// Bundle ID'leri sırayla denenir — ilk bulunan kullanılır
    var bundleIdentifiers: [String] {
        switch self {
        case .safari:     return ["com.apple.Safari"]
        case .chrome:     return ["com.google.Chrome", "com.google.Chrome.canary"]
        case .firefox:    return ["org.mozilla.firefox", "org.mozilla.firefoxdeveloperedition", "org.mozilla.nightly"]
        case .firefoxDev: return ["org.mozilla.firefoxdeveloperedition", "org.mozilla.firefox", "org.mozilla.nightly"]
        case .edge:       return ["com.microsoft.edgemac", "com.microsoft.edgemac.Beta", "com.microsoft.edgemac.Dev"]
        case .arc:        return ["company.thebrowser.Browser", "company.thebrowser.Arc"]
        case .brave:      return ["com.brave.Browser", "com.brave.Browser.beta", "com.brave.Browser.nightly"]
        }
    }
    
    /// İlk bulunan bundle ID (geriye uyumluluk)
    var bundleIdentifier: String {
        bundleIdentifiers.first!
    }
    
    var iconName: String {
        switch self {
        case .safari:     return "safari"
        case .chrome:     return "globe"
        case .firefox:    return "flame"
        case .firefoxDev: return "flame.fill"
        case .edge:       return "edge"
        case .arc:        return "arc"
        case .brave:      return "shield"
        }
    }
}
