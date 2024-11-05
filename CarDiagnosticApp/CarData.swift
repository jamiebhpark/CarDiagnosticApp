import Foundation
import Combine
import UserNotifications
import PDFKit
import SwiftUI

class CarData: ObservableObject {
    @Published var engineTemperature: Double
    @Published var batteryLevel: Double
    @Published var fuelEfficiency: Double
    
    @Published var engineTemperatureHistory: [DataPoint] = []
    @Published var batteryLevelHistory: [DataPoint] = []
    @Published var fuelEfficiencyHistory: [DataPoint] = []
    @Published var batteryUsageHistory: [BatteryUsage] = []  // 배터리 사용 기록 추가
    
    // 추가 데이터 포인트
    @Published var tirePressure: Double = 32.0
    @Published var batteryVoltage: Double = 12.6
    @Published var fuelLevel: Double = 50.0
    @Published var intakeAirTemperature: Double = 25.0
    @Published var engineLoad: Double = 20.0
    @Published var oxygenSensor: Double = 0.45
    
    @Published var warningLogs: [WarningLog] = []  // 경고 기록
    
    private var timer: Timer?
    private var settings: ThresholdSettings  // 사용자 임계값 설정
    var isConnected: Bool = false // Bluetooth 연결 상태 시뮬레이션
    
    init(settings: ThresholdSettings) {
        self.settings = settings
        self.engineTemperature = Double.random(in: 60...120)
        self.batteryLevel = Double.random(in: 10...100)
        self.fuelEfficiency = Double.random(in: 5...20)
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.updateData()
        }
        
        requestNotificationPermission()
        connectToOBD()
        loadWarningLogs()  // 앱 실행 시 경고 로그 불러오기
    }
    
    func connectToOBD() {
        isConnected = true
        startMockDataUpdates()
    }
    func disconnectFromOBD() {
        isConnected = false
    }
    
    private func updateData() {
        engineTemperature = Double.random(in: 60...120)
        batteryLevel = Double.random(in: 10...100)
        fuelEfficiency = Double.random(in: 5...20)
        
        let currentBatteryUsage = BatteryUsage(date: Date(), batteryLevel: batteryLevel)
        batteryUsageHistory.append(currentBatteryUsage)
        
        if batteryUsageHistory.count > 100 { batteryUsageHistory.removeFirst() }
        
        engineTemperatureHistory.append(DataPoint(time: Date(), value: engineTemperature))
        batteryLevelHistory.append(DataPoint(time: Date(), value: batteryLevel))
        fuelEfficiencyHistory.append(DataPoint(time: Date(), value: fuelEfficiency))
        
        if engineTemperatureHistory.count > 50 { engineTemperatureHistory.removeFirst() }
        if batteryLevelHistory.count > 50 { batteryLevelHistory.removeFirst() }
        if fuelEfficiencyHistory.count > 50 { fuelEfficiencyHistory.removeFirst() }
        
        saveDiagnosticData()
        checkForAlerts()
    }
    
    func startMockDataUpdates() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard self.isConnected else { return }
            
            self.engineTemperature = Double.random(in: 60...120)
            self.batteryLevel = Double.random(in: 10...100)
            self.fuelEfficiency = Double.random(in: 5...20)
            self.tirePressure = Double.random(in: 28...35)
            self.batteryVoltage = Double.random(in: 12.0...13.8)
            self.fuelLevel = Double.random(in: 10...100)
            self.intakeAirTemperature = Double.random(in: 20...40)
            self.engineLoad = Double.random(in: 20...80)
            self.oxygenSensor = Double.random(in: 0.1...0.9)
        }
    }
    
    func batteryLifePrediction() -> String {
        guard batteryUsageHistory.count >= 2 else {
            return "Not enough data for prediction"
        }
        
        let recentData = batteryUsageHistory.suffix(5)
        let start = recentData.first!
        let end = recentData.last!
        let timeInterval = end.date.timeIntervalSince(start.date) / 3600  // 시간 단위로 변환
        
        guard timeInterval > 0 else {
            return "Invalid time interval"
        }
        
        let batteryDecrease = start.batteryLevel - end.batteryLevel
        let decreaseRatePerHour = batteryDecrease / timeInterval
        
        guard decreaseRatePerHour > 0 else {
            return "Battery level is stable or increasing"
        }
        
        let remainingTime = batteryLevel / decreaseRatePerHour
        return String(format: "Estimated battery life: %.1f hours", remainingTime)
    }
    
    func engineTemperatureStatus() -> (String, Color) {
        if engineTemperature > settings.engineTemperatureThreshold {
            return ("High", .red)
        } else if engineTemperature > settings.engineTemperatureThreshold * 0.8 {
            return ("Moderate", .orange)
        } else {
            return ("Normal", .green)
        }
    }
    
    // 배터리 수준 상태를 판별하고, 텍스트와 색상을 반환
    func batteryLevelStatus() -> (String, Color) {
        if batteryLevel < settings.batteryLevelThreshold {
            return ("Low", .red)
        } else if batteryLevel < settings.batteryLevelThreshold * 1.2 {
            return ("Moderate", .orange)
        } else {
            return ("Normal", .green)
        }
    }

    // 타이어 압력 상태를 판별하고, 텍스트와 색상을 반환
    func tirePressureStatus() -> (String, Color) {
        if tirePressure < 30 {
            return ("Low", .red)
        } else if tirePressure > 35 {
            return ("High", .orange)
        } else {
            return ("Normal", .green)
        }
    }

    
    // 경고 발생 시 로그 기록
    func logWarning(type: String, message: String) {
        let log = WarningLog(date: Date(), type: type, message: message)
        warningLogs.append(log)
        saveWarningLogs()
    }
    
    func checkForAlerts() {
        if engineTemperature > settings.engineTemperatureThreshold {
            let message = String(format: "Warning: Engine temperature is above %.0f°C!", settings.engineTemperatureThreshold)
            sendAlertNotification(message: message)
            logWarning(type: "Engine Temperature", message: message)
        }
        
        if batteryLevel < settings.batteryLevelThreshold {
            let message = String(format: "Warning: Battery level is below %.0f%%!", settings.batteryLevelThreshold)
            sendAlertNotification(message: message)
            logWarning(type: "Battery Level", message: message)
        }
    }
    
    private func saveWarningLogs() {
        if let data = try? JSONEncoder().encode(warningLogs) {
            UserDefaults.standard.set(data, forKey: "WarningLogs")
        }
    }
    
    private func loadWarningLogs() {
        if let data = UserDefaults.standard.data(forKey: "WarningLogs"),
           let logs = try? JSONDecoder().decode([WarningLog].self, from: data) {
            warningLogs = logs
        }
    }
    
    func sendAlertNotification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Car Diagnostic Alert"
        content.body = message
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func saveDiagnosticData() {
        let history = [
            "date": Date(),
            "engineTemperature": engineTemperature,
            "batteryLevel": batteryLevel,
            "fuelEfficiency": fuelEfficiency
        ] as [String : Any]
        
        var diagnosticHistory = UserDefaults.standard.array(forKey: "DiagnosticHistory") as? [[String: Any]] ?? []
        diagnosticHistory.append(history)
        UserDefaults.standard.set(diagnosticHistory, forKey: "DiagnosticHistory")
    }
    
    static func loadDiagnosticHistory() -> [DiagnosticRecord] {
        let diagnosticHistory = UserDefaults.standard.array(forKey: "DiagnosticHistory") as? [[String: Any]] ?? []
        
        return diagnosticHistory.compactMap { item in
            if let date = item["date"] as? Date,
               let engineTemperature = item["engineTemperature"] as? Double,
               let batteryLevel = item["batteryLevel"] as? Double,
               let fuelEfficiency = item["fuelEfficiency"] as? Double {
                return DiagnosticRecord(
                    date: date,
                    engineTemperature: engineTemperature,
                    batteryLevel: batteryLevel,
                    fuelEfficiency: fuelEfficiency
                )
            }
            return nil
        }
    }
}

