import Foundation

struct WarningLog: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let type: String
    let message: String
}
