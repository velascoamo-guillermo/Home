# Home Timeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the placeholder HomeView with a unified timeline feed showing upcoming pet appointments and periodical household tasks sorted by due date.

**Architecture:** Tagged `HomeItem` enum wraps both `Appointment+Pet` and `HouseholdTask`; a computed `homeTimeline` property on `SupabaseStore` merges and sorts them. `HomeView` renders a single `List` from that property with swipe actions for task management.

**Tech Stack:** SwiftUI, Swift 6 strict concurrency (`@MainActor` default), Swift Testing, Supabase Swift SDK, EventKit.

---

## File Map

| Action | Path |
|---|---|
| Create | `Home/Home/Home/HouseholdTask.swift` |
| Create | `Home/Home/Home/HomeItem.swift` |
| Modify | `Home/Home/Shared/Services/CalendarService.swift` |
| Modify | `Home/Home/Shared/Services/SupabaseStore.swift` |
| Modify | `HomeTests/SupabaseStoreTests.swift` |
| Create | `Home/Home/Home/HomeItemRow.swift` |
| Create | `Home/Home/Home/HouseholdTaskSheet.swift` |
| Modify | `Home/Home/Home/HomeView.swift` |

---

## Task 1: Create Supabase `household_tasks` table

**Files:** none (Supabase dashboard or CLI)

- [ ] **Step 1: Run SQL in Supabase dashboard**

Open your project at supabase.com → SQL Editor → run:

```sql
create table household_tasks (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  icon text not null,
  interval_days int not null,
  next_due_date timestamptz not null,
  notes text not null default ''
);

-- Enable RLS (allow all for now — tighten per your auth policy)
alter table household_tasks enable row level security;
create policy "allow all" on household_tasks for all using (true);
```

- [ ] **Step 2: Verify**

In Supabase Table Editor, confirm `household_tasks` appears with the correct columns.

---

## Task 2: `HouseholdTask` model

**Files:**
- Create: `Home/Home/Home/HouseholdTask.swift`

- [ ] **Step 1: Create the file**

```swift
import Foundation

struct HouseholdTask: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var title: String
    var icon: String
    var intervalDays: Int
    var nextDueDate: Date
    var notes: String = ""

    enum CodingKeys: String, CodingKey {
        case id, title, icon, notes
        case intervalDays = "interval_days"
        case nextDueDate  = "next_due_date"
    }
}
```

- [ ] **Step 2: Build**

```bash
xcodebuild -project "Home.xcodeproj" -scheme Home \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build 2>&1 | grep -E "BUILD|error:"
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Commit**

```bash
git add "Home/Home/Home/HouseholdTask.swift"
git commit -m "feat: add HouseholdTask model"
```

---

## Task 3: `HomeItem` enum

**Files:**
- Create: `Home/Home/Home/HomeItem.swift`

- [ ] **Step 1: Create the file**

```swift
import Foundation

enum HomeItem: Identifiable {
    case appointment(Appointment, Pet)
    case task(HouseholdTask)

    var id: UUID {
        switch self {
        case .appointment(let a, _): return a.id
        case .task(let t):           return t.id
        }
    }

    var dueDate: Date {
        switch self {
        case .appointment(let a, _): return a.date
        case .task(let t):           return t.nextDueDate
        }
    }
}
```

- [ ] **Step 2: Build**

```bash
xcodebuild -project "Home.xcodeproj" -scheme Home \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build 2>&1 | grep -E "BUILD|error:"
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Commit**

```bash
git add "Home/Home/Home/HomeItem.swift"
git commit -m "feat: add HomeItem enum"
```

---

## Task 4: `CalendarService` — add household task support

**Files:**
- Modify: `Home/Home/Shared/Services/CalendarService.swift`

- [ ] **Step 1: Add `addHouseholdTask` method**

Append inside the `enum CalendarService` body, after `addPetEvent`:

```swift
@discardableResult
static func addHouseholdTask(_ task: HouseholdTask) async -> Bool {
    guard await requestAccess() else { return false }
    let event = EKEvent(eventStore: store)
    event.title = task.title
    event.startDate = task.nextDueDate
    event.endDate = task.nextDueDate
    event.isAllDay = true
    event.notes = task.notes.isEmpty ? nil : task.notes
    event.calendar = store.defaultCalendarForNewEvents
    do {
        try store.save(event, span: .thisEvent)
        return true
    } catch {
        return false
    }
}
```

- [ ] **Step 2: Build**

