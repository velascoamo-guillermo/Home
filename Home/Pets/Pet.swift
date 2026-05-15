import Foundation

struct Pet: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var type: String
    var breed: String
    var photoFilename: String? = nil
}
