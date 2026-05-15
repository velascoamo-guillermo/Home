import Foundation

struct Pet: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let breed: String
}
