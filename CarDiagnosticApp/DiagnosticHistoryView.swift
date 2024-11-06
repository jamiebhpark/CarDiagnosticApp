import SwiftUI

struct DiagnosticHistoryView: View {
    @ObservedObject var carData: CarData
    @State private var historyData: [DiagnosticRecord] = []
    @State private var currentPage = 0
    @State private var isLoading = false
    private let itemsPerPage = 10  // 한 페이지당 기록 개수 설정
    
    var body: some View {
        List {
            ForEach(historyData, id: \.id) { item in
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date: \(dateFormatter.string(from: item.date))")
                        .font(.headline)
                    
                    Group {
                        Text("Engine Temperature: \(item.engineTemperature, specifier: "%.1f") °C")
                        Text("Battery Level: \(item.batteryLevel, specifier: "%.1f") %")
                        Text("Fuel Efficiency: \(item.fuelEfficiency, specifier: "%.1f") km/l")
                        Text("Tire Pressure: \(item.tirePressure, specifier: "%.1f") PSI")
                        Text("Battery Voltage: \(item.batteryVoltage, specifier: "%.1f") V")
                        Text("Fuel Level: \(item.fuelLevel, specifier: "%.1f") %")
                        Text("Intake Air Temperature: \(item.intakeAirTemperature, specifier: "%.1f") °C")
                        Text("Engine Load: \(item.engineLoad, specifier: "%.1f") %")
                        Text("Oxygen Sensor: \(item.oxygenSensor, specifier: "%.2f") V")
                    }
                    .padding(.leading, 10)
                }
                .padding()
            }
            
            // 추가 페이지 로드 버튼
            if isLoading {
                ProgressView()
            } else if historyData.count >= (currentPage + 1) * itemsPerPage {
                Button("Load More") {
                    loadMoreData()
                }
                .padding()
            }
        }
        .onAppear {
            loadMoreData()
        }
        .navigationTitle("Diagnostic History")
    }
    
    private func loadMoreData() {
        isLoading = true
        DispatchQueue.global(qos: .background).async {
            // 추가할 페이지 범위 설정
            let newRecords = Array(CarData.loadDiagnosticHistory().suffix(from: currentPage * itemsPerPage).prefix(itemsPerPage))
            DispatchQueue.main.async {
                self.historyData.append(contentsOf: newRecords)
                self.currentPage += 1
                self.isLoading = false
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}
