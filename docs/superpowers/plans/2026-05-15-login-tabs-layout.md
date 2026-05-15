# Pet Home — Login + Tab Layout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor monolithic `ContentView.swift` into a feature-folder structure with a colorful Liquid Glass login screen and an iOS 26 authenticated tab shell.

**Architecture:** Each feature lives in its own folder. `ContentView` acts as a root switch between `LoginView` and `MainTabView`, driven by `AuthManager` via `@EnvironmentObject`. iOS 26 `Tab` API and `.glassEffect()` used throughout.

**Tech Stack:** SwiftUI, iOS 26+, Liquid Glass (`.glassEffect()`), SF Symbols 6, native `Tab` API (iOS 18+)

> **Note for agentic workers:** This is a layout-only plan. There is no business logic to unit-test. Verification steps are build checks (⌘B) and SwiftUI preview checks. After creating each file on disk, add it to the Xcode project: right-click the target group in the Project Navigator → "Add Files to Home" → select the file, ensure target membership is checked.

---

### Task 1: Create directory structure

**Files:**
- Create dirs: `Home/Auth/`, `Home/Main/`, `Home/Pets/`, `Home/Shop/`, `Home/Settings/`, `Home/Shared/Components/`

- [ ] **Step 1: Create directories on disk**

Run from the repo root (`/Users/guillermovelasco/Documents/Projects/Swifts Projects/Home`):

```bash
mkdir -p Home/Auth Home/Main Home/Pets Home/Shop Home/Settings "Home/Shared/Components"
```

- [ ] **Step 2: Verify**

```bash
find Home -type d | sort
```

Expected: all 6 new directories appear in output.

- [ ] **Step 3: Commit**

```bash
git add .
git commit -m "chore: create feature folder structure"
```

---

### Task 2: AuthManager

**Files:**
- Create: `Home/Auth/AuthManager.swift`

- [ ] **Step 1: Create `Home/Auth/AuthManager.swift`**

```swift
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
```

- [ ] **Step 2: Add to Xcode project**

Right-click the `Auth` group in Xcode → "Add Files to Home" → select `AuthManager.swift`.

- [ ] **Step 3: Build**

⌘B — expect 0 errors.

- [ ] **Step 4: Commit**

```bash
git add Home/Auth/AuthManager.swift
git commit -m "feat: add AuthManager"
```

---

### Task 3: Shared components — FeatureCard, PetRow, ProductCard, SettingsRow

**Files:**
- Create: `Home/Shared/Components/FeatureCard.swift`
- Create: `Home/Shared/Components/PetRow.swift`
- Create: `Home/Shared/Components/ProductCard.swift`
- Create: `Home/Shared/Components/SettingsRow.swift`

- [ ] **Step 1: Create `Home/Shared/Components/FeatureCard.swift`**

```swift
import SwiftUI

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
        .glassEffect(in: RoundedRectangle(cornerRadius: 14))
    }
}
```

- [ ] **Step 2: Create `Home/Shared/Components/PetRow.swift`**

```swift
import SwiftUI

struct PetRow: View {
    let pet: Pet

    var body: some View {
        HStack {
            Image(systemName: pet.type == "Dog" ? "dog.fill" : "cat.fill")
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
```

- [ ] **Step 3: Create `Home/Shared/Components/ProductCard.swift`**

```swift
import SwiftUI

struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: product.icon)
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
        .glassEffect(in: RoundedRectangle(cornerRadius: 14))
    }
}
```

- [ ] **Step 4: Create `Home/Shared/Components/SettingsRow.swift`**

```swift
import SwiftUI

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
```

- [ ] **Step 5: Add all 4 files to Xcode project**

Right-click `Shared/Components` group → "Add Files to Home" → select all 4 files.

- [ ] **Step 6: Build**

⌘B — will fail with "cannot find type 'Pet'" and "cannot find type 'Product'". Expected — models are created in Tasks 4 and 5. Proceed.

- [ ] **Step 7: Commit**

```bash
git add "Home/Shared/Components/"
git commit -m "feat: add shared UI components"
```

---

### Task 4: Pet model

**Files:**
- Create: `Home/Pets/Pet.swift`

- [ ] **Step 1: Create `Home/Pets/Pet.swift`**

```swift
import Foundation

struct Pet: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let breed: String
}
```

- [ ] **Step 2: Add to Xcode project**

Right-click `Pets` group → "Add Files to Home" → select `Pet.swift`.

- [ ] **Step 3: Build**

⌘B — `PetRow` error resolves. Only `Product` error remains.

- [ ] **Step 4: Commit**

