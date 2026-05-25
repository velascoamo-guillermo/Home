import SwiftUI

struct PetAvatarView: View {
    let pet: Pet
    let size: CGFloat

    var body: some View {
        Group {
            if let urlString = pet.photoUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    placeholder
                }
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(.circle)
    }

    private var placeholder: some View {
        Circle()
            .fill(.tint.opacity(0.12))
            .overlay {
                Image(systemName: pet.type == "Dog" ? "dog.fill" : "cat.fill")
                    .font(.system(size: size * 0.4))
                    .foregroundStyle(.tint)
            }
    }
}
