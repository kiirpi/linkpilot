import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var ruleManager: RuleManager
    @State private var newDomain = ""
    @State private var newBrowser: Browser = .safari
    
    var body: some View {
        TabView {
            RulesSettingsView()
                .environmentObject(ruleManager)
                .tabItem {
                    Label("Rules", systemImage: "list.bullet")
                }
            
            AddRuleSettingsView(
                domain: $newDomain,
                browser: $newBrowser
            )
            .environmentObject(ruleManager)
            .tabItem {
                Label("Add Rule", systemImage: "plus.circle")
            }
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 500, height: 400)
    }
}

struct RulesSettingsView: View {
    @EnvironmentObject var ruleManager: RuleManager
    
    var body: some View {
        VStack {
            if ruleManager.rules.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No Rules")
                        .font(.title2)
                        .fontWeight(.medium)
                    Text("Add a rule to get started")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(ruleManager.rules) { rule in
                        RuleSettingsRow(rule: rule)
                            .environmentObject(ruleManager)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            ruleManager.deleteRule(ruleManager.rules[index])
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct RuleSettingsRow: View {
    @EnvironmentObject var ruleManager: RuleManager
    let rule: BrowserRule
    @State private var isEditing = false
    @State private var editingDomain = ""
    @State private var editingBrowser: Browser = .safari
    
    var body: some View {
        HStack {
            Image(systemName: rule.browser.iconName)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            if isEditing {
                TextField("Domain", text: $editingDomain)
                    .textFieldStyle(.roundedBorder)
                
                Picker("Browser", selection: $editingBrowser) {
                    ForEach(Browser.allCases, id: \.self) { browser in
                        Text(browser.rawValue).tag(browser)
                    }
                }
                
                Button("Save") {
                    var updatedRule = rule
                    updatedRule.domain = editingDomain
                    updatedRule.browser = editingBrowser
                    ruleManager.updateRule(updatedRule)
                    isEditing = false
                }
                
                Button("Cancel") {
                    isEditing = false
                }
            } else {
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
                
                Button(action: {
                    editingDomain = rule.domain
                    editingBrowser = rule.browser
                    isEditing = true
                }) {
                    Image(systemName: "pencil")
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddRuleSettingsView: View {
    @EnvironmentObject var ruleManager: RuleManager
    @Binding var domain: String
    @Binding var browser: Browser
    @State private var showAlert = false
    
    var body: some View {
        Form {
            Section("Add New Rule") {
                TextField("Domain (e.g., google.com or *.github.com)", text: $domain)
                    .textFieldStyle(.roundedBorder)
                
                Picker("Browser", selection: $browser) {
                    ForEach(Browser.allCases, id: \.self) { browser in
                        Text(browser.rawValue).tag(browser)
                    }
                }
                
                Button("Add Rule") {
                    if !domain.isEmpty {
                        ruleManager.addRule(domain: domain, browser: browser)
                        domain = ""
                        browser = .safari
                        showAlert = true
                    }
                }
                .keyboardShortcut(.defaultAction)
            }
            
            Section("Examples") {
                Text("• google.com → Opens all Google domains in selected browser")
                Text("• *.github.com → Opens GitHub and all subdomains")
                Text("• mail.google.com → Opens only Gmail")
            }
            .font(.system(size: 11))
            .foregroundColor(.secondary)
        }
        .padding()
        .alert("Rule Added", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "safari")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("ChooseBrowser")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Version 1.0")
                .foregroundColor(.secondary)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("How to use:")
                    .fontWeight(.semibold)
                
                Text("1. Set this app as your default browser in System Preferences")
                Text("2. Add domain rules to route URLs to specific browsers")
                Text("3. Click links - they'll open in the right browser automatically")
            }
            .font(.system(size: 12))
            
            Spacer()
            
            Text("Made with ❤️ for macOS")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
