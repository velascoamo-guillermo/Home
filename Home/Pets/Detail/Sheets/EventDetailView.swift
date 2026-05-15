import SwiftUI

struct EventDetailView: View {
    let event: PetEvent
    let pet: Pet
    @Environment(DataStore.self) private var store
    @State private var showFilePicker = false
    @State private var selectedFile: PetFile? = nil

    var files: [PetFile] { store.files(for: pet.id, linkedTo: .event(event.id)) }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("Category") { Label(event.category.label, systemImage: event.category.icon) }
                    LabeledContent("Date") { Text(event.date.formatted(date: .long, time: .omitted)) }
                    if let v = event.value { LabeledContent("Value", value: v) }
                    if !event.notes.isEmpty { Text(event.notes).font(.subheadline) }
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
            .navigationTitle(event.title)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showFilePicker) {
                FilePickerCoordinator { data, ext in
                    guard let i = store.data.events.firstIndex(where: { $0.id == event.id }) else { return }
                    if let f = try? store.saveFile(data: data, ext: ext, petId: pet.id, linkedTo: .event(event.id)) {
                        store.data.events[i].fileIds.append(f.id)
                        store.save()
                    }
                }
            }
            .sheet(item: $selectedFile) { file in FilePreviewView(file: file, pet: pet) }
        }
    }
}
