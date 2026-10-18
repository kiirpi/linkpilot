import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var ruleManager: RuleManager
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ChooseBrowser")
                .font(.headline)
            
            Divider()
            
            if ruleManager.rules.isEmpty {
                Text("No rules configured")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(ruleManager.rules) { rule in
                        RuleRow(rule: rule)
                            .environmentObject(ruleManager)
                    }
                }
                .padding(.horizontal)
            }
            
            Divider()
            
            Button(action: {
                openWindow(id: "settings")
                NSApp.activate(ignoringOtherApps: true)
            }) {
                Label("Settings...", systemImage: "gear")
            }
            .keyboardShortcut(",")
            
            Button(action: {
                NSApp.terminate(nil)
            }) {
                Label("Quit ChooseBrowser", systemImage: "xmark.circle")
            }
            .keyboardShortcut("q")
        }
        .padding()
        .frame(width: 300)
    }
}

struct RuleRow: View {
    @EnvironmentObject var ruleManager: RuleManager
    let rule: BrowserRule
    
    var body: some View {
        HStack {
            Image(systemName: "globe")
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(rule.domain)
                    .font(.system(size: 13, weight: .medium))
                Text(rule.browser.rawValue)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { rule.isActive },
                set: { _ in ruleManager.toggleRule(rule) }
            ))
            .toggleStyle(.switch)
            .labelsHidden()
        }
        .opacity(rule.isActive ? 1.0 : 0.6)
    }
}
