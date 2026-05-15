import SwiftUI
import PDFKit

struct FilePreviewView: View {
    let file: PetFile
    let pet: Pet
    @Environment(DataStore.self) private var store
    @State private var showExtraction = false

    private var fileURL: URL { store.fileURL(for: file) }
    private var canExtract: Bool { file.sourceType == .document || file.sourceType == .scan }

    var body: some View {
        NavigationStack {
            Group {
                if file.sourceType == .photo, let image = loadImage() {
                    ScrollView([.horizontal, .vertical]) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding()
                    }
                } else if file.sourceType == .document || file.sourceType == .scan {
                    PDFKitView(url: fileURL)
                } else {
                    ContentUnavailableView("Cannot Preview", systemImage: "doc.questionmark",
                        description: Text("This file type cannot be previewed."))
                }
            }
            .navigationTitle(file.filename)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if canExtract {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Extract Info", systemImage: "sparkles") {
                            showExtraction = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showExtraction) {
                ExtractionResultSheet(file: file, pet: pet)
            }
        }
    }

    private func loadImage() -> UIImage? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.document = PDFDocument(url: url)
        return view
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}
