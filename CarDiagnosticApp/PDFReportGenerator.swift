import PDFKit
import UIKit

class PDFReportGenerator {
    static func generateEnhancedPDFReport(carData: CarData, statusManager: CarStatusManager) -> URL? {
        let engineTemperatureStatus = statusManager.evaluateEngineTemperature(carData.engineTemperature) ?? "Normal"
        let batteryLevelStatus = statusManager.evaluateBatteryLevel(carData.batteryLevel) ?? "Normal"
        let tirePressureStatus = statusManager.evaluateTirePressure(carData.tirePressure) ?? "Normal"
        let engineTemperature = carData.engineTemperature
        let batteryLevel = carData.batteryLevel
        let fuelEfficiency = carData.fuelEfficiency
        let tirePressure = carData.tirePressure
        let batteryVoltage = carData.batteryVoltage
        let fuelLevel = carData.fuelLevel
        let intakeAirTemperature = carData.intakeAirTemperature
        let engineLoad = carData.engineLoad
        let oxygenSensor = carData.oxygenSensor
        let engineTemperatureHistory = carData.engineTemperatureHistory
        let batteryLevelHistory = carData.batteryLevelHistory

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

        let diagnosticSummaries = [
            "• Engine Temperature: \(engineTemperatureStatus) - \(String(format: "%.1f", engineTemperature))°C (\(carData.settings.engineTemperatureThresholdModerate)~\(carData.settings.engineTemperatureThresholdHigh)°C)",
            "• Battery Level: \(batteryLevelStatus) - \(String(format: "%.1f", batteryLevel))% (\(carData.settings.batteryLevelThresholdModerate)~100%)",
            "• Fuel Efficiency: \(String(format: "%.1f", fuelEfficiency)) km/l",
            "• Tire Pressure: \(tirePressureStatus) - \(String(format: "%.1f", tirePressure)) PSI (\(carData.settings.tirePressureThresholdLow)~\(carData.settings.tirePressureThresholdHigh) PSI)",
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
    private static func drawLineGraph(dataPoints: [DataPoint], title: String, yAxisLabel: String, xAxisLabel: String, context: CGContext, origin: CGPoint) {
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
