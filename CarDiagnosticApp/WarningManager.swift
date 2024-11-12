import Foundation

class WarningManager {
    private let maxWarningLogs = 50
    @Published private(set) var warningLogs: [WarningLog] = []
    private let statusManager: CarStatusManager

    init(statusManager: CarStatusManager) {
        self.statusManager = statusManager
    }

    func evaluateAndLogWarnings(carData: CarData) {
        var messages: [String] = []

        if let engineWarning = statusManager.evaluateEngineTemperature(carData.engineTemperature) {
            messages.append(engineWarning)
        }

        if let batteryWarning = statusManager.evaluateBatteryLevel(carData.batteryLevel) {
            messages.append(batteryWarning)
        }

        if let tirePressureWarning = statusManager.evaluateTirePressure(carData.tirePressure) {
            messages.append(tirePressureWarning)
        }

        if let voltageWarning = statusManager.evaluateBatteryVoltage(carData.batteryVoltage) {
            messages.append(voltageWarning)
        }

        if let oxygenWarning = statusManager.evaluateOxygenSensor(carData.oxygenSensor) {
            messages.append(oxygenWarning)
        }

        if let fuelWarning = statusManager.evaluateFuelLevel(carData.fuelLevel) {
            messages.append(fuelWarning)
        }

        // 여러 경고 메시지를 하나로 합쳐서 한 번에 추가
        if !messages.isEmpty {
            let combinedMessage = messages.joined(separator: "\n")
            logWarning(type: "Multiple Warnings", message: combinedMessage)
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

    func loadWarningLogs() {
        if let data = UserDefaults.standard.data(forKey: "WarningLogs"),
           let logs = try? JSONDecoder().decode([WarningLog].self, from: data) {
            warningLogs = logs
        }
    }
}
