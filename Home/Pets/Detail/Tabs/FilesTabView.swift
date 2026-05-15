import SwiftUI

struct FilesTabView: View {
    let pet: Pet
    @Environment(DataStore.self) private var store
    @State private var showFilePicker = false
    @State private var selectedFile: PetFile? = nil

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 8)]
    var standaloneFiles: [PetFile] { store.files(for: pet.id, linkedTo: .standalone) }

    var body: some View {
        ScrollView {
            if standaloneFiles.isEmpty {
                ContentUnavailableView("No Files", systemImage: "folder",
                    description: Text("Add vet reports, photos, and other documents."))
                    .padding(.top, 60)
            } else {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(standaloneFiles) { file in
                        FileGridCell(file: file, fileURL: store.fileURL(for: file))
                            .onTapGesture { selectedFile = file }
                            .contextMenu {
                                Button("Delete", role: .destructive) { store.deleteFile(file) }
                            }
                    }
                }
                .padding()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", systemImage: "plus") { showFilePicker = true }
            }
        }
        .sheet(isPresented: $showFilePicker) {
            FilePickerCoordinator { data, ext in
                _ = try? store.saveFile(data: data, ext: ext, petId: pet.id, linkedTo: .standalone)
            }
        }
        .sheet(item: $selectedFile) { file in FilePreviewView(file: file, pet: pet) }
    }
}

private struct FileGridCell: View {
    let file: PetFile
    let fileURL: URL

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(.regularMaterial)
            .frame(height: 100)
            .overlay {
                if file.sourceType == .document || file.sourceType == .scan {
                    Image(systemName: "doc.fill")
                        .font(.largeTitle).foregroundStyle(.secondary)
                } else if let image = loadImage() {
                    Image(uiImage: image).resizable().scaledToFill().clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Image(systemName: "photo").font(.largeTitle).foregroundStyle(.secondary)
                }
            }
    }

    private func loadImage() -> UIImage? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
}
