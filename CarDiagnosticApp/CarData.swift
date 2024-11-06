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
    @Published var tirePressureHistory: [DataPoint] = []
    @Published var batteryUsageHistory: [BatteryUsage] = []
    
    // 추가 데이터 포인트
    @Published var tirePressure: Double = 32.0
    @Published var batteryVoltage: Double = 12.6
    @Published var fuelLevel: Double = 50.0
    @Published var intakeAirTemperature: Double = 25.0
    @Published var engineLoad: Double = 20.0
    @Published var oxygenSensor: Double = 0.45
    
    @Published var warningLogs: [WarningLog] = []
    private let maxWarningLogs = 50
    
    private var timer: Timer?
    private var settings: ThresholdSettings
    var isConnected: Bool = false
    
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
        loadWarningLogs()
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
        let timeInterval = end.date.timeIntervalSince(start.date) / 3600
        
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
        if engineTemperature > settings.engineTemperatureThresholdHigh {
            return ("High", .red)
        } else if engineTemperature > settings.engineTemperatureThresholdModerate {
            return ("Moderate", .orange)
        } else {
            return ("Normal", .green)
        }
    }
    
    func batteryLevelStatus() -> (String, Color) {
        if batteryLevel < settings.batteryLevelThresholdLow {
            return ("Low", .red)
        } else if batteryLevel < settings.batteryLevelThresholdModerate {
            return ("Moderate", .orange)
        } else {
            return ("Normal", .green)
        }
    }
    
    func tirePressureStatus() -> (String, Color) {
        if tirePressure < settings.tirePressureThresholdLow {
            return ("Low", .red)
        } else if tirePressure > settings.tirePressureThresholdHigh {
            return ("High", .orange)
        } else {
            return ("Normal", .green)
        }
    }
    

    
    func checkForAlerts() {
        // 엔진 온도 경고
        if engineTemperature > settings.engineTemperatureThresholdHigh {
            let message = String(format: "Warning: Engine temperature is above %.0f°C!", settings.engineTemperatureThresholdHigh)
            sendAlertNotification(message: message)
            logWarning(type: "Engine Temperature", message: message)
        }
        
        // 배터리 레벨 경고
        if batteryLevel < settings.batteryLevelThresholdLow {
            let message = String(format: "Warning: Battery level is below %.0f%%!", settings.batteryLevelThresholdLow)
            sendAlertNotification(message: message)
            logWarning(type: "Battery Level", message: message)
        }
        
        // 타이어 압력 경고
        if tirePressure < settings.tirePressureThresholdLow {
            let message = String(format: "Warning: Tire pressure is below %.0f PSI!", settings.tirePressureThresholdLow)
            sendAlertNotification(message: message)
            logWarning(type: "Tire Pressure", message: message)
        } else if tirePressure > settings.tirePressureThresholdHigh {
            let message = String(format: "Warning: Tire pressure is above %.0f PSI!", settings.tirePressureThresholdHigh)
            sendAlertNotification(message: message)
            logWarning(type: "Tire Pressure", message: message)
        }
        
        // 배터리 전압 경고
        if batteryVoltage < 12.0 || batteryVoltage > 13.8 {
            let message = "Warning: Battery voltage is abnormal (normal range: 12.0 - 13.8 V)."
            sendAlertNotification(message: message)
            logWarning(type: "Battery Voltage", message: message)
        }
        
        // 산소 센서 경고
        if oxygenSensor < 0.2 || oxygenSensor > 0.8 {
            let message = "Warning: Oxygen sensor voltage is outside the normal range (0.2 - 0.8 V)."
            sendAlertNotification(message: message)
            logWarning(type: "Oxygen Sensor", message: message)
        }
        
        // 연료 레벨 경고 (예시: 15% 이하일 때)
        if fuelLevel < 15 {
            let message = "Warning: Fuel level is below 15%."
            sendAlertNotification(message: message)
            logWarning(type: "Fuel Level", message: message)
        }
    }
    
    func logWarning(type: String, message: String) {
        let log = WarningLog(date: Date(), type: type, message: message)
        warningLogs.append(log)
        if warningLogs.count > maxWarningLogs {
            warningLogs.removeFirst()
        }
        
        saveWarningLogs() // 변경된 로그 저장
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
    func overallStatus() -> (String, Color) {
        // Here, we use conditions to evaluate overall car status
        if engineTemperature > settings.engineTemperatureThresholdHigh || batteryLevel < settings.batteryLevelThresholdLow || tirePressure < settings.tirePressureThresholdLow {
            return ("Warning", .red)
        } else if engineTemperature > settings.engineTemperatureThresholdModerate || batteryLevel < settings.batteryLevelThresholdModerate {
            return ("Moderate", .orange)
        } else {
            return ("Good", .green)
        }
    }
    
    func saveDiagnosticData() {
        let history = [
            "date": Date(),
            "engineTemperature": engineTemperature,
            "batteryLevel": batteryLevel,
            "fuelEfficiency": fuelEfficiency,
            "tirePressure": tirePressure,
            "batteryVoltage": batteryVoltage,
            "fuelLevel": fuelLevel,
            "intakeAirTemperature": intakeAirTemperature,
            "engineLoad": engineLoad,
            "oxygenSensor": oxygenSensor
        ] as [String : Any]
        
        var diagnosticHistory = UserDefaults.standard.array(forKey: "DiagnosticHistory") as? [[String: Any]] ?? []
        diagnosticHistory.append(history)
        
        // 최근 10개의 기록만 유지
        if diagnosticHistory.count > 10 {
            diagnosticHistory.removeFirst(diagnosticHistory.count - 10)
        }
        
        UserDefaults.standard.set(diagnosticHistory, forKey: "DiagnosticHistory")
    }

    static func loadDiagnosticHistory() -> [DiagnosticRecord] {
        let diagnosticHistory = UserDefaults.standard.array(forKey: "DiagnosticHistory") as? [[String: Any]] ?? []
        
        return diagnosticHistory.compactMap { item in
            if let date = item["date"] as? Date,
               let engineTemperature = item["engineTemperature"] as? Double,
               let batteryLevel = item["batteryLevel"] as? Double,
               let fuelEfficiency = item["fuelEfficiency"] as? Double,
               let tirePressure = item["tirePressure"] as? Double,
               let batteryVoltage = item["batteryVoltage"] as? Double,
               let fuelLevel = item["fuelLevel"] as? Double,
               let intakeAirTemperature = item["intakeAirTemperature"] as? Double,
               let engineLoad = item["engineLoad"] as? Double,
               let oxygenSensor = item["oxygenSensor"] as? Double {
                return DiagnosticRecord(
                    date: date,
                    engineTemperature: engineTemperature,
                    batteryLevel: batteryLevel,
                    fuelEfficiency: fuelEfficiency,
                    tirePressure: tirePressure,
                    batteryVoltage: batteryVoltage,
                    fuelLevel: fuelLevel,
                    intakeAirTemperature: intakeAirTemperature,
                    engineLoad: engineLoad,
                    oxygenSensor: oxygenSensor
                )
            }
            return nil
        }
    }
}

