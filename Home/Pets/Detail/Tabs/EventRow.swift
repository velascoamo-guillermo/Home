import SwiftUI

struct EventRow: View {
    let event: PetEvent

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: event.category.icon)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title).font(.headline)
                HStack(spacing: 6) {
                    Text(event.date.formatted(date: .abbreviated, time: .omitted))
                    if let v = event.value {
                        Text("·")
                        Text(v)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }
}
