import SwiftUI

struct PetRow: View {
    let pet: Pet

    var body: some View {
        HStack(spacing: 12) {
            PetAvatarView(pet: pet, size: 48)

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
}
