import SwiftUI
import PDFKit

struct ContentView: View {
    @ObservedObject private var carData: CarData
    @StateObject private var settings = ThresholdSettings()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var reportURL: URL? = nil // PDF 파일 URL 저장 변수
    @State private var showingShareSheet = false // 공유 시트 표시 여부

    init() {
        let settings = ThresholdSettings()
        _carData = ObservedObject(wrappedValue: CarData(settings: settings))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Bluetooth 연결 상태 표시
                    HStack {
                        Circle()
                            .fill(carData.isConnected ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                        Text(carData.isConnected ? "Connected to OBD-II" : "Not Connected")
                            .foregroundColor(carData.isConnected ? .green : .red)
                            .fontWeight(.bold)
                    }
                    .padding()

                    // 연결되지 않은 경우 경고 메시지 표시
                    if !carData.isConnected {
                        Text("Please connect to the OBD-II device to start data monitoring.")
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Text("Car Diagnostic Summary")
                        .font(.title)
                        .padding()
                    
                    // Engine Temperature 상태 표시
                    HStack {
                        Text("Engine Temperature:")
                        Spacer()
                        let (engineStatusText, engineStatusColor) = carData.engineTemperatureStatus()
                        Text("\(carData.engineTemperature, specifier: "%.1f") °C - \(engineStatusText)")
                            .foregroundColor(engineStatusColor)
                    }
                    LineGraphView(dataPoints: carData.engineTemperatureHistory)
                        .frame(height: 100)
                        .padding()
                    
                    // Battery Level 상태 표시
                    HStack {
                        Text("Battery Level:")
                        Spacer()
                        let (batteryStatusText, batteryStatusColor) = carData.batteryLevelStatus()
                        Text("\(carData.batteryLevel, specifier: "%.1f") % - \(batteryStatusText)")
                            .foregroundColor(batteryStatusColor)
                    }
                    Text(carData.batteryLifePrediction())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                    LineGraphView(dataPoints: carData.batteryLevelHistory)
                        .frame(height: 100)
                        .padding()
                    
                    // Fuel Efficiency 상태 표시 (연비는 상태 표시 없이 기본 색상 유지)
                    HStack {
                        Text("Fuel Efficiency:")
                        Spacer()
                        Text("\(carData.fuelEfficiency, specifier: "%.1f") km/l")
                            .foregroundColor(carData.fuelEfficiency < 10 ? .orange : .primary)
                    }
                    LineGraphView(dataPoints: carData.fuelEfficiencyHistory)
                        .frame(height: 100)
                        .padding()
                    
                    // 추가 데이터 포인트 상태 표시
                    HStack {
                        Text("Tire Pressure:")
                        Spacer()
                        let (tireStatusText, tireStatusColor) = carData.tirePressureStatus()
                        Text("\(carData.tirePressure, specifier: "%.1f") PSI - \(tireStatusText)")
                            .foregroundColor(tireStatusColor)
                    }
                    
                    HStack {
                        Text("Battery Voltage:")
                        Spacer()
                        Text("\(carData.batteryVoltage, specifier: "%.1f") V")
                            .foregroundColor(carData.batteryVoltage < 12.0 ? .orange : .primary)
                    }
                    
                    HStack {
                        Text("Fuel Level:")
                        Spacer()
                        Text("\(carData.fuelLevel, specifier: "%.1f") %")
                            .foregroundColor(carData.fuelLevel < 15 ? .red : .primary)
                    }
                    
                    HStack {
                        Text("Intake Air Temperature:")
                        Spacer()
                        Text("\(carData.intakeAirTemperature, specifier: "%.1f") °C")
                            .foregroundColor(carData.intakeAirTemperature > 35 ? .orange : .primary)
                    }
                    
                    HStack {
                        Text("Engine Load:")
                        Spacer()
                        Text("\(carData.engineLoad, specifier: "%.1f") %")
                            .foregroundColor(carData.engineLoad > 70 ? .red : .primary)
                    }
                    
                    HStack {
                        Text("Oxygen Sensor:")
                        Spacer()
                        Text("\(carData.oxygenSensor, specifier: "%.2f") V")
                            .foregroundColor(carData.oxygenSensor < 0.2 || carData.oxygenSensor > 0.8 ? .orange : .primary)
                    }
                    
                    // 버튼들
                    NavigationLink(destination: DetailedDiagnosticView(carData: carData)) {
                        Text("View Detailed Diagnostics")
                            .foregroundColor(.blue)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    }
                    
                    NavigationLink(destination: DiagnosticHistoryView(carData: carData)) {
                        Text("View Diagnostic History")
                            .foregroundColor(.blue)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    }
                    
                    NavigationLink(destination: ThresholdSettingsView(settings: settings)) {
                        Text("Set Alert Thresholds")
                            .foregroundColor(.blue)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    }
                    
                    // 경고 히스토리 화면으로 이동하는 버튼
                    NavigationLink(destination: WarningHistoryView(carData: carData)) {
                        Text("View Warning History")
                            .foregroundColor(.blue)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    }
                    
                    // PDF 리포트 생성 및 공유 버튼
                    Button(action: {
                        if let url = carData.generatePDFReport() {
                            reportURL = url
                            showingShareSheet = true
                        } else {
                            alertMessage = "Failed to generate report."
                            showAlert = true
                        }
                    }) {
                        Text("Generate and Share Report")
                            .foregroundColor(.blue)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    }
                    
                    Spacer()
                }
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("CarAlert"))) { notification in
                    if let message = notification.object as? String {
                        alertMessage = message
                        showAlert = true
                    }
                }
                .sheet(isPresented: $showingShareSheet, onDismiss: {
                    if let reportURL = reportURL {
                        try? FileManager.default.removeItem(at: reportURL)
                    }
                }, content: {
                    if let reportURL = reportURL {
                        ActivityView(activityItems: [reportURL])
                    }
                })
            }
        }
    }
}
