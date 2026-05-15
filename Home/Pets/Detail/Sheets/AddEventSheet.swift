import SwiftUI

struct AddEventSheet: View {
    let petId: UUID
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var date: Date = .now
    @State private var title: String = ""
    @State private var category: EventCategory = .other
    @State private var notes: String = ""
    @State private var value: String = ""
    @State private var showFilePicker = false
    @State private var attachedFiles: [PetFile] = []

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                Section("Event") {
                    TextField("Title", text: $title)
                    Picker("Category", selection: $category) {
                        ForEach(EventCategory.allCases, id: \.self) { cat in
                            Label(cat.label, systemImage: cat.icon).tag(cat)
                        }
                    }
                    if category == .weight {
                        TextField("Value (e.g. 4.2 kg)", text: $value)
                    }
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
                Section("Files") {
                    Button { showFilePicker = true } label: {
                        Label("Attach file", systemImage: "plus.circle")
                    }
                    ForEach(attachedFiles) { file in
                        Label(file.filename, systemImage: file.sourceType == .document ? "doc.fill" : "photo.fill")
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { save() }.disabled(title.isEmpty)
                }
            }
            .sheet(isPresented: $showFilePicker) {
                FilePickerCoordinator { data, ext in
                    if let f = try? store.saveFile(data: data, ext: ext, petId: petId, linkedTo: .standalone) {
                        attachedFiles.append(f)
                    }
                }
            }
        }
    }

    private func save() {
        var event = PetEvent(
            petId: petId, date: date, title: title, category: category,
            notes: notes, value: value.isEmpty ? nil : value, fileIds: []
        )
        for file in attachedFiles {
            guard let i = store.data.files.firstIndex(where: { $0.id == file.id }) else { continue }
            store.data.files[i].linkedTo = .event(event.id)
            event.fileIds.append(file.id)
        }
        store.data.events.append(event)
        store.save()
        dismiss()
    }
}
