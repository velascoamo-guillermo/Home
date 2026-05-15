// Home/Settings/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var showApiKeySheet = false
    @State private var hasApiKey: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    SettingsRow(icon: "person.circle", title: "Profile", subtitle: "Manage your account")
                    SettingsRow(icon: "bell", title: "Notifications", subtitle: "Pet reminders & alerts")
                    SettingsRow(icon: "shield", title: "Privacy", subtitle: "Data & security settings")
                }

                Section("Integrations") {
                    Button { showApiKeySheet = true } label: {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundStyle(.purple)
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Claude API Key")
                                    .foregroundStyle(.primary)
                                Text(hasApiKey ? "Configured" : "Not configured")
                                    .font(.caption)
                                    .foregroundStyle(hasApiKey ? .green : .secondary)
                            }
                        }
                    }
                }

                Section {
                    SettingsRow(icon: "questionmark.circle", title: "Help & Support", subtitle: "Get assistance")
                    SettingsRow(icon: "info.circle", title: "About", subtitle: "App version & info")
                }

                Section {
                    Button {
                        authManager.signOut()
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right").foregroundStyle(.red)
                            Text("Sign Out").foregroundStyle(.red)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear { hasApiKey = KeychainService.load(account: KeychainService.claudeApiKeyAccount) != nil }
            .sheet(isPresented: $showApiKeySheet, onDismiss: {
                hasApiKey = KeychainService.load(account: KeychainService.claudeApiKeyAccount) != nil
            }) {
                ApiKeySheet()
            }
        }
    }
}

private struct ApiKeySheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var key: String = ""
    @State private var isSecure: Bool = true

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        if isSecure {
                            SecureField("sk-ant-...", text: $key)
                        } else {
                            TextField("sk-ant-...", text: $key)
                        }
                        Button { isSecure.toggle() } label: {
                            Image(systemName: isSecure ? "eye" : "eye.slash")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Claude API Key")
                } footer: {
                    Text("Used to extract information from vet documents. Stored securely in Keychain.")
                }
                if KeychainService.load(account: KeychainService.claudeApiKeyAccount) != nil {
                    Section {
                        Button("Remove Key", role: .destructive) {
                            KeychainService.delete(account: KeychainService.claudeApiKeyAccount)
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("API Key")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        KeychainService.save(key: key.trimmingCharacters(in: .whitespaces),
                                            account: KeychainService.claudeApiKeyAccount)
                        dismiss()
                    }
                    .disabled(key.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                key = KeychainService.load(account: KeychainService.claudeApiKeyAccount) ?? ""
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(AuthManager())
}
