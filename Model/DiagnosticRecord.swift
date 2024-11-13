import Foundation

struct DiagnosticRecord: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var engineTemperature: Double
    var batteryLevel: Double
    var fuelEfficiency: Double
    var tirePressure: Double
    var batteryVoltage: Double
    var fuelLevel: Double
    var intakeAirTemperature: Double
    var engineLoad: Double
    var oxygenSensor: Double
}
