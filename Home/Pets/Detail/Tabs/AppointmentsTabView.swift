import SwiftUI

struct AppointmentsTabView: View {
    let pet: Pet
    @Environment(DataStore.self) private var store
    @State private var showAdd = false

    private var upcoming: [Appointment] {
        store.appointments(for: pet.id).filter { $0.status == .upcoming }.sorted { $0.date < $1.date }
    }
    private var past: [Appointment] {
        store.appointments(for: pet.id).filter { $0.status != .upcoming }.sorted { $0.date > $1.date }
    }

    var body: some View {
        List {
            if upcoming.isEmpty && past.isEmpty {
                ContentUnavailableView("No Appointments", systemImage: "calendar.badge.plus",
                    description: Text("Tap + to schedule a visit."))
                    .listRowBackground(Color.clear)
            }
            if !upcoming.isEmpty {
                Section("Upcoming") {
                    ForEach(upcoming) { appt in
                        AppointmentRow(appointment: appt)
                            .swipeActions(edge: .trailing) {
                                Button("Cancel", role: .destructive) { setStatus(appt, .cancelled) }
                                Button("Done") { setStatus(appt, .done) }.tint(.green)
                            }
                    }
                }
            }
            if !past.isEmpty {
                Section("Past") {
                    ForEach(past) { appt in
                        AppointmentRow(appointment: appt)
                            .swipeActions { Button("Delete", role: .destructive) { delete(appt) } }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", systemImage: "plus") { showAdd = true }
            }
        }
        .sheet(isPresented: $showAdd) {
            AddAppointmentSheet(petId: pet.id)
        }
    }

    private func setStatus(_ appt: Appointment, _ status: AppointmentStatus) {
        guard let i = store.data.appointments.firstIndex(where: { $0.id == appt.id }) else { return }
        store.data.appointments[i].status = status
        store.save()
    }

    private func delete(_ appt: Appointment) {
        store.data.appointments.removeAll { $0.id == appt.id }
        store.save()
    }
}

private struct AppointmentRow: View {
    let appointment: Appointment

    private var statusColor: Color {
        switch appointment.status {
        case .upcoming:   return .blue
        case .done:       return .green
        case .cancelled:  return .red
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.reason).font(.headline)
                Text(appointment.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption).foregroundStyle(.secondary)
                if !appointment.notes.isEmpty {
                    Text(appointment.notes).font(.caption2).foregroundStyle(.tertiary)
                }
            }
            Spacer()
            Text(appointment.status.rawValue.capitalized)
                .font(.caption2.bold())
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(statusColor.opacity(0.15), in: Capsule())
                .foregroundStyle(statusColor)
        }
    }
}
