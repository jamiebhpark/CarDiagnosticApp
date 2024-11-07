import SwiftUI

struct DetailedDiagnosticView: View {
    @ObservedObject var carData: CarData
    private var carStatusManager: CarStatusManager
    
    init(carData: CarData) {
        self.carData = carData
        self.carStatusManager = CarStatusManager(settings: carData.settings)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Detailed Car Diagnostic")
                .font(.title)
                .padding()
            
            VStack(spacing: 10) {
                // Engine Temperature
                HStack {
                    Text("Engine Temperature:")
                    Spacer()
                    let engineStatus = carStatusManager.evaluateEngineTemperature(carData.engineTemperature)
                    let engineStatusColor = engineStatus != nil ? Color.red : Color.green
                    Text("\(carData.engineTemperature, specifier: "%.1f") °C")
                        .foregroundColor(engineStatusColor)
                }
                
                // Battery Level
                HStack {
                    Text("Battery Level:")
                    Spacer()
                    let batteryStatus = carStatusManager.evaluateBatteryLevel(carData.batteryLevel)
                    let batteryStatusColor = batteryStatus != nil ? Color.orange : Color.green
                    Text("\(carData.batteryLevel, specifier: "%.1f") %")
                        .foregroundColor(batteryStatusColor)
                }
                
                // Fuel Efficiency
                HStack {
                    Text("Fuel Efficiency:")
                    Spacer()
                    Text("\(carData.fuelEfficiency, specifier: "%.1f") km/l")
                        .foregroundColor(carData.fuelEfficiency < 10 ? .orange : .primary)
                }
                
                // Tire Pressure
                HStack {
                    Text("Tire Pressure:")
                    Spacer()
                    let tireStatus = carStatusManager.evaluateTirePressure(carData.tirePressure)
                    let tireStatusColor = tireStatus != nil ? Color.red : Color.green
                    Text("\(carData.tirePressure, specifier: "%.1f") PSI")
                        .foregroundColor(tireStatusColor)
                }
                
                // Battery Voltage
                HStack {
                    Text("Battery Voltage:")
                    Spacer()
                    let voltageStatus = carStatusManager.evaluateBatteryVoltage(carData.batteryVoltage)
                    let voltageStatusColor = voltageStatus != nil ? Color.orange : Color.primary
                    Text("\(carData.batteryVoltage, specifier: "%.1f") V")
                        .foregroundColor(voltageStatusColor)
                }
                
                // Fuel Level
                HStack {
                    Text("Fuel Level:")
                    Spacer()
                    let fuelStatus = carStatusManager.evaluateFuelLevel(carData.fuelLevel)
                    let fuelStatusColor = fuelStatus != nil ? Color.red : Color.primary
                    Text("\(carData.fuelLevel, specifier: "%.1f") %")
                        .foregroundColor(fuelStatusColor)
                }
                
                // Intake Air Temperature
                HStack {
                    Text("Intake Air Temperature:")
                    Spacer()
                    Text("\(carData.intakeAirTemperature, specifier: "%.1f") °C")
                        .foregroundColor(carData.intakeAirTemperature > 35 ? .orange : .primary)
                }
                
                // Engine Load
                HStack {
                    Text("Engine Load:")
                    Spacer()
                    Text("\(carData.engineLoad, specifier: "%.1f") %")
                        .foregroundColor(carData.engineLoad > 70 ? .red : .primary)
                }
                
                // Oxygen Sensor Voltage
                HStack {
                    Text("Oxygen Sensor:")
                    Spacer()
                    let oxygenStatus = carStatusManager.evaluateOxygenSensor(carData.oxygenSensor)
                    let oxygenStatusColor = oxygenStatus != nil ? Color.orange : Color.primary
                    Text("\(carData.oxygenSensor, specifier: "%.2f") V")
                        .foregroundColor(oxygenStatusColor)
                }
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}
