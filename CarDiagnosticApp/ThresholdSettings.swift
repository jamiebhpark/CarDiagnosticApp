import Foundation

class ThresholdSettings: ObservableObject {
    @Published var engineTemperatureThreshold: Double {
        didSet { saveSettings() }
    }
    @Published var batteryLevelThreshold: Double {
        didSet { saveSettings() }
    }
    
    init() {
        // UserDefaults에서 임계값을 불러오거나 기본값을 설정
        let savedEngineTempThreshold = UserDefaults.standard.double(forKey: "engineTemperatureThreshold")
        self.engineTemperatureThreshold = savedEngineTempThreshold != 0 ? savedEngineTempThreshold : 100  // 기본값 설정
        
        let savedBatteryLevelThreshold = UserDefaults.standard.double(forKey: "batteryLevelThreshold")
        self.batteryLevelThreshold = savedBatteryLevelThreshold != 0 ? savedBatteryLevelThreshold : 20  // 기본값 설정
    }
    
    func saveSettings() {
        UserDefaults.standard.set(engineTemperatureThreshold, forKey: "engineTemperatureThreshold")
        UserDefaults.standard.set(batteryLevelThreshold, forKey: "batteryLevelThreshold")
    }
}
