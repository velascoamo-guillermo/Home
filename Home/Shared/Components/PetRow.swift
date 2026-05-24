import SwiftUI

struct PetRow: View {
    let pet: Pet

    var body: some View {
        HStack(spacing: 12) {
            thumbnail
                .frame(width: 48, height: 48)
                .clipShape(.circle)

            VStack(alignment: .leading, spacing: 2) {
                Text(pet.name)
                    .font(.headline)
                Text("\(pet.breed) • \(pet.type)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let urlString = pet.photoUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                iconPlaceholder
            }
        } else {
            iconPlaceholder
        }
    }

    private var iconPlaceholder: some View {
        Circle()
            .fill(.tint.opacity(0.12))
            .overlay {
                Image(systemName: pet.type == "Dog" ? "dog.fill" : "cat.fill")
                    .font(.title3)
                    .foregroundStyle(.tint)
            }
    }
}
