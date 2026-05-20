import Foundation

struct HouseholdTask: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var title: String
    var icon: String
    var intervalDays: Int
    var nextDueDate: Date
    var notes: String = ""

    enum CodingKeys: String, CodingKey {
        case id, title, icon, notes
        case intervalDays = "interval_days"
        case nextDueDate  = "next_due_date"
    }
}
