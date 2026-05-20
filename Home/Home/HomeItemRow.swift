import SwiftUI

struct HomeItemRow: View {
    let item: HomeItem

    private var isOverdue: Bool {
        item.dueDate < .now
    }

    private var relativeLabel: String {
        let cal   = Calendar.current
        let today = cal.startOfDay(for: .now)
        let due   = cal.startOfDay(for: item.dueDate)
        let days  = cal.dateComponents([.day], from: today, to: due).day ?? 0
        switch days {
        case 0:    return "Today"
        case 1:    return "Tomorrow"
        case 2...: return "in \(days) days"
        default:   return item.dueDate.formatted(date: .abbreviated, time: .omitted)
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundStyle(iconColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(relativeLabel)
                    .font(.caption.bold())
                    .foregroundStyle(isOverdue ? .red : .secondary)
                if isOverdue {
                    Text("Overdue")
                        .font(.caption2.bold())
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(.red.opacity(0.12), in: Capsule())
                        .foregroundStyle(.red)
                }
            }
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch item {
        case .appointment:  return "calendar"
        case .task(let t):  return t.icon
        }
    }

    private var iconColor: Color {
        switch item {
        case .appointment:  return .blue
        case .task:         return isOverdue ? .red : .orange
        }
    }

    private var title: String {
        switch item {
        case .appointment(let a, _): return a.reason
        case .task(let t):           return t.title
        }
    }

    private var subtitle: String {
        switch item {
        case .appointment(_, let p): return p.name
        case .task(let t):           return t.notes.isEmpty ? item.dueDate.formatted(date: .abbreviated, time: .omitted) : t.notes
        }
    }
}
