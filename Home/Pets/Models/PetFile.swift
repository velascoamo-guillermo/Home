import Foundation

enum FileSourceType: String, Codable, Hashable {
    case photo, document, scan
}

struct PetFile: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var petId: UUID
    var storagePath: String
    var sourceType: FileSourceType
    var linkedToType: String   // "event" | "clinicalEntry" | "standalone"
    var linkedToId: UUID?
    var createdAt: Date

    var displayName: String {
        URL(string: storagePath)?.lastPathComponent ?? storagePath
    }

    enum CodingKeys: String, CodingKey {
        case id
        case petId = "pet_id"
        case storagePath = "storage_path"
        case sourceType = "source_type"
        case linkedToType = "linked_to_type"
        case linkedToId = "linked_to_id"
        case createdAt = "created_at"
    }
}
