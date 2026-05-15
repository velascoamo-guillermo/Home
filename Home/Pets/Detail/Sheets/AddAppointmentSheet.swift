import SwiftUI

struct AddAppointmentSheet: View {
    let petId: UUID
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var date: Date = .now
    @State private var reason: String = ""
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date & Time", selection: $date)
                Section("Details") {
                    TextField("Reason for visit", text: $reason)
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("New Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { save() }.disabled(reason.isEmpty)
                }
            }
        }
    }

    private func save() {
        let appt = Appointment(petId: petId, date: date, reason: reason, notes: notes, status: .upcoming)
        store.data.appointments.append(appt)
        store.save()
        dismiss()
    }
}