extension CarData {
    func generatePDFReport() -> URL? {
        let pageBounds = CGRect(x: 0, y: 0, width: 612, height: 792)
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, pageBounds, nil)
        UIGraphicsBeginPDFPageWithInfo(pageBounds, nil)
        
        guard UIGraphicsGetCurrentContext() != nil else { return nil }
        
        let reportTitle = "Car Diagnostic Report"
        let batteryPrediction = batteryLifePrediction()
        let engineSummary = String(format: "Engine Temperature: %.1f °C", engineTemperatureHistory.last?.value ?? 0)
        let batterySummary = String(format: "Battery Level: %.1f %%", batteryLevelHistory.last?.value ?? 0)
        let fuelSummary = String(format: "Fuel Efficiency: %.1f km/l", fuelEfficiencyHistory.last?.value ?? 0)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 20),
            .foregroundColor: UIColor.black
        ]
        reportTitle.draw(at: CGPoint(x: 72, y: 700), withAttributes: titleAttributes)
        
        let contentAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.black
        ]
        
        engineSummary.draw(at: CGPoint(x: 72, y: 650), withAttributes: contentAttributes)
        batterySummary.draw(at: CGPoint(x: 72, y: 630), withAttributes: contentAttributes)
        fuelSummary.draw(at: CGPoint(x: 72, y: 610), withAttributes: contentAttributes)
        batteryPrediction.draw(at: CGPoint(x: 72, y: 590), withAttributes: contentAttributes)
        
        UIGraphicsEndPDFContext()
        
        let fileURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("CarDiagnosticReport.pdf")
        
        do {
            try pdfData.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to save PDF file: \(error)")
            return nil
        }
    }
}
