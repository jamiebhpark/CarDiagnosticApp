import SwiftUI

struct DetailedDiagnosticView: View {
    @ObservedObject var carData: CarData
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Detailed Car Diagnostic")
                .font(.title)
                .padding()
            
            VStack(spacing: 10) {
                HStack {
                    Text("Engine Temperature:")
                    Spacer()
                    Text("\(carData.engineTemperature, specifier: "%.1f") °C")
                        .foregroundColor(carData.engineTemperature > 100 ? .red : .primary)
                }
                
                HStack {
                    Text("Battery Level:")
                    Spacer()
                    Text("\(carData.batteryLevel, specifier: "%.1f") %")
                        .foregroundColor(carData.batteryLevel < 20 ? .orange : .primary)
                }
                
                HStack {
                    Text("Fuel Efficiency:")
                    Spacer()
                    Text("\(carData.fuelEfficiency, specifier: "%.1f") km/l")
                        .foregroundColor(carData.fuelEfficiency < 10 ? .orange : .primary)
                }
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}
