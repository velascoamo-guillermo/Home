---
name: project-documentation
description: Design for README (portfolio/showcase) and /docs diagrams (architecture, ER, user flow, module dependency) using Mermaid
metadata:
  type: project
---

# Project Documentation Design

**Date:** 2026-05-29  
**Scope:** README.md (root) + `/docs` subdirectory with four Mermaid diagram docs  
**Audience:** Portfolio visitors and GitHub explorers  

---

## Structure

```
README.md                  # root — portfolio showcase
docs/
  architecture.md          # arch diagram + module dependency graph
  data-model.md            # ER diagram (Supabase tables + relationships)
  user-flows.md            # navigation/screen flow diagram
```

---

## README.md Sections

1. **Hero** — app name, one-line tagline, tech stack badges (SwiftUI · Swift 6 · Supabase · iOS 18+)
2. **Features** — bullet highlights per tab (Home timeline, Pets, AI doc extraction, File storage)
3. **Screenshots** — placeholder grid (3–4 simulator screenshots)
4. **Architecture** — brief prose + inline Mermaid arch overview, with links to `/docs` for detail
5. **Getting Started** — `Config.xcconfig` setup, `supabase db push`, open in Xcode

---

## docs/architecture.md

Two Mermaid diagrams:

**App layer diagram** — vertical stack: UI layer (Views) → Store layer (SupabaseStore) → Backend (Supabase REST + Storage). Includes `ExtractionService` → Claude API lateral dependency.

**Module dependency graph** — directed graph of Swift types: which views depend on which models/services. Key nodes: `HomeApp`, `ContentView`, `MainTabView`, `SupabaseStore`, `PetDetailView`, `HomeView`, `ExtractionService`.

---

## docs/data-model.md

Mermaid `erDiagram` covering all Supabase tables:

- `pets` — id, name, species, birthdate, photo_url
- `veterinarian` — id, name, clinic, phone, email
- `appointments` — id, pet_id → pets, vet_id → veterinarian, date, status
- `clinical_entries` — id, pet_id → pets, date, notes, diagnosis
- `pet_events` — id, pet_id → pets, date, title, notes
- `pet_files` — id, pet_id → pets, storage_path, source_type, linked_to_type, linked_to_id
- `household_tasks` — id, title, due_date, section_id → task_sections
- `task_sections` — id, name, icon

---

## docs/user-flows.md

Mermaid `flowchart TD` showing screen navigation:

- Entry: `HomeApp` → `ContentView` → auth gate → `MainTabView`
- Home tab: `HomeView` → task actions (add, done, snooze, delete, calendar)
- Pets tab: `PetsView` → `PetDetailView` (card grid) → tab views (Vet, Appointments, Clinical, Events, Files) → per-tab sheets → `ExtractionResultSheet`
- Settings tab: `SettingsView`

---

## Constraints

- No external diagram tooling — Mermaid only (GitHub-native rendering)
- No screenshots committed to repo (placeholder text pointing to App Store or simulator)
- README stays under ~150 lines; depth in `/docs`
- No setup instructions beyond what CLAUDE.md already covers (keep DRY)
