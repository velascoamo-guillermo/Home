// Home/Pets/PetsView.swift
import SwiftUI

struct PetsView: View {
    @Environment(DataStore.self) private var store
    @State private var showAddPet = false

    var body: some View {
        NavigationStack {
            List(store.data.pets) { pet in
                NavigationLink(value: pet) {
                    PetRow(pet: pet)
                }
                .swipeActions(edge: .trailing) {
                    Button("Delete", role: .destructive) { delete(pet) }
                }
            }
            .navigationTitle("My Pets")
            .navigationDestination(for: Pet.self) { pet in
                PetDetailView(pet: pet)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Pet", systemImage: "plus") {
                        showAddPet = true
                    }
                }
            }
            .sheet(isPresented: $showAddPet) {
                AddPetSheet()
            }
        }
    }

    private func delete(_ pet: Pet) {
        store.files(for: pet.id).forEach { store.deleteFile($0) }
        store.data.appointments.removeAll { $0.petId == pet.id }
        store.data.clinicalEntries.removeAll { $0.petId == pet.id }
        store.data.events.removeAll { $0.petId == pet.id }
        store.data.pets.removeAll { $0.id == pet.id }
        store.save()
    }
}

private struct AddPetSheet: View {
    @Environment(DataStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var type = "Dog"
    @State private var breed = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                Picker("Type", selection: $type) {
                    Text("Dog").tag("Dog")
                    Text("Cat").tag("Cat")
                    Text("Other").tag("Other")
                }
                TextField("Breed", text: $breed)
            }
            .navigationTitle("Add Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        store.data.pets.append(Pet(name: name, type: type, breed: breed))
                        store.save()
                        dismiss()
                    }
                    .disabled(name.isEmpty || breed.isEmpty)
                }
            }
        }
    }
}

#Preview {
    PetsView()
        .environment(DataStore())
}
