import Foundation

struct DataPoint: Identifiable {
    let id = UUID()
    let time: Date
    let value: Double
}