extension CarData {
    func generateEnhancedPDFReport() -> URL? {
        let pageBounds = CGRect(x: 0, y: 0, width: 612, height: 792) // A4 사이즈
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, pageBounds, nil)
        UIGraphicsBeginPDFPageWithInfo(pageBounds, nil)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        var yOffset: CGFloat = 72 // A4 용지 상단에서 시작 위치
        
        // 상단 타이틀 및 날짜
        let reportTitle = "Comprehensive Car Diagnostic Report"
        let diagnosticDate = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 22),
            .foregroundColor: UIColor.black
        ]
        reportTitle.draw(at: CGPoint(x: 72, y: yOffset), withAttributes: titleAttributes)
        yOffset += 30
        
        let dateText = "Generated on: \(diagnosticDate)"
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.gray
        ]
        dateText.draw(at: CGPoint(x: 72, y: yOffset), withAttributes: dateAttributes)
        yOffset += 40
        
        // 진단 요약 섹션
        let sectionTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.black
        ]
        let contentAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.darkGray
        ]
        
        "Diagnostic Summary".draw(at: CGPoint(x: 72, y: yOffset), withAttributes: sectionTitleAttributes)
        yOffset += 25

        // 주요 항목 상태 표시
        let diagnosticSummaries = [
            "• Engine Temperature: \(engineTemperatureStatus().0) - \(String(format: "%.1f", engineTemperature))°C (\(settings.engineTemperatureThresholdModerate)~\(settings.engineTemperatureThresholdHigh)°C)",
            "• Battery Level: \(batteryLevelStatus().0) - \(String(format: "%.1f", batteryLevel))% (\(settings.batteryLevelThresholdModerate)~100%)",
            "• Fuel Efficiency: \(String(format: "%.1f", fuelEfficiency)) km/l",
            "• Tire Pressure: \(tirePressureStatus().0) - \(String(format: "%.1f", tirePressure)) PSI (\(settings.tirePressureThresholdLow)~\(settings.tirePressureThresholdHigh) PSI)",
            "• Battery Voltage: \(String(format: "%.1f", batteryVoltage)) V (12.0~13.8 V)",
            "• Fuel Level: \(String(format: "%.1f", fuelLevel)) %",
            "• Intake Air Temperature: \(String(format: "%.1f", intakeAirTemperature)) °C (20~35 °C)",
            "• Engine Load: \(String(format: "%.1f", engineLoad)) % (0~70%)",
            "• Oxygen Sensor: \(String(format: "%.2f", oxygenSensor)) V (0.2~0.8 V)"
        ]
        
        for summary in diagnosticSummaries {
            summary.draw(at: CGPoint(x: 72, y: yOffset), withAttributes: contentAttributes)
            yOffset += 20
        }
        
        yOffset += 40
        
        // 주요 그래프 - 엔진 온도 및 배터리 레벨
        drawLineGraph(dataPoints: engineTemperatureHistory, title: "Engine Temperature Over Time", yAxisLabel: "°C", xAxisLabel: "Time", context: context, origin: CGPoint(x: 72, y: yOffset))
        yOffset += 140
        
        drawLineGraph(dataPoints: batteryLevelHistory, title: "Battery Level Over Time", yAxisLabel: "%", xAxisLabel: "Time", context: context, origin: CGPoint(x: 72, y: yOffset))
        
        UIGraphicsEndPDFContext()
        
        let fileURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("EnhancedCarDiagnosticReport.pdf")
        
        do {
            try pdfData.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to save PDF file: \(error)")
            return nil
        }
    }
    
    // 그래프를 그리는 메서드 (축과 단위 추가)
    private func drawLineGraph(dataPoints: [DataPoint], title: String, yAxisLabel: String, xAxisLabel: String, context: CGContext, origin: CGPoint) {
        context.setFillColor(UIColor.lightGray.cgColor)
        context.fill(CGRect(x: origin.x, y: origin.y, width: 468, height: 100))
        
        context.setStrokeColor(UIColor.blue.cgColor)
        context.setLineWidth(1.5)
        
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(0.5)
        
        // Y축 그리기
        context.move(to: CGPoint(x: origin.x, y: origin.y))
        context.addLine(to: CGPoint(x: origin.x, y: origin.y + 100))
        context.strokePath()
        
        // X축 그리기
        context.move(to: CGPoint(x: origin.x, y: origin.y + 100))
        context.addLine(to: CGPoint(x: origin.x + 468, y: origin.y + 100))
        context.strokePath()
        
        // Y축 라벨
        let maxY = dataPoints.map { $0.value }.max() ?? 1
        let yAxisLabelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.black
        ]
        "\(Int(maxY)) \(yAxisLabel)".draw(at: CGPoint(x: origin.x - 30, y: origin.y), withAttributes: yAxisLabelAttributes)
        "0 \(yAxisLabel)".draw(at: CGPoint(x: origin.x - 30, y: origin.y + 90), withAttributes: yAxisLabelAttributes)
        
        // X축 라벨
        xAxisLabel.draw(at: CGPoint(x: origin.x + 230, y: origin.y + 110), withAttributes: yAxisLabelAttributes)

        // 데이터 라인 그리기
        if dataPoints.count > 1 {
            let scale = 100 / maxY
            
            for i in 1..<dataPoints.count {
                let startPoint = CGPoint(x: origin.x + CGFloat(i - 1) * 10, y: origin.y + 100 - CGFloat(dataPoints[i - 1].value) * scale)
                let endPoint = CGPoint(x: origin.x + CGFloat(i) * 10, y: origin.y + 100 - CGFloat(dataPoints[i].value) * scale)
                
                context.move(to: startPoint)
                context.addLine(to: endPoint)
                context.strokePath()
            }
        }
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]
        title.draw(at: CGPoint(x: origin.x, y: origin.y - 20), withAttributes: titleAttributes)
    }
}
