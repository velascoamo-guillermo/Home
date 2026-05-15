import SwiftUI

@MainActor
final class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false

    func signIn(email: String, password: String) async {
        isLoading = true
        try? await Task.sleep(for: .seconds(1))
        if !email.isEmpty && !password.isEmpty {
            isAuthenticated = true
        }
        isLoading = false
    }

    func signOut() {
        isAuthenticated = false
    }
}
