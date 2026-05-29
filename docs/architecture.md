# Architecture

## App Layer Diagram

```mermaid
graph TD
    subgraph UI["UI Layer (SwiftUI)"]
        HomeApp --> ContentView
        ContentView --> MainTabView
        MainTabView --> HomeView
        MainTabView --> PetsView
        MainTabView --> ShopView
        MainTabView --> SettingsView
        PetsView --> PetDetailView
        PetDetailView --> VetTabView
        PetDetailView --> AppointmentsTabView
        PetDetailView --> ClinicalHistoryTabView
        PetDetailView --> EventsTabView
        PetDetailView --> FilesTabView
    end

    subgraph Services["Services"]
        SupabaseStore["SupabaseStore (@Observable)"]
        ExtractionService
        CalendarService
        KeychainService
    end

    subgraph Backend["Backend"]
        DB[(Supabase DB)]
        Storage[(Supabase Storage\npet-files bucket)]
        ClaudeAPI[Claude API]
    end

    UI -->|"@Environment(SupabaseStore.self)"| SupabaseStore
    FilesTabView --> ExtractionService
    HomeView --> CalendarService
    SupabaseStore --> KeychainService
    ExtractionService -->|REST| ClaudeAPI
    SupabaseStore -->|REST| DB
    SupabaseStore -->|Storage API| Storage
```

`SupabaseStore` is created once in `ContentView` and passed down via `.environment(store)`. Every view reads and mutates app state through it — no local caches, no view models.

---

## Module Dependency Graph

```mermaid
graph LR
    HomeApp --> ContentView
    ContentView --> SupabaseStore
    ContentView --> MainTabView

    MainTabView --> HomeView
    MainTabView --> PetsView
    MainTabView --> ShopView
    MainTabView --> SettingsView

    HomeView --> HomeItem
    HomeView --> HouseholdTask
    HomeView --> CalendarService
    HomeView --> SupabaseStore

    PetsView --> Pet
    PetsView --> PetRow
    PetsView --> PetAvatarView
    PetsView --> PetDetailView

    PetDetailView --> PetAvatarView
    PetDetailView --> SupabaseStore
    PetDetailView --> VetTabView
    PetDetailView --> AppointmentsTabView
    PetDetailView --> ClinicalHistoryTabView
    PetDetailView --> EventsTabView
    PetDetailView --> FilesTabView

    FilesTabView --> ExtractionService
    FilesTabView --> FilePickerCoordinator
    FilesTabView --> FilePreviewView

    ExtractionService --> SupabaseStore
    SupabaseStore --> SupabaseConfig
    SupabaseStore --> KeychainService
```
