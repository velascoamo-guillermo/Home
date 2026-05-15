import Foundation

struct ClinicalEntry: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var petId: UUID
    var date: Date
    var title: String
    var description: String
    var fileIds: [UUID]
}