```bash
git add Home/Pets/Pet.swift
git commit -m "feat: add Pet model"
```

---

### Task 5: Product model

**Files:**
- Create: `Home/Shop/Product.swift`

- [ ] **Step 1: Create `Home/Shop/Product.swift`**

```swift
import Foundation

struct Product: Identifiable {
    let id = UUID()
    let name: String
    let price: String
    let icon: String
}
```

- [ ] **Step 2: Add to Xcode project**

Right-click `Shop` group → "Add Files to Home" → select `Product.swift`.

- [ ] **Step 3: Build**

⌘B — all model errors resolve. Expect 0 errors.

- [ ] **Step 4: Commit**

```bash
git add Home/Shop/Product.swift
git commit -m "feat: add Product model"
```

---

### Task 6: LoginView

**Files:**
- Create: `Home/Auth/LoginView.swift`

- [ ] **Step 1: Create `Home/Auth/LoginView.swift`**

```swift
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""

    private let gradientStart = Color(red: 1.0, green: 0.45, blue: 0.2)
    private let gradientEnd = Color(red: 0.65, green: 0.25, blue: 0.75)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [gradientStart, gradientEnd],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 16) {
                    Image(systemName: "pawprint.circle.fill")
                        .font(.system(size: 90))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.25), radius: 14, y: 6)

                    Text("Pet Home")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Text("Welcome back!")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.8))
                }

                Spacer()

                VStack(spacing: 14) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.plain)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .foregroundStyle(.white)
                        .tint(.white)
                        .padding()
                        .glassEffect(in: RoundedRectangle(cornerRadius: 14))

                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .foregroundStyle(.white)
                        .tint(.white)
                        .padding()
                        .glassEffect(in: RoundedRectangle(cornerRadius: 14))

                    Button(action: signIn) {
                        HStack(spacing: 10) {
                            if authManager.isLoading {
                                ProgressView()
                                    .tint(gradientStart)
                                    .scaleEffect(0.85)
                            }
                            Text("Sign In")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(gradientStart)
                        .padding()
                        .background(.white)
                        .clipShape(Capsule())
                    }
                    .disabled(authManager.isLoading || email.isEmpty || password.isEmpty)
                }
                .padding(.horizontal, 28)

                Spacer()

                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundStyle(.white.opacity(0.8))
                    Button("Sign Up") {}
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                .padding(.bottom, 36)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func signIn() {
        Task {
            await authManager.signIn(email: email, password: password)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}
```

- [ ] **Step 2: Add to Xcode project**

Right-click `Auth` group → "Add Files to Home" → select `LoginView.swift`.

- [ ] **Step 3: Build + check preview**

⌘B → 0 errors. Open `LoginView` preview — expect gradient background, glass fields, white capsule button.

- [ ] **Step 4: Commit**

```bash
git add Home/Auth/LoginView.swift
git commit -m "feat: add Liquid Glass login screen"
```

---

### Task 7: HomeView

**Files:**
- Create: `Home/Home/HomeView.swift`

- [ ] **Step 1: Create `Home/Home/HomeView.swift`**

```swift
import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Good to see you! 🐾")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)

                    VStack(spacing: 12) {
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
                            icon: "photo.fill",
                            title: "Memories",
                            description: "Save precious moments with your pets"
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
}
```

- [ ] **Step 2: Add to Xcode project**

Right-click `Home` group → "Add Files to Home" → select `HomeView.swift`.

- [ ] **Step 3: Build + preview**

⌘B → 0 errors. Preview shows title, 3 glass cards.

- [ ] **Step 4: Commit**

```bash
git add Home/Home/HomeView.swift
git commit -m "feat: add HomeView"
```

---

### Task 8: PetsView

**Files:**
- Create: `Home/Pets/PetsView.swift`

- [ ] **Step 1: Create `Home/Pets/PetsView.swift`**

```swift
import SwiftUI

struct PetsView: View {
    @State private var pets: [Pet] = [
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
                        // placeholder
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    PetsView()
}
```

- [ ] **Step 2: Add to Xcode project**

Right-click `Pets` group → "Add Files to Home" → select `PetsView.swift`.

- [ ] **Step 3: Build + preview**

⌘B → 0 errors. Preview shows list of 3 pets with icons.

- [ ] **Step 4: Commit**

```bash
git add Home/Pets/PetsView.swift
git commit -m "feat: add PetsView"
```

---

### Task 9: ShopView

**Files:**
- Create: `Home/Shop/ShopView.swift`

- [ ] **Step 1: Create `Home/Shop/ShopView.swift`**

