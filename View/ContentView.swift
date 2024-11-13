import SwiftUI
import PDFKit

// 앱의 메인 화면 뷰를 구성하는 ContentView
struct ContentView: View {
    @ObservedObject private var carData: CarData // 자동차 데이터 객체
    @StateObject private var settings = ThresholdSettings() // 임계값 설정 객체
    @State private var showAlert = false // 경고 알림을 보여줄지 여부
    @State private var alertMessage = "" // 경고 메시지
    @State private var reportURL: URL? = nil // PDF 리포트의 URL
    @State private var showingShareSheet = false // 공유 시트를 보여줄지 여부

    // ContentView의 초기화 메서드
    init() {
        let settings = ThresholdSettings()
        _carData = ObservedObject(wrappedValue: CarData(settings: settings))
    }
    
    // View의 본문을 정의하는 부분
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Bluetooth 연결 상태 표시
                    HStack {
                        Circle()
                            .fill(carData.isConnected ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                            .accessibilityLabel(carData.isConnected ? "Connected to OBD-II" : "Not Connected")
                        Text(carData.isConnected ? "Connected to OBD-II" : "Not Connected")
                            .foregroundColor(carData.isConnected ? .green : .red)
                            .fontWeight(.bold)
                    }
                    .padding()

                    // 연결되지 않았을 때 경고 메시지
                    if !carData.isConnected {
                        ConnectionWarningMessage()
                    }
                    
                    // OBD-II 연결 버튼
                    Button(action: {
                        carData.connectToOBD() // OBD-II 연결 메서드 호출
                    }) {
                        Text("Connect to OBD-II")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .accessibilityLabel("Connect to OBD-II")
                    }
                    
                    Text("Car Diagnostic Summary")
                        .font(.title)
                        .padding()
                    
                    // 자동차 진단 요약 정보를 보여주는 뷰
                    DiagnosticSummary(carData: carData, settings: settings)

                    // 요약 경고 메시지 표시
                    if let alertMessage = overallStatusAlertMessage() {
                        Text(alertMessage)
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding()
                            .accessibilityLabel("Warning: \(alertMessage)")
                    }
                    
                    // 내비게이션 링크와 버튼을 표시하는 뷰
                    NavigationLinksView(carData: carData, settings: settings)
                    
                    // 유지 관리 팁 보기 버튼 추가
                    NavigationLink(destination: MaintenanceTipsView(tipManager: carData.maintenanceTipManager)) {
                        NavigationButtonView(label: "View Maintenance Tips")
                    }
                    
                    // PDF 리포트 공유 버튼
                    ReportButton(showingShareSheet: $showingShareSheet, reportURL: $reportURL, alertMessage: $alertMessage, showAlert: $showAlert, carData: carData)
                    
                    Spacer()
                }
                .padding()
                // 접근성 레이블이 없는 `Alert` 대신 알림에 대한 접근성 제공
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                // 경고 알림을 받을 때 처리하는 부분
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("CarAlert"))) { notification in
                    if let message = notification.object as? String {
                        alertMessage = message
                        showAlert = true
                    }
                }
                // 공유 시트가 나타났다가 사라질 때 파일 삭제 처리
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
            .navigationBarTitle("Car Diagnostic", displayMode: .inline) // 화면 제목 추가
        }
    }
    
    // 경고 메시지를 종합하여 제공하는 메서드
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
