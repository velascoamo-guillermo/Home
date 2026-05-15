# Pets Detail Feature — Design Spec

**Date:** 2026-05-15  
**Status:** Approved

---

## Overview

Expand the Pets section of the Home iOS app with a full pet detail screen. Each pet has five tabs: Veterinarian, Appointments, Clinical History, Events, and Files. A shared `DataStore` persists all data as a single JSON file. Files (images, documents, scans) are stored on disk. A Claude API integration extracts structured data from vet report documents.

---

## Data Models

All models are `Codable` and stored in a single `AppData.json` in the app's Documents directory. Binary files are stored separately in `Documents/PetFiles/<uuid>.<ext>`.

### AppData
Root container written/read as one JSON blob.

```swift
struct AppData: Codable {
    var veterinarian: Veterinarian?
    var pets: [Pet]
    var appointments: [Appointment]
    var clinicalEntries: [ClinicalEntry]
    var events: [PetEvent]
    var files: [PetFile]
}
```

### Veterinarian
One shared vet for all pets, stored at app level.

| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| name | String | Doctor name |
| clinicName | String | |
| phone | String | tap-to-call |
| address | String | opens Maps |
| notes | String | specialty, free text |

### Pet (extended)
Add `photoFilename: String?` to existing model.

### Appointment

| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| petId | UUID | links to Pet |
| date | Date | |
| reason | String | |
| notes | String | |
| status | AppointmentStatus | upcoming / done / cancelled |

### ClinicalEntry

| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| petId | UUID | |
| date | Date | |
| title | String | |
| description | String | diagnosis/findings |
| fileIds | [UUID] | linked PetFiles |

### PetEvent (general log)

| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| petId | UUID | |
| date | Date | |
| title | String | |
| category | EventCategory | vaccine / grooming / medication / weight / other |
| notes | String | |
| value | String? | e.g. "4.2 kg" for weight |
| fileIds | [UUID] | |

### PetFile

| Field | Type | Notes |
|---|---|---|
| id | UUID | |
| petId | UUID | |
| filename | String | path within Documents/PetFiles/ |
| sourceType | FileSourceType | photo / document / scan |
| createdAt | Date | |
| linkedTo | FileLink | .event(UUID) / .clinicalEntry(UUID) / .standalone |

Images saved as JPEG (0.8 quality). Documents and scans saved as PDF.

---

## DataStore

`@Observable` class injected via `@Environment` into the view hierarchy from `HomeApp`.

- Loads `AppData` from disk on init (or creates empty if missing)
- `save()` encodes and writes to `Documents/AppData.json`
- Helpers: `appointments(for petId)`, `events(for petId)`, `clinicalEntries(for petId)`, `files(for petId, linkedTo:)`
- File operations: `saveFile(data:ext:petId:linkedTo:) -> PetFile`, `deleteFile(_ file:)`

---

## Navigation & Screen Structure

```
PetsView (existing list)
└── PetDetailView(pet)
    ├── Header: pet photo, name, breed
    └── TabView (segmented) — 5 tabs
        ├── [Vet]          VetTabView
        ├── [Appointments] AppointmentsTabView
        ├── [History]      ClinicalHistoryTabView
        ├── [Events]       EventsTabView
        └── [Files]        FilesTabView
```

### VetTabView
- Shows shared vet card: name, clinic, phone (tap → call), address (tap → Maps)
- Edit button → `VetEditSheet` (create or update)
- Empty state if no vet configured yet

### AppointmentsTabView
- Two sections: Upcoming / Past
- Row: date, pet name, reason, status badge (color-coded)
- `+` button → `AddAppointmentSheet`
- Swipe to delete, swipe to mark done/cancelled

### ClinicalHistoryTabView
- Chronological list
- Row: date, title, description preview, file count badge
- Tap → `ClinicalEntryDetailView` (full entry + file grid)
- `+` button → `AddClinicalEntrySheet`

### EventsTabView
- Chronological list (no grouping for MVP)
- Row: category icon, date, title, value if present
- Tap → `EventDetailView` (notes + files)
- `+` button → `AddEventSheet` (category picker, title, date, notes, value, attach files)

### FilesTabView
- 3-column grid of all standalone files for this pet
- `+` button → `FilePickerCoordinator` (photo / camera / document / scan)
- Tap → `FilePreviewView`
- Long press → delete confirmation

---

## File Handling

### FilePickerCoordinator
Reusable SwiftUI component used in Events, ClinicalEntry, and Files tabs. Presents an action sheet with four sources:
- **Photo library** — `PhotosPicker`
- **Camera** — `UIImagePickerController` (camera source)
- **Files app** — `UIDocumentPickerViewController`
- **Scan document** — `VNDocumentCameraViewController` (VisionKit)

Returns `Data` + extension to caller. Caller passes to `DataStore.saveFile(...)`.

### FilePreviewView
- Images: `AsyncImage` / `Image`
- PDFs: `PDFView` (PDFKit)
- "Extract info" button visible only for `sourceType == .document || .scan`

---

## Claude API — Vet Report Extraction

### Setup
- API key stored in iOS Keychain (never in JSON or source)
- User enters key once in Settings → stored via `KeychainService`
- `ExtractionService` reads key from Keychain at call time

### Flow
1. User taps "Extract info" on a document/scan in `FilePreviewView`
2. `ExtractionService.extract(fileURL:petName:)` called
3. File read as base64, sent to `claude-sonnet-4-6` via Anthropic API
4. Prompt instructs Claude to extract:
   - Date of visit
   - Diagnosis / findings
   - Test results (key-value pairs)
   - Medications prescribed
   - Vet recommendations
5. Response parsed into `ExtractionResult` struct
6. `ExtractionResultSheet` shown — structured card, user can edit fields
7. "Save to Clinical History" → creates `ClinicalEntry` linked to this file

### ExtractionResult
```swift
struct ExtractionResult {
    var visitDate: Date?
    var diagnosis: String
    var testResults: [String: String]
    var medications: [String]
    var recommendations: String
}
```

Error states: no API key configured (prompt to add in Settings), API error (show message, allow retry), parse failure (show raw response, allow manual entry).

---

## File Structure

### New files
```
Home/Pets/
├── Models/
│   ├── Veterinarian.swift
│   ├── Appointment.swift
│   ├── ClinicalEntry.swift
│   ├── PetEvent.swift
│   └── PetFile.swift
├── Store/
│   ├── AppData.swift
│   └── DataStore.swift
├── Detail/
│   ├── PetDetailView.swift
│   ├── Tabs/
│   │   ├── VetTabView.swift
│   │   ├── AppointmentsTabView.swift
│   │   ├── ClinicalHistoryTabView.swift
│   │   ├── EventsTabView.swift
│   │   └── FilesTabView.swift
│   └── Sheets/
│       ├── VetEditSheet.swift
│       ├── AddAppointmentSheet.swift
│       ├── AddClinicalEntrySheet.swift
│       ├── AddEventSheet.swift
│       ├── ClinicalEntryDetailView.swift
│       └── EventDetailView.swift
├── Files/
│   ├── FilePickerCoordinator.swift
│   └── FilePreviewView.swift
└── Claude/
    └── ExtractionService.swift
```

### Modified files
- `Pet.swift` — add `photoFilename: String?`
- `PetsView.swift` — add `NavigationLink` to `PetDetailView`
- `SettingsView.swift` — add Claude API key row (Keychain)
- `HomeApp.swift` — inject `DataStore` into environment

---

## Out of Scope (this iteration)

- iCloud sync
- Push notifications for appointments
- Multiple vets per pet
- Sharing / exporting records
- Claude API auto-extraction on file add