```bash
xcodebuild -project "Home.xcodeproj" -scheme Home \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build 2>&1 | grep -E "BUILD|error:"
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Commit**

```bash
git add "Home/Home/Shared/Services/CalendarService.swift"
git commit -m "feat: add CalendarService.addHouseholdTask"
```

---

## Task 5: `SupabaseStore` — `householdTasks` property + CRUD

**Files:**
- Modify: `Home/Home/Shared/Services/SupabaseStore.swift`

- [ ] **Step 1: Add stored property**

After `var files: [PetFile] = []` (line 16), add:

```swift
var householdTasks: [HouseholdTask] = []
```

- [ ] **Step 2: Load in `loadAll()`**

Inside `loadAll()`, add a new `async let` alongside the existing ones:

```swift
async let ht: [HouseholdTask] = client.from("household_tasks").select().execute().value
```

Then add to the assignment block:

```swift
householdTasks = try await ht
```

- [ ] **Step 3: Add CRUD methods**

Append a new `// MARK: - Household Tasks` section at the end of the class body (before the closing `}`):

```swift
// MARK: - Household Tasks

func addTask(_ task: HouseholdTask) async throws {
    try await client.from("household_tasks").insert(task).execute()
    householdTasks.append(task)
}

func updateTask(_ task: HouseholdTask) async throws {
    try await client.from("household_tasks").update(task).eq("id", value: task.id).execute()
    if let i = householdTasks.firstIndex(where: { $0.id == task.id }) {
        householdTasks[i] = task
    }
}

func deleteTask(_ task: HouseholdTask) async throws {
    try await client.from("household_tasks").delete().eq("id", value: task.id).execute()
    householdTasks.removeAll { $0.id == task.id }
}
```

- [ ] **Step 4: Build**

```bash
xcodebuild -project "Home.xcodeproj" -scheme Home \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build 2>&1 | grep -E "BUILD|error:"
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 5: Commit**

```bash
git add "Home/Home/Shared/Services/SupabaseStore.swift"
git commit -m "feat: add householdTasks storage and CRUD to SupabaseStore"
```

---

## Task 6: `SupabaseStore` — `homeTimeline` + tests

**Files:**
- Modify: `Home/Home/Shared/Services/SupabaseStore.swift`
- Modify: `HomeTests/SupabaseStoreTests.swift`

- [ ] **Step 1: Write failing tests first**

Append to `HomeTests/SupabaseStoreTests.swift` inside the existing `@Suite`:

```swift
@Test("homeTimeline sorts appointments and tasks by dueDate")
func homeTimelineSorted() {
    let store = SupabaseStore()
    let pet = Pet(name: "Rex", type: "dog", breed: "lab")
    store.pets = [pet]

    let sooner = Date.now.addingTimeInterval(3600)
    let later  = Date.now.addingTimeInterval(7200)

    store.appointments   = [Appointment(petId: pet.id, date: later,  reason: "checkup", notes: "", status: .upcoming)]
    store.householdTasks = [HouseholdTask(title: "Filter", icon: "drop", intervalDays: 90, nextDueDate: sooner)]

    let timeline = store.homeTimeline
    #expect(timeline.count == 2)
    #expect(timeline[0].dueDate <= timeline[1].dueDate)
}

@Test("homeTimeline excludes done and cancelled appointments")
func homeTimelineExcludesNonUpcoming() {
    let store = SupabaseStore()
    let pet = Pet(name: "Rex", type: "dog", breed: "lab")
    store.pets = [pet]
    store.appointments = [
        Appointment(petId: pet.id, date: .now, reason: "done",      notes: "", status: .done),
        Appointment(petId: pet.id, date: .now, reason: "cancelled",  notes: "", status: .cancelled),
        Appointment(petId: pet.id, date: .now, reason: "upcoming",   notes: "", status: .upcoming)
    ]
    #expect(store.homeTimeline.count == 1)
}

@Test("homeTimeline excludes appointment with missing pet")
func homeTimelineDropsOrphanedAppointment() {
    let store = SupabaseStore()
    store.pets = []
    store.appointments = [
        Appointment(petId: UUID(), date: .now, reason: "orphan", notes: "", status: .upcoming)
    ]
    #expect(store.homeTimeline.count == 0)
}
```

- [ ] **Step 2: Run tests — verify they fail**

```bash
xcodebuild test -project "Home.xcodeproj" -scheme Home \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | grep -E "passed|failed|error:|homeTimeline"
```

Expected: failures on the three new tests (symbol not found).

- [ ] **Step 3: Add `homeTimeline` to `SupabaseStore`**

Add inside `// MARK: - In-memory filters` section:

```swift
var homeTimeline: [HomeItem] {
    let appts = appointments
        .filter { $0.status == .upcoming }
        .compactMap { appt -> HomeItem? in
            guard let pet = pets.first(where: { $0.id == appt.petId }) else { return nil }
            return .appointment(appt, pet)
        }
    let tasks = householdTasks.map { HomeItem.task($0) }
    return (appts + tasks).sorted { $0.dueDate < $1.dueDate }
}
```

