import Foundation

struct BatteryUsage: Identifiable {
    let id = UUID()
    let date: Date
    let batteryLevel: Double
}
