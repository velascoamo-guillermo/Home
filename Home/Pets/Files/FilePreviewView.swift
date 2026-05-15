// Stub — replaced in Task 11
import SwiftUI

struct FilePreviewView: View {
    let file: PetFile
    let pet: Pet
    var body: some View { Text(file.filename).navigationTitle("Preview") }
}
