import SwiftUI

struct PetAvatarView: View {
    let pet: Pet
    let size: CGFloat

    var body: some View {
        Group {
            if let urlString = pet.photoUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(.circle)
    }

    private var symbolName: String {
        switch pet.type {
        case "Dog": "dog.fill"
        case "Cat": "cat.fill"
        default:    "pawprint.fill"
        }
    }

    private var placeholder: some View {
        Circle()
            .fill(.tint.opacity(0.12))
            .overlay {
                Image(systemName: symbolName)
                    .font(.system(size: size * 0.4))
                    .foregroundStyle(.tint)
            }
    }
}
