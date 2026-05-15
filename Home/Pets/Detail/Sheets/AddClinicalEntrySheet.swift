import SwiftUI

struct AddClinicalEntrySheet: View {
    let petId: UUID
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var date: Date = .now
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var showFilePicker = false
    @State private var attachedFiles: [PetFile] = []

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                Section("Entry") {
                    TextField("Title (e.g. Annual checkup)", text: $title)
                    TextField("Diagnosis / findings", text: $description, axis: .vertical)
                        .lineLimit(3...6)
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
            .navigationTitle("New Entry")
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
        var entry = ClinicalEntry(petId: petId, date: date, title: title, description: description, fileIds: [])
        // Relink files to this entry
        for file in attachedFiles {
            guard let i = store.data.files.firstIndex(where: { $0.id == file.id }) else { continue }
            store.data.files[i].linkedTo = .clinicalEntry(entry.id)
            entry.fileIds.append(file.id)
        }
        store.data.clinicalEntries.append(entry)
        store.save()
        dismiss()
    }
}
