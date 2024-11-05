import SwiftUI

struct DiagnosticHistoryView: View {
    @ObservedObject var carData: CarData
    @State private var historyData: [DiagnosticRecord] = []
    
    var body: some View {
        List(historyData) { item in
            VStack(alignment: .leading) {
                Text("Date: \(dateFormatter.string(from: item.date))")
                    .font(.headline)
                Text("Engine Temperature: \(item.engineTemperature, specifier: "%.1f") °C")
                Text("Battery Level: \(item.batteryLevel, specifier: "%.1f") %")
                Text("Fuel Efficiency: \(item.fuelEfficiency, specifier: "%.1f") km/l")
            }
            .padding()
        }
        .onAppear {
            self.historyData = CarData.loadDiagnosticHistory()
        }
        .navigationTitle("Diagnostic History")
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}
