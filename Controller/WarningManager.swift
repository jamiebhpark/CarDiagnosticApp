import Foundation

/// `WarningManager`는 차량 경고를 평가하고 로그를 관리하는 클래스입니다.
/// 차량 상태를 평가하여 필요 시 경고를 기록하고 유지 관리 팁을 제공하는 역할을 합니다.
class WarningManager: ObservableObject {
    private let maxWarningLogs = 50  // 최대 경고 로그 수
    @Published private(set) var warningLogs: [WarningLog] = []  // 경고 로그 배열
    private let statusManager: CarStatusManager  // 차량 상태를 평가하는 매니저
    var warningCount: [String: Int] = [:]  // 경고 발생 횟수를 기록하는 딕셔너리
    @Published var maintenanceTips: [String] = []  // 유지 관리 팁 배열

    /// `WarningManager`의 초기화 메서드
    /// - Parameter statusManager: 차량 상태를 평가하기 위한 `CarStatusManager` 인스턴스
    init(statusManager: CarStatusManager) {
        self.statusManager = statusManager
    }

    /// 차량 데이터를 평가하고, 필요한 경고를 로그에 추가하는 메서드
    /// - Parameter carData: 평가할 차량 데이터 (`CarData` 인스턴스)
    func evaluateAndLogWarnings(carData: CarData) {
        var messages: [String] = []

        if let engineWarning = statusManager.evaluateEngineTemperature(carData.engineTemperature) {
            messages.append(engineWarning)
            incrementWarningCount(for: "Engine Temperature")
        }

        if let batteryWarning = statusManager.evaluateBatteryLevel(carData.batteryLevel) {
            messages.append(batteryWarning)
            incrementWarningCount(for: "Battery Level")
        }

        if let tirePressureWarning = statusManager.evaluateTirePressure(carData.tirePressure) {
            messages.append(tirePressureWarning)
            incrementWarningCount(for: "Tire Pressure")
        }

        if let voltageWarning = statusManager.evaluateBatteryVoltage(carData.batteryVoltage) {
            messages.append(voltageWarning)
            incrementWarningCount(for: "Battery Voltage")
        }

        if let oxygenWarning = statusManager.evaluateOxygenSensor(carData.oxygenSensor) {
            messages.append(oxygenWarning)
            incrementWarningCount(for: "Oxygen Sensor")
        }

        if let fuelWarning = statusManager.evaluateFuelLevel(carData.fuelLevel) {
            messages.append(fuelWarning)
            incrementWarningCount(for: "Fuel Level")
        }

        // 여러 경고 메시지를 하나로 합쳐서 한 번에 추가
        if !messages.isEmpty {
            let combinedMessage = messages.joined(separator: "\n")
            logWarning(type: "Multiple Warnings", message: combinedMessage)
        }

    }

    /// 경고를 로그에 추가하고 저장하는 메서드
    /// - Parameters:
    ///   - type: 경고 유형
    ///   - message: 경고 메시지
    func logWarning(type: String, message: String) {
        let log = WarningLog(date: Date(), type: type, message: message)
        warningLogs.append(log)
        if warningLogs.count > maxWarningLogs {
            warningLogs.removeFirst()  // 최대 개수를 초과하면 가장 오래된 항목 제거
        }

        saveWarningLogs()  // 변경된 로그를 저장
    }

    /// 경고 발생 횟수를 증가시키는 메서드
    /// - Parameter type: 경고 유형
    private func incrementWarningCount(for type: String) {
        warningCount[type, default: 0] += 1
    }

    /// 경고 로그를 `UserDefaults`에 저장하는 메서드
    private func saveWarningLogs() {
        if let data = try? JSONEncoder().encode(warningLogs) {
            UserDefaults.standard.set(data, forKey: "WarningLogs")
        }
    }

    /// `UserDefaults`에서 경고 로그를 불러오는 메서드
    func loadWarningLogs() {
        if let data = UserDefaults.standard.data(forKey: "WarningLogs"),
           let logs = try? JSONDecoder().decode([WarningLog].self, from: data) {
            warningLogs = logs
        }
    }
}
