import SwiftUI

struct ClinicalEntryDetailView: View {
    let entry: ClinicalEntry
    let pet: Pet
    @Environment(DataStore.self) private var store
    @State private var showFilePicker = false
    @State private var selectedFile: PetFile? = nil

    var files: [PetFile] { store.files(for: pet.id, linkedTo: .clinicalEntry(entry.id)) }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("Date") {
                        Text(entry.date.formatted(date: .long, time: .omitted))
                    }
                    if !entry.description.isEmpty {
                        Text(entry.description).font(.subheadline)
                    }
                }
                Section("Files") {
                    ForEach(files) { file in
                        Button { selectedFile = file } label: {
                            Label(file.filename, systemImage: file.sourceType == .document ? "doc.fill" : "photo.fill")
                        }
                        .swipeActions { Button("Delete", role: .destructive) { store.deleteFile(file) } }
                    }
                    Button { showFilePicker = true } label: {
                        Label("Add file", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle(entry.title)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showFilePicker) {
                FilePickerCoordinator { data, ext in
                    guard let i = store.data.clinicalEntries.firstIndex(where: { $0.id == entry.id }) else { return }
                    if let f = try? store.saveFile(data: data, ext: ext, petId: pet.id, linkedTo: .clinicalEntry(entry.id)) {
                        store.data.clinicalEntries[i].fileIds.append(f.id)
                        store.save()
                    }
                }
            }
            .sheet(item: $selectedFile) { file in
                FilePreviewView(file: file, pet: pet)
            }
        }
    }
}
