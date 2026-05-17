import Foundation

struct Pet: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var type: String
    var breed: String
    var photoUrl: String? = nil

    enum CodingKeys: String, CodingKey {
        case id, name, type, breed
        case photoUrl = "photo_url"
    }
}
