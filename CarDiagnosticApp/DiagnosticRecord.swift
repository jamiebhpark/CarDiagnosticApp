import Foundation

struct DiagnosticRecord: Identifiable {
    let id = UUID()  // 고유 ID를 부여하여 Identifiable 준수
    let date: Date
    let engineTemperature: Double
    let batteryLevel: Double
    let fuelEfficiency: Double
}
