import SwiftUI
import PDFKit

struct ContentView: View {
    @ObservedObject private var carData: CarData
    @StateObject private var settings = ThresholdSettings()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var reportURL: URL? = nil
    @State private var showingShareSheet = false

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

                    if !carData.isConnected {
                        ConnectionWarningMessage()
                    }
                    
                    Text("Car Diagnostic Summary")
                        .font(.title)
                        .padding()
                    
                    DiagnosticSummary(carData: carData, settings: settings)


                    // 요약 경고 메시지 표시
                    if let alertMessage = overallStatusAlertMessage() {
                        Text(alertMessage)
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    // Navigation Links and Buttons
                    NavigationLinksView(carData: carData, settings: settings)
                    ReportButton(showingShareSheet: $showingShareSheet, reportURL: $reportURL, alertMessage: $alertMessage, showAlert: $showAlert, carData: carData)
                    
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
    
    // 요약 경고 메시지 제공
    private func overallStatusAlertMessage() -> String? {
        var alerts: [String] = []
        
        if carData.engineTemperature > settings.engineTemperatureThresholdHigh {
            alerts.append("High engine temperature detected!")
        }
        if carData.batteryLevel < settings.batteryLevelThresholdLow {
            alerts.append("Low battery level detected!")
        }
        if carData.tirePressure < settings.tirePressureThresholdLow || carData.tirePressure > settings.tirePressureThresholdHigh {
            alerts.append("Tire pressure is out of range!")
        }
        
        return alerts.isEmpty ? nil : alerts.joined(separator: "\n")
    }
}