- [ ] **Step 4: Run tests — verify they pass**

```bash
xcodebuild test -project "Home.xcodeproj" -scheme Home \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | grep -E "passed|failed|error:"
```

Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add "Home/Home/Shared/Services/SupabaseStore.swift" \
        "HomeTests/SupabaseStoreTests.swift"
git commit -m "feat: add homeTimeline computed property with tests"
```

---

## Task 7: `HomeItemRow`

**Files:**
- Create: `Home/Home/Home/HomeItemRow.swift`

- [ ] **Step 1: Create the file**

```swift
import SwiftUI

struct HomeItemRow: View {
    let item: HomeItem

    private var isOverdue: Bool {
        item.dueDate < .now
    }

    private var relativeLabel: String {
        let cal  = Calendar.current
        let today = cal.startOfDay(for: .now)
        let due   = cal.startOfDay(for: item.dueDate)
        let days  = cal.dateComponents([.day], from: today, to: due).day ?? 0
        switch days {
        case 0:        return "Today"
        case 1:        return "Tomorrow"
        case 2...:     return "in \(days) days"
        default:       return item.dueDate.formatted(date: .abbreviated, time: .omitted)
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundStyle(iconColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(relativeLabel)
                    .font(.caption.bold())
                    .foregroundStyle(isOverdue ? .red : .secondary)
                if isOverdue {
                    Text("Overdue")
                        .font(.caption2.bold())
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(.red.opacity(0.12), in: Capsule())
                        .foregroundStyle(.red)
                }
            }
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch item {
        case .appointment:      return "calendar"
        case .task(let t):      return t.icon
        }
    }

    private var iconColor: Color {
        switch item {
        case .appointment:      return .blue
        case .task:             return isOverdue ? .red : .orange
        }
    }

    private var title: String {
        switch item {
        case .appointment(let a, _): return a.reason
        case .task(let t):           return t.title
        }
    }

    private var subtitle: String {
        switch item {
        case .appointment(_, let p): return p.name
        case .task(let t):           return t.notes.isEmpty ? item.dueDate.formatted(date: .abbreviated, time: .omitted) : t.notes
        }
    }
}
```

- [ ] **Step 2: Build**

```bash
xcodebuild -project "Home.xcodeproj" -scheme Home \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build 2>&1 | grep -E "BUILD|error:"
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Commit**

```bash
git add "Home/Home/Home/HomeItemRow.swift"
git commit -m "feat: add HomeItemRow"
```

---

## Task 8: `HouseholdTaskSheet` (add + edit)

**Files:**
- Create: `Home/Home/Home/HouseholdTaskSheet.swift`

- [ ] **Step 1: Create the file**

```swift
import SwiftUI

struct HouseholdTaskSheet: View {
    @Environment(SupabaseStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let existing: HouseholdTask?

    @State private var title = ""
    @State private var icon = "wrench"
    @State private var intervalValue = 1
    @State private var intervalUnit  = IntervalUnit.months
    @State private var nextDueDate   = Date.now
    @State private var notes = ""

    private var isEditing: Bool { existing != nil }

    init(existing: HouseholdTask? = nil) {
        self.existing = existing
        if let t = existing {
            _title         = State(initialValue: t.title)
            _icon          = State(initialValue: t.icon)
            _nextDueDate   = State(initialValue: t.nextDueDate)
            _notes         = State(initialValue: t.notes)
            let (val, unit) = IntervalUnit.decompose(days: t.intervalDays)
            _intervalValue = State(initialValue: val)
            _intervalUnit  = State(initialValue: unit)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("Name", text: $title)
                    Picker("Icon", selection: $icon) {
                        ForEach(Self.iconOptions, id: \.self) { sym in
                            Label(sym, systemImage: sym).tag(sym)
                        }
                    }
                }

                Section("Schedule") {
                    DatePicker("Due date", selection: $nextDueDate, displayedComponents: .date)
                    HStack {
                        Text("Repeat every")
                        Spacer()
                        Stepper("\(intervalValue)", value: $intervalValue, in: 1...99)
                        Picker("", selection: $intervalUnit) {
                            ForEach(IntervalUnit.allCases) { unit in
                                Text(unit.label).tag(unit)
                            }
                        }
                        .labelsHidden()
                        .fixedSize()
                    }
                }

                Section("Notes") {
                    TextField("Optional", text: $notes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        var task = existing ?? HouseholdTask(title: "", icon: icon, intervalDays: 1, nextDueDate: nextDueDate)
        task.title        = title.trimmingCharacters(in: .whitespaces)
        task.icon         = icon
        task.intervalDays = intervalUnit.toDays(intervalValue)
        task.nextDueDate  = nextDueDate
        task.notes        = notes.trimmingCharacters(in: .whitespaces)

        Task {
            if isEditing {
                try? await store.updateTask(task)
            } else {
                try? await store.addTask(task)
            }
        }
        dismiss()
    }

    static let iconOptions: [String] = [
        "wrench", "drop", "flame", "fan", "lightbulb",
        "trash", "shippingbox", "hammer", "leaf", "air.purifier"
    ]
}

// MARK: - IntervalUnit

private enum IntervalUnit: String, CaseIterable, Identifiable {
    case days, weeks, months

    var id: String { rawValue }
    var label: String { rawValue.capitalized }

    func toDays(_ value: Int) -> Int {
        switch self {
        case .days:   return value
        case .weeks:  return value * 7
        case .months: return value * 30
        }
    }

    static func decompose(days: Int) -> (Int, IntervalUnit) {
        if days % 30 == 0 { return (days / 30, .months) }
        if days % 7  == 0 { return (days / 7,  .weeks)  }
        return (days, .days)
    }
}
```

- [ ] **Step 2: Build**

```bash
xcodebuild -project "Home.xcodeproj" -scheme Home \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build 2>&1 | grep -E "BUILD|error:"
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Commit**

```bash
git add "Home/Home/Home/HouseholdTaskSheet.swift"
git commit -m "feat: add HouseholdTaskSheet for add and edit"
```

---

## Task 9: Overhaul `HomeView`

**Files:**
- Modify: `Home/Home/Home/HomeView.swift`

- [ ] **Step 1: Replace file contents**

```swift
import SwiftUI

struct HomeView: View {
    @Environment(SupabaseStore.self) private var store
    @State private var showAdd = false
    @State private var editingTask: HouseholdTask? = nil

