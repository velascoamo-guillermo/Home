//
//  ContentView.swift
//  Home
//
//  Created by Guillermo Velasco on 15/5/26.
//

import SwiftUI

// MARK: - Authentication State Manager
@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    
    func signIn(email: String, password: String) async {
        isLoading = true
        
        // Simulate network call
        try? await Task.sleep(for: .seconds(1))
        
        // Simple validation for demo - replace with real authentication
        if !email.isEmpty && !password.isEmpty {
            isAuthenticated = true
        }
        
        isLoading = false
    }
    
    func signOut() {
        isAuthenticated = false
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var authManager = AuthManager()
    
    var body: some View {
        if authManager.isAuthenticated {
            MainTabView()
                .environmentObject(authManager)
        } else {
            AuthView()
                .environmentObject(authManager)
        }
    }
}

// MARK: - Authentication View
struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                // Logo/Title
                VStack(spacing: 12) {
                    Image(systemName: "pawprint.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.tint)
                    
                    Text("Pet Home")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Welcome back!")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Login Form
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)
                    
                    Button(action: signIn) {
                        HStack {
                            if authManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                            }
                            
                            Text("Sign In")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white)
                        .padding()
                        .background(.tint)
                        .cornerRadius(10)
                    }
                    .disabled(authManager.isLoading || email.isEmpty || password.isEmpty)
                }
                
                Spacer()
                
                // Sign up option
                HStack {
                    Text("Don't have an account?")
                        .foregroundStyle(.secondary)
                    Button("Sign Up") {
                        // Handle sign up
                    }
                    .fontWeight(.medium)
                }
            }
            .padding(.horizontal, 24)
            .navigationBarHidden(true)
        }
    }
    
    private func signIn() {
        Task {
            await authManager.signIn(email: email, password: password)
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            PetsView()
                .tabItem {
                    Image(systemName: "pawprint")
                    Text("Pets")
                }
            
            ShopView()
                .tabItem {
                    Image(systemName: "cart")
                    Text("Shop")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

// MARK: - Tab Views
struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome to Pet Home! 🏠")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 12) {
                    FeatureCard(
                        icon: "heart.fill",
                        title: "Pet Care",
                        description: "Track your pet's health and activities"
                    )
                    
                    FeatureCard(
                        icon: "calendar",
                        title: "Appointments",
                        description: "Schedule vet visits and grooming"
                    )
                    
                    FeatureCard(
                        icon: "photo",
                        title: "Memories",
                        description: "Save precious moments with your pets"
                    )
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

struct PetsView: View {
    @State private var pets = [
        Pet(name: "Luna", type: "Dog", breed: "Golden Retriever"),
        Pet(name: "Whiskers", type: "Cat", breed: "Persian"),
        Pet(name: "Buddy", type: "Dog", breed: "Labrador")
    ]
    
    var body: some View {
        NavigationStack {
            List(pets) { pet in
                PetRow(pet: pet)
            }
            .navigationTitle("My Pets")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Add new pet
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

struct ShopView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(sampleProducts, id: \.id) { product in
                        ProductCard(product: product)
                    }
                }
                .padding()
            }
            .navigationTitle("Pet Shop")
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    SettingsRow(icon: "person.circle", title: "Profile", subtitle: "Manage your account")
                    SettingsRow(icon: "bell", title: "Notifications", subtitle: "Pet reminders & alerts")
                    SettingsRow(icon: "shield", title: "Privacy", subtitle: "Data & security settings")
                }
                
                Section {
                    SettingsRow(icon: "questionmark.circle", title: "Help & Support", subtitle: "Get assistance")
                    SettingsRow(icon: "info.circle", title: "About", subtitle: "App version & info")
                }
                
                Section {
                    Button(action: {
                        authManager.signOut()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundStyle(.red)
                            Text("Sign Out")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Supporting Views and Models
struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

struct Pet: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let breed: String
}

struct PetRow: View {
    let pet: Pet
    
    var body: some View {
        HStack {
            Image(systemName: pet.type == "Dog" ? "dog" : "cat")
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(pet.name)
                    .font(.headline)
                Text("\(pet.breed) • \(pet.type)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct Product: Identifiable {
    let id = UUID()
    let name: String
    let price: String
    let image: String
}

let sampleProducts = [
    Product(name: "Premium Dog Food", price: "$29.99", image: "bowl"),
    Product(name: "Cat Toy Set", price: "$15.99", image: "sparkles"),
    Product(name: "Pet Bed", price: "$49.99", image: "bed.double"),
    Product(name: "Leash & Collar", price: "$19.99", image: "link")
]

struct ProductCard: View {
    let product: Product
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: product.image)
                .font(.system(size: 40))
                .foregroundStyle(.tint)
                .frame(height: 60)
            
            Text(product.name)
                .font(.headline)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Text(product.price)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.tint)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ContentView()
}
