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
    @Published var tirePressureHistory: [DataPoint] = [] // 타이어 압력 기록 추가
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
    func generateEnhancedPDFReport() -> URL? {
        let pageBounds = CGRect(x: 0, y: 0, width: 612, height: 792) // A4 사이즈
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, pageBounds, nil)
        var yOffset: CGFloat = 740 // 페이지 상단에서부터 시작
        
        func addNewPageIfNeeded() {
            if yOffset < 100 { // 충분한 공간이 없으면 새 페이지 추가
                UIGraphicsBeginPDFPageWithInfo(pageBounds, nil)
                yOffset = 740
            }
        }
        
        UIGraphicsBeginPDFPageWithInfo(pageBounds, nil)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // 상단 타이틀 및 날짜
        let reportTitle = "Comprehensive Car Diagnostic Report"
        let diagnosticDate = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 22),
            .foregroundColor: UIColor.black
        ]
        reportTitle.draw(at: CGPoint(x: 72, y: yOffset), withAttributes: titleAttributes)
        yOffset -= 30
        
        let dateText = "Generated on: \(diagnosticDate)"
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.gray
        ]
        dateText.draw(at: CGPoint(x: 72, y: yOffset), withAttributes: dateAttributes)
        yOffset -= 40
        
        // 진단 요약 섹션
        let sectionTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.black
        ]
        let contentAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.darkGray
        ]
        
        // 섹션 타이틀
        "Diagnostic Summary".draw(at: CGPoint(x: 72, y: yOffset), withAttributes: sectionTitleAttributes)
        yOffset -= 30
        
        // 진단 요약 내용
        let engineSummary = "• Engine Temperature: \(engineTemperatureStatus().0) - \(String(format: "%.1f", engineTemperature))°C"
        let batterySummary = "• Battery Level: \(batteryLevelStatus().0) - \(String(format: "%.1f", batteryLevel))%"
        let fuelSummary = "• Fuel Efficiency: \(String(format: "%.1f", fuelEfficiency)) km/l"
        let tirePressureSummary = "• Tire Pressure: \(tirePressureStatus().0) - \(String(format: "%.1f", tirePressure)) PSI"
        let batteryVoltageSummary = "• Battery Voltage: \(String(format: "%.1f", batteryVoltage)) V"
        
        let summaries = [engineSummary, batterySummary, fuelSummary, tirePressureSummary, batteryVoltageSummary]
        
        for summary in summaries {
            summary.draw(at: CGPoint(x: 72, y: yOffset), withAttributes: contentAttributes)
            yOffset -= 20
            addNewPageIfNeeded()
        }
        
        yOffset -= 20
        
        // 권장 조치 섹션
        "Recommended Actions".draw(at: CGPoint(x: 72, y: yOffset), withAttributes: sectionTitleAttributes)
        yOffset -= 30
        let recommendationsText = generateRecommendations()
        
        // 단일 줄로 작성된 텍스트를 각 줄로 나눠서 그려주는 방식으로 수정
        for line in recommendationsText.split(separator: "\n") {
            let lineText = String(line)
            lineText.draw(at: CGPoint(x: 72, y: yOffset), withAttributes: contentAttributes)
            yOffset -= 20
            addNewPageIfNeeded()
        }
        yOffset -= 10
        
        // 그래프 추가
        drawLineGraph(dataPoints: engineTemperatureHistory, title: "Engine Temperature Over Time", context: context, origin: CGPoint(x: 72, y: yOffset))
        yOffset -= 150
        addNewPageIfNeeded()
        
        drawLineGraph(dataPoints: batteryLevelHistory, title: "Battery Level Over Time", context: context, origin: CGPoint(x: 72, y: yOffset))
        yOffset -= 150
        addNewPageIfNeeded()
        
        drawLineGraph(dataPoints: tirePressureHistory, title: "Tire Pressure Over Time", context: context, origin: CGPoint(x: 72, y: yOffset))
        yOffset -= 150
        addNewPageIfNeeded()
        
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
    
    // 권장 조치를 생성하는 메서드
    private func generateRecommendations() -> String {
        var recommendations = [String]()
        
        if engineTemperature > settings.engineTemperatureThreshold {
            recommendations.append("Engine temperature is high. Check coolant and radiator.")
        }
        if batteryLevel < settings.batteryLevelThreshold {
            recommendations.append("Battery level is low. Consider recharging or replacing the battery.")
        }
        if tirePressure < 30 || tirePressure > 35 {
            recommendations.append("Tire pressure is outside the optimal range. Adjust pressure as needed.")
        }
        if batteryVoltage < 12.0 || batteryVoltage > 13.8 {
            recommendations.append("Battery voltage is abnormal. Check the alternator and battery health.")
        }
        
        return recommendations.joined(separator: "\n")
    }
    
    // 그래프를 그리는 메서드 (엔진 온도 예시)
    private func drawLineGraph(dataPoints: [DataPoint], title: String, context: CGContext, origin: CGPoint) {
        context.saveGState()
        context.setFillColor(UIColor.lightGray.cgColor)
        context.fill(CGRect(x: origin.x, y: origin.y - 100, width: 468, height: 100))
        
        context.setStrokeColor(UIColor.blue.cgColor)
        context.setLineWidth(1.5)
        
        if dataPoints.count > 1 {
            let maxY = dataPoints.map { $0.value }.max() ?? 1
            let scale = 100 / maxY
            
            for i in 1..<dataPoints.count {
                let startPoint = CGPoint(x: origin.x + CGFloat(i - 1) * 10, y: origin.y - CGFloat(dataPoints[i - 1].value) * scale)
                let endPoint = CGPoint(x: origin.x + CGFloat(i) * 10, y: origin.y - CGFloat(dataPoints[i].value) * scale)
                
                context.move(to: startPoint)
                context.addLine(to: endPoint)
                context.strokePath()
            }
        }
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]
        title.draw(at: CGPoint(x: origin.x, y: origin.y + 10), withAttributes: titleAttributes)
        
        context.restoreGState()
    }
}
