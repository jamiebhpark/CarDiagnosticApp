import SwiftUI

struct DetailedDiagnosticView: View {
    @ObservedObject var carData: CarData
    
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
                    let (engineStatusText, engineStatusColor) = carData.engineTemperatureStatus()
                    Text("\(carData.engineTemperature, specifier: "%.1f") °C - \(engineStatusText)")
                        .foregroundColor(engineStatusColor)
                }
                
                // Battery Level
                HStack {
                    Text("Battery Level:")
                    Spacer()
                    let (batteryStatusText, batteryStatusColor) = carData.batteryLevelStatus()
                    Text("\(carData.batteryLevel, specifier: "%.1f") % - \(batteryStatusText)")
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
                    let (tireStatusText, tireStatusColor) = carData.tirePressureStatus()
                    Text("\(carData.tirePressure, specifier: "%.1f") PSI - \(tireStatusText)")
                        .foregroundColor(tireStatusColor)
                }
                
                // Battery Voltage
                HStack {
                    Text("Battery Voltage:")
                    Spacer()
                    Text("\(carData.batteryVoltage, specifier: "%.1f") V")
                        .foregroundColor(carData.batteryVoltage < 12.0 || carData.batteryVoltage > 13.8 ? .orange : .primary)
                }
                
                // Fuel Level
                HStack {
                    Text("Fuel Level:")
                    Spacer()
                    Text("\(carData.fuelLevel, specifier: "%.1f") %")
                        .foregroundColor(carData.fuelLevel < 15 ? .red : .primary)
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
                    Text("\(carData.oxygenSensor, specifier: "%.2f") V")
                        .foregroundColor(carData.oxygenSensor < 0.2 || carData.oxygenSensor > 0.8 ? .orange : .primary)
                }
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}