```swift
import SwiftUI

struct ShopView: View {
    private let products: [Product] = [
        Product(name: "Premium Dog Food", price: "$29.99", icon: "bowl.fill"),
        Product(name: "Cat Toy Set", price: "$15.99", icon: "sparkles"),
        Product(name: "Pet Bed", price: "$49.99", icon: "bed.double.fill"),
        Product(name: "Leash & Collar", price: "$19.99", icon: "link")
    ]

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(products) { product in
                        ProductCard(product: product)
                    }
                }
                .padding()
            }
            .navigationTitle("Pet Shop")
        }
    }
}

#Preview {
    ShopView()
}
```

- [ ] **Step 2: Add to Xcode project**

Right-click `Shop` group → "Add Files to Home" → select `ShopView.swift`.

- [ ] **Step 3: Build + preview**

⌘B → 0 errors. Preview shows 2-column grid of 4 glass product cards.

- [ ] **Step 4: Commit**

```bash
git add Home/Shop/ShopView.swift
git commit -m "feat: add ShopView"
```

---

### Task 10: SettingsView

**Files:**
- Create: `Home/Settings/SettingsView.swift`

- [ ] **Step 1: Create `Home/Settings/SettingsView.swift`**

```swift
import SwiftUI

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
                    Button {
                        authManager.signOut()
                    } label: {
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

#Preview {
    SettingsView()
        .environmentObject(AuthManager())
}
```

- [ ] **Step 2: Add to Xcode project**

Right-click `Settings` group → "Add Files to Home" → select `SettingsView.swift`.

- [ ] **Step 3: Build + preview**

⌘B → 0 errors. Preview shows grouped list with Sign Out in red.

- [ ] **Step 4: Commit**

```bash
git add Home/Settings/SettingsView.swift
git commit -m "feat: add SettingsView"
```

---

### Task 11: MainTabView with iOS 26 Tab API

**Files:**
- Create: `Home/Main/MainTabView.swift`

- [ ] **Step 1: Create `Home/Main/MainTabView.swift`**

```swift
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                HomeView()
            }
            Tab("Pets", systemImage: "pawprint.fill") {
                PetsView()
            }
            Tab("Shop", systemImage: "cart.fill") {
                ShopView()
            }
            Tab("Settings", systemImage: "gearshape.fill") {
                SettingsView()
            }
        }
        .tint(Color(red: 1.0, green: 0.45, blue: 0.2))
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager())
}
```

- [ ] **Step 2: Add to Xcode project**

Right-click `Main` group → "Add Files to Home" → select `MainTabView.swift`.

- [ ] **Step 3: Build + preview**

⌘B → 0 errors. Preview shows tab bar with 4 tabs, orange tint, Liquid Glass tab bar (iOS 26 automatic).

- [ ] **Step 4: Commit**

```bash
git add Home/Main/MainTabView.swift
git commit -m "feat: add MainTabView with iOS 26 Tab API"
```

---

### Task 12: Slim ContentView + remove old code

**Files:**
- Modify: `Home/ContentView.swift` — replace entire contents

- [ ] **Step 1: Replace `Home/ContentView.swift`**

```swift
import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager()

    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .environmentObject(authManager)
    }
}

#Preview {
    ContentView()
}
```

- [ ] **Step 2: Build**

⌘B → 0 errors. All old code (AuthView, old MainTabView, Pet, Product, etc.) now lives in dedicated files.

- [ ] **Step 3: Run in simulator**

Launch on iPhone 16 Pro (iOS 26). Verify:
- Login screen shows gradient + glass fields + capsule button
- Sign in with any non-empty email + password → navigates to tab shell
- All 4 tabs accessible, tab bar has Liquid Glass appearance
- Settings → Sign Out → returns to login

- [ ] **Step 4: Commit**

```bash
git add Home/ContentView.swift
git commit -m "refactor: slim ContentView to root auth switch"
```

---

### Task 13: Xcode group cleanup (manual)

- [ ] **Step 1: Remove old Xcode group references**

In Xcode Project Navigator: if the old monolithic `ContentView.swift` still shows duplicate symbols or if Xcode groups don't match the folder structure, reorganize groups to match:

```
Home (group)
├── Auth/
├── Main/
├── Pets/
├── Shop/
├── Settings/
└── Shared/
    └── Components/
```

- [ ] **Step 2: Final build + archive check**

Product → Build (⌘B). Expect 0 errors, 0 warnings related to duplicate symbols.

- [ ] **Step 3: Commit if any .xcodeproj changes**

```bash
git add Home.xcodeproj/
git commit -m "chore: reorganize Xcode groups to match feature folders"
```