    var body: some View {
        NavigationStack {
            Group {
                if store.homeTimeline.isEmpty {
                    ContentUnavailableView(
                        "Nothing scheduled",
                        systemImage: "calendar.badge.clock",
                        description: Text("Add a household task or schedule a pet appointment.")
                    )
                } else {
                    List {
                        ForEach(store.homeTimeline) { item in
                            HomeItemRow(item: item)
                                .contentShape(Rectangle())
                                .onTapGesture { handleTap(item) }
                                .swipeActions(edge: .leading) {
                                    if case .task(let t) = item {
                                        Button {
                                            markDone(t)
                                        } label: {
                                            Label("Done", systemImage: "checkmark")
                                        }
                                        .tint(.green)
                                    }
                                }
                                .swipeActions(edge: .trailing) {
                                    if case .task(let t) = item {
                                        Button(role: .destructive) {
                                            Task { try? await store.deleteTask(t) }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }

                                        Button {
                                            snooze(t)
                                        } label: {
                                            Label("Snooze", systemImage: "clock.arrow.circlepath")
                                        }
                                        .tint(.orange)

                                        Button {
                                            Task { await CalendarService.addHouseholdTask(t) }
                                        } label: {
                                            Label("Calendar", systemImage: "calendar.badge.plus")
                                        }
                                        .tint(.blue)
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add task", systemImage: "plus") { showAdd = true }
                }
            }
            .sheet(isPresented: $showAdd) {
                HouseholdTaskSheet()
            }
            .sheet(item: $editingTask) { task in
                HouseholdTaskSheet(existing: task)
            }
        }
    }

    private func handleTap(_ item: HomeItem) {
        if case .task(let t) = item { editingTask = t }
    }

    private func markDone(_ task: HouseholdTask) {
        var updated = task
        updated.nextDueDate = Calendar.current.date(
            byAdding: .day, value: task.intervalDays, to: .now
        ) ?? .now
        Task { try? await store.updateTask(updated) }
    }

    private func snooze(_ task: HouseholdTask) {
        var updated = task
        updated.nextDueDate = Calendar.current.date(byAdding: .day, value: 1, to: task.nextDueDate) ?? task.nextDueDate
        Task { try? await store.updateTask(updated) }
    }
}

#Preview {
    HomeView()
        .environment(SupabaseStore())
}
```

- [ ] **Step 2: Build**

```bash
xcodebuild -project "Home.xcodeproj" -scheme Home \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build 2>&1 | grep -E "BUILD|error:"
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Run all tests**

```bash
xcodebuild test -project "Home.xcodeproj" -scheme Home \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | grep -E "passed|failed|error:"
```

Expected: all tests pass.

- [ ] **Step 4: Commit**

```bash
git add "Home/Home/Home/HomeView.swift"
git commit -m "feat: replace HomeView placeholder with unified timeline feed"
```
