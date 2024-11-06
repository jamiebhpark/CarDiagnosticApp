import Foundation

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
    
    init() {
        let defaults = UserDefaults.standard
        engineTemperatureThresholdHigh = defaults.double(forKey: "engineTemperatureThresholdHigh") != 0 ? defaults.double(forKey: "engineTemperatureThresholdHigh") : 120
        engineTemperatureThresholdModerate = defaults.double(forKey: "engineTemperatureThresholdModerate") != 0 ? defaults.double(forKey: "engineTemperatureThresholdModerate") : 100
        batteryLevelThresholdLow = defaults.double(forKey: "batteryLevelThresholdLow") != 0 ? defaults.double(forKey: "batteryLevelThresholdLow") : 20
        batteryLevelThresholdModerate = defaults.double(forKey: "batteryLevelThresholdModerate") != 0 ? defaults.double(forKey: "batteryLevelThresholdModerate") : 50
        tirePressureThresholdLow = defaults.double(forKey: "tirePressureThresholdLow") != 0 ? defaults.double(forKey: "tirePressureThresholdLow") : 30
        tirePressureThresholdHigh = defaults.double(forKey: "tirePressureThresholdHigh") != 0 ? defaults.double(forKey: "tirePressureThresholdHigh") : 35
    }
    
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
