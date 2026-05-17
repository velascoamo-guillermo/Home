import Foundation

struct ClinicalEntry: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var petId: UUID
    var date: Date
    var title: String
    var description: String

    enum CodingKeys: String, CodingKey {
        case id, date, title, description
        case petId = "pet_id"
    }
}
