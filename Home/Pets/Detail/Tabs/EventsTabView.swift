import SwiftUI

struct EventsTabView: View {
    let pet: Pet
    @Environment(DataStore.self) private var store
    @State private var showAdd = false
    @State private var selectedEvent: PetEvent? = nil

    var events: [PetEvent] { store.events(for: pet.id) }

    var body: some View {
        List {
            if events.isEmpty {
                ContentUnavailableView("No Events", systemImage: "list.bullet",
                    description: Text("Track vaccines, grooming, medications and more."))
                    .listRowBackground(Color.clear)
            }
            ForEach(events) { event in
                Button { selectedEvent = event } label: { EventRow(event: event) }
                    .buttonStyle(.plain)
                    .swipeActions { Button("Delete", role: .destructive) { delete(event) } }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", systemImage: "plus") { showAdd = true }
            }
        }
        .sheet(isPresented: $showAdd) { AddEventSheet(petId: pet.id) }
        .sheet(item: $selectedEvent) { event in EventDetailView(event: event, pet: pet) }
    }

    private func delete(_ event: PetEvent) {
        store.files(for: pet.id, linkedTo: .event(event.id)).forEach { store.deleteFile($0) }
        store.data.events.removeAll { $0.id == event.id }
        store.save()
    }
}
