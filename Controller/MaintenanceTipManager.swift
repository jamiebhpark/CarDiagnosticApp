import Foundation

/// `MaintenanceTipManager`는 차량 상태와 경고 횟수에 따라 유지 관리 팁을 관리하는 클래스입니다.
class MaintenanceTipManager: ObservableObject {
    @Published private(set) var maintenanceTips: [String] = []  // 유지 관리 팁 배열
    
    /// `MaintenanceTipManager`의 초기화 메서드
    init() {
        loadMaintenanceTips() // 유지 관리 팁 불러오기
    }

    /// 유지 관리 팁을 업데이트하고 저장하는 메서드
    /// - Parameters:
    ///   - carData: 차량 데이터 (`CarData` 인스턴스)
    ///   - warningCount: 경고 발생 횟수를 기록한 딕셔너리
    func updateTips(basedOn carData: CarData, warningCount: [String: Int]) {
        var newTips: [String] = maintenanceTips // 기존 팁을 유지

        // 팁 추가 조건에 따라 새로운 팁을 추가
        // 중복되는 팁은 추가하지 않도록 기존 팁을 체크
        if carData.engineTemperature > carData.settings.engineTemperatureThresholdModerate,
           !newTips.contains("엔진 온도가 높습니다. 냉각수 레벨을 확인하고, 부족할 경우 보충하세요.") {
            newTips.append("엔진 온도가 높습니다. 냉각수 레벨을 확인하고, 부족할 경우 보충하세요.")
        }
        if let count = warningCount["Engine Temperature"], count >= 3,
           !newTips.contains("엔진 온도 경고가 여러 번 발생했습니다. 냉각 시스템을 점검하세요.") {
            newTips.append("엔진 온도 경고가 여러 번 발생했습니다. 냉각 시스템을 점검하세요.")
        }

        if carData.batteryLevel < carData.settings.batteryLevelThresholdLow,
           !newTips.contains("배터리 레벨이 낮습니다. 방전 방지를 위해 차량을 주기적으로 운행하거나 배터리를 충전하세요.") {
            newTips.append("배터리 레벨이 낮습니다. 방전 방지를 위해 차량을 주기적으로 운행하거나 배터리를 충전하세요.")
        }
        if let count = warningCount["Battery Level"], count >= 3,
           !newTips.contains("배터리 레벨 경고가 여러 번 발생했습니다. 배터리 상태를 점검하거나 교체를 고려하세요.") {
            newTips.append("배터리 레벨 경고가 여러 번 발생했습니다. 배터리 상태를 점검하거나 교체를 고려하세요.")
        }

        if carData.tirePressure < carData.settings.tirePressureThresholdLow || carData.tirePressure > carData.settings.tirePressureThresholdHigh,
           !newTips.contains("타이어 압력이 적정 범위를 벗어났습니다. 타이어를 점검하고 필요시 공기를 주입하거나 빼세요.") {
            newTips.append("타이어 압력이 적정 범위를 벗어났습니다. 타이어를 점검하고 필요시 공기를 주입하거나 빼세요.")
        }
        if let count = warningCount["Tire Pressure"], count >= 3,
           !newTips.contains("타이어 압력 경고가 여러 번 발생했습니다. 타이어 상태를 점검하고 필요 시 교체하세요.") {
            newTips.append("타이어 압력 경고가 여러 번 발생했습니다. 타이어 상태를 점검하고 필요 시 교체하세요.")
        }

        if carData.batteryVoltage < 12.0 || carData.batteryVoltage > 13.8,
           !newTips.contains("배터리 전압이 비정상적입니다. 배터리 또는 발전기 상태를 점검하세요.") {
            newTips.append("배터리 전압이 비정상적입니다. 배터리 또는 발전기 상태를 점검하세요.")
        }
        if let count = warningCount["Battery Voltage"], count >= 3,
           !newTips.contains("배터리 전압 경고가 여러 번 발생했습니다. 발전기 및 배터리 연결 상태를 점검하세요.") {
            newTips.append("배터리 전압 경고가 여러 번 발생했습니다. 발전기 및 배터리 연결 상태를 점검하세요.")
        }

        if carData.fuelLevel < 15,
           !newTips.contains("연료가 부족합니다. 가까운 주유소에서 연료를 보충하세요.") {
            newTips.append("연료가 부족합니다. 가까운 주유소에서 연료를 보충하세요.")
        }
        if let count = warningCount["Fuel Level"], count >= 3,
           !newTips.contains("연료 부족 경고가 여러 번 발생했습니다. 연료 시스템에 문제가 있는지 확인하세요.") {
            newTips.append("연료 부족 경고가 여러 번 발생했습니다. 연료 시스템에 문제가 있는지 확인하세요.")
        }

        if carData.oxygenSensor < 0.2 || carData.oxygenSensor > 0.8,
           !newTips.contains("산소 센서의 값이 정상 범위를 벗어났습니다. 배기가스 시스템을 점검하세요.") {
            newTips.append("산소 센서의 값이 정상 범위를 벗어났습니다. 배기가스 시스템을 점검하세요.")
        }
        if let count = warningCount["Oxygen Sensor"], count >= 3,
           !newTips.contains("산소 센서 경고가 여러 번 발생했습니다. 배기가스 시스템을 점검하고 필요 시 센서를 교체하세요.") {
            newTips.append("산소 센서 경고가 여러 번 발생했습니다. 배기가스 시스템을 점검하고 필요 시 센서를 교체하세요.")
        }

        // 팁 업데이트 및 저장
        maintenanceTips = newTips
        saveMaintenanceTips()
    }

    /// 유지 관리 팁을 `UserDefaults`에 저장하는 메서드
    private func saveMaintenanceTips() {
        if let data = try? JSONEncoder().encode(maintenanceTips) {
            UserDefaults.standard.set(data, forKey: "MaintenanceTips")
        }
    }

    /// `UserDefaults`에서 유지 관리 팁을 불러오는 메서드
    private func loadMaintenanceTips() {
        if let data = UserDefaults.standard.data(forKey: "MaintenanceTips"),
           let tips = try? JSONDecoder().decode([String].self, from: data) {
            maintenanceTips = tips
        }
    }
}
