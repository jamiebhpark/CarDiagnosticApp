import Foundation

/// `ThresholdSettings`는 차량의 여러 진단 수치에 대한 임계값 설정을 관리하는 클래스입니다.
/// 사용자가 각 설정을 변경하면 해당 값이 자동으로 저장됩니다.
class ThresholdSettings: ObservableObject {
    @Published var engineTemperatureThresholdHigh: Double {
        didSet { saveSettings() }
    }
    @Published var engineTemperatureThresholdModerate: Double {
        didSet { saveSettings() }
    }
    @Published var batteryLevelThresholdLow: Double {
        didSet { saveSettings() }
    }
    @Published var batteryLevelThresholdModerate: Double {
        didSet { saveSettings() }
    }
    @Published var tirePressureThresholdLow: Double {
        didSet { saveSettings() }
    }
    @Published var tirePressureThresholdHigh: Double {
        didSet { saveSettings() }
    }
    
    /// 초기화 메서드 - 기본값을 설정하거나 저장된 값을 불러옵니다.
    init() {
        let defaults = UserDefaults.standard
        engineTemperatureThresholdHigh = defaults.double(forKey: "engineTemperatureThresholdHigh") != 0 ? defaults.double(forKey: "engineTemperatureThresholdHigh") : 120
        engineTemperatureThresholdModerate = defaults.double(forKey: "engineTemperatureThresholdModerate") != 0 ? defaults.double(forKey: "engineTemperatureThresholdModerate") : 100
        batteryLevelThresholdLow = defaults.double(forKey: "batteryLevelThresholdLow") != 0 ? defaults.double(forKey: "batteryLevelThresholdLow") : 20
        batteryLevelThresholdModerate = defaults.double(forKey: "batteryLevelThresholdModerate") != 0 ? defaults.double(forKey: "batteryLevelThresholdModerate") : 50
        tirePressureThresholdLow = defaults.double(forKey: "tirePressureThresholdLow") != 0 ? defaults.double(forKey: "tirePressureThresholdLow") : 30
        tirePressureThresholdHigh = defaults.double(forKey: "tirePressureThresholdHigh") != 0 ? defaults.double(forKey: "tirePressureThresholdHigh") : 35
    }
    
    /// 설정 변경 시 값을 UserDefaults에 저장하는 메서드입니다.
    private func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(engineTemperatureThresholdHigh, forKey: "engineTemperatureThresholdHigh")
        defaults.set(engineTemperatureThresholdModerate, forKey: "engineTemperatureThresholdModerate")
        defaults.set(batteryLevelThresholdLow, forKey: "batteryLevelThresholdLow")
        defaults.set(batteryLevelThresholdModerate, forKey: "batteryLevelThresholdModerate")
        defaults.set(tirePressureThresholdLow, forKey: "tirePressureThresholdLow")
        defaults.set(tirePressureThresholdHigh, forKey: "tirePressureThresholdHigh")
    }
}
