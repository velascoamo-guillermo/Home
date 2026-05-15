# Pet Home — Login + Tab Layout Design

**Date:** 2026-05-15  
**Scope:** Initial layout/mockup — login screen + authenticated tab shell  
**Auth:** Mock only (no backend)  
**Platform:** iOS 26+, Liquid Glass design language

---

## File Structure

```
Home/
├── HomeApp.swift
├── ContentView.swift              ← root switch: auth vs main
├── Auth/
│   ├── AuthManager.swift
│   └── LoginView.swift
├── Main/
│   └── MainTabView.swift
├── Home/
│   └── HomeView.swift
├── Pets/
│   ├── PetsView.swift
│   └── Pet.swift
├── Shop/
│   ├── ShopView.swift
│   └── Product.swift
├── Settings/
│   └── SettingsView.swift
└── Shared/
    └── Components/
        ├── FeatureCard.swift
        ├── PetRow.swift
        ├── ProductCard.swift
        └── SettingsRow.swift
```

`ContentView` only decides which root view to show — no logic of its own.  
`AuthManager` is `@MainActor class ObservableObject` in `Auth/AuthManager.swift`.

---

## Login Screen (`Auth/LoginView.swift`)

**Style:** Colorful/playful

- **Background:** vertical gradient (warm orange → pink/purple), full screen, ignores safe area
- **Logo:** `pawprint.circle.fill`, large (80pt), white, drop shadow
- **Title:** "Pet Home", white, largeTitle bold
- **Subtitle:** "Welcome back!", white, semitransparent, title3
- **Fields:** `.ultraThinMaterial` background, white text, no classic border, rounded corners. Email field + SecureField password.
- **Sign In button:** white fill, pill shape (cornerRadius 30), text in gradient accent color. Shows inline `ProgressView` while loading. Disabled when fields empty or loading.
- **"Don't have an account?"** text: white semitransparent + tappable "Sign Up" in white bold (no-op placeholder)

---

## Main Tab View (`Main/MainTabView.swift`)

- Native iOS `TabView`
- Tint: orange/coral (matches login gradient start color), set via `.tint()`
- Each tab has its own `NavigationStack`

| Tab | Icon | View |
|-----|------|------|
| Home | `house.fill` | `HomeView` |
| Pets | `pawprint.fill` | `PetsView` |
| Shop | `cart.fill` | `ShopView` |
| Settings | `gearshape.fill` | `SettingsView` |

---

## Tab Content (Placeholder Layout)

### Home (`Home/HomeView.swift`)
- `navigationTitle("Home")`
- Greeting text at top
- `FeatureCard` list: Pet Care, Appointments, Memories
- Cards use `.regularMaterial` background, tint icon, rounded

### Pets (`Pets/PetsView.swift`)
- `navigationTitle("My Pets")`
- `List` of `PetRow` items (name, breed, type icon)
- Toolbar `+` button (no-op placeholder)
- Hardcoded sample pets via `Pet` model in `Pets/Pet.swift`

### Shop (`Shop/ShopView.swift`)
- `navigationTitle("Pet Shop")`
- `ScrollView` + `LazyVGrid` 2-column
- `ProductCard` with SF Symbol icon, name, price
- Hardcoded sample products via `Product` model in `Shop/Product.swift`

### Settings (`Settings/SettingsView.swift`)
- `navigationTitle("Settings")`
- Grouped `List`: Profile, Notifications, Privacy / Help, About / Sign Out
- Sign Out calls `authManager.signOut()` → returns to login
- Sign Out row text and icon in `.red`

---

## Shared Components (`Shared/Components/`)

| File | What |
|------|------|
| `FeatureCard.swift` | HStack with icon + title + description, material bg |
| `PetRow.swift` | HStack with pet icon + name/breed + chevron |
| `ProductCard.swift` | VStack with icon + name + price, material bg |
| `SettingsRow.swift` | HStack with icon + title + subtitle + chevron |

---

## iOS 26 / Liquid Glass Requirements

- **Minimum deployment target:** iOS 26
- **Tab bar:** Use new `Tab` API (`TabView` with `Tab {}` syntax, iOS 18+/26) — not legacy `.tabItem`
- **Liquid Glass materials:** Prefer `.glassEffect()` modifier (iOS 26) over `.regularMaterial` / `.ultraThinMaterial` where supported — gives the frosted translucent glass look
- **Navigation:** Use `NavigationStack` (already planned) — compatible with iOS 26
- **Login fields:** `.glassEffect()` on field backgrounds instead of `.ultraThinMaterial`
- **Cards:** `.glassEffect()` for `FeatureCard` and `ProductCard` backgrounds
- **Tab bar background:** adopts Liquid Glass automatically on iOS 26 with new `TabView` API
- **Avoid deprecated APIs:** No `.navigationBarHidden(true)` — use `.toolbar(.hidden, for: .navigationBar)` instead

---

## Out of Scope

- Real authentication backend
- Navigation within tabs (detail views)
- Data persistence
- Sign Up flow
