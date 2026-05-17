import Foundation

struct Veterinarian: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var clinicName: String
    var phone: String
    var address: String
    var schedule: String
    var notes: String

    enum CodingKeys: String, CodingKey {
        case id, name, phone, address, schedule, notes
        case clinicName = "clinic_name"
    }
}
