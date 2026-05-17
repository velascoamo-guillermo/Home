import Foundation

enum AppointmentStatus: String, Codable, CaseIterable, Hashable {
    case upcoming, done, cancelled
}

struct Appointment: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var petId: UUID
    var date: Date
    var reason: String
    var notes: String
    var status: AppointmentStatus

    enum CodingKeys: String, CodingKey {
        case id, date, reason, notes, status
        case petId = "pet_id"
    }
}
