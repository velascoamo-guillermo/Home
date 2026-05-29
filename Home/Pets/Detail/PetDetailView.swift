import SwiftUI
import PhotosUI

enum PetDetailTab: String, CaseIterable {
    case vet = "Vet"
    case appointments = "Appointments"
    case history = "History"
    case events = "Events"
    case files = "Files"

    var icon: String {
        switch self {
        case .vet:          return "stethoscope"
        case .appointments: return "calendar"
        case .history:      return "clock.arrow.circlepath"
        case .events:       return "list.bullet"
        case .files:        return "folder"
        }
    }
}

struct PetDetailView: View {
    let pet: Pet
    @Environment(SupabaseStore.self) private var store
    @State private var selectedTab: PetDetailTab = .vet
    @State private var photoPickerItem: PhotosPickerItem? = nil
    @State private var isUploadingPhoto = false

    private var currentPet: Pet {
        store.pets.first(where: { $0.id == pet.id }) ?? pet
    }

    var body: some View {
        VStack(spacing: 0) {
            petHeader
            tabPicker
            tabContent
        }
        .navigationTitle(currentPet.name)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: photoPickerItem) { _, item in
            guard let item else { return }
            Task {
                isUploadingPhoto = true
                if let data = try? await item.loadTransferable(type: Data.self) {
                    try? await store.updatePetPhoto(currentPet, imageData: data)
                }
                isUploadingPhoto = false
                photoPickerItem = nil
            }
        }
    }

    private var petHeader: some View {
        VStack(spacing: 8) {
            PhotosPicker(selection: $photoPickerItem, matching: .images) {
                ZStack {
                    petPhoto
                        .frame(width: 84, height: 84)
                        .clipShape(.circle)

                    if isUploadingPhoto {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 84, height: 84)
                        ProgressView()
                    }

                    Image(systemName: "camera.circle.fill")
                        .font(.title3)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .tint)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .frame(width: 84, height: 84)
                        .offset(x: 4, y: 4)
                }
            }
            .accessibilityLabel("Change pet photo")

            Text(currentPet.name)
                .font(.title2.bold())

            Text("\(currentPet.breed) · \(currentPet.type)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let birthday = currentPet.birthday {
                Label(birthday.formatted(date: .abbreviated, time: .omitted),
                      systemImage: "birthday.cake")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private var petPhoto: some View {
        if let urlString = currentPet.photoUrl, let url = URL(string: urlString) {
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
                Image(systemName: currentPet.type == "Dog" ? "dog.fill" : "cat.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(.tint)
            }
    }

    private var tabPicker: some View {
        HStack(spacing: 0) {
            ForEach(PetDetailTab.allCases, id: \.self) { tab in
                let selected = selectedTab == tab
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 15, weight: selected ? .semibold : .regular))
                        Text(tab.rawValue)
                            .font(.caption2)
                            .fontWeight(selected ? .semibold : .regular)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .foregroundStyle(selected ? Color.accentColor : Color.secondary)
                }
                .overlay(alignment: .bottom) {
                    if selected {
                        Rectangle()
                            .frame(height: 2)
                            .foregroundStyle(.tint)
                    }
                }
            }
        }
        .background(.bar)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .vet:          VetTabView(pet: currentPet)
        case .appointments: AppointmentsTabView(pet: currentPet)
        case .history:      ClinicalHistoryTabView(pet: currentPet)
        case .events:       EventsTabView(pet: currentPet)
        case .files:        FilesTabView(pet: currentPet)
        }
    }
}

#Preview {
    NavigationStack {
        PetDetailView(pet: Pet(name: "Luna", type: "Dog", breed: "Golden Retriever"))
    }
    .environment(SupabaseStore())
}
