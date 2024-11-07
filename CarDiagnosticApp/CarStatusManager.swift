import Foundation
import SwiftUI

class CarStatusManager {
    let settings: ThresholdSettings
    
    init(settings: ThresholdSettings) {
        self.settings = settings
    }
    
    func evaluateEngineTemperature(_ temperature: Double) -> String? {
        if temperature > settings.engineTemperatureThresholdHigh {
            return String(format: "Warning: Engine temperature is above %.0f°C!", settings.engineTemperatureThresholdHigh)
        }
        return nil
    }
    
    func evaluateBatteryLevel(_ level: Double) -> String? {
        if level < settings.batteryLevelThresholdLow {
            return String(format: "Warning: Battery level is below %.0f%%!", settings.batteryLevelThresholdLow)
        }
        return nil
    }
    
    func evaluateTirePressure(_ pressure: Double) -> String? {
        if pressure < settings.tirePressureThresholdLow {
            return String(format: "Warning: Tire pressure is below %.0f PSI!", settings.tirePressureThresholdLow)
        } else if pressure > settings.tirePressureThresholdHigh {
            return String(format: "Warning: Tire pressure is above %.0f PSI!", settings.tirePressureThresholdHigh)
        }
        return nil
    }
    
    func evaluateBatteryVoltage(_ voltage: Double) -> String? {
        if voltage < 12.0 || voltage > 13.8 {
            return "Warning: Battery voltage is abnormal (normal range: 12.0 - 13.8 V)."
        }
        return nil
    }
    
    func evaluateOxygenSensor(_ sensorValue: Double) -> String? {
        if sensorValue < 0.2 || sensorValue > 0.8 {
            return "Warning: Oxygen sensor voltage is outside the normal range (0.2 - 0.8 V)."
        }
        return nil
    }
    
    func evaluateFuelLevel(_ level: Double) -> String? {
        if level < 15 {
            return "Warning: Fuel level is below 15%."
        }
        return nil
    }
    
    func overallStatus(engineTemperature: Double, batteryLevel: Double, tirePressure: Double, settings: ThresholdSettings) -> (String, Color) {
        if engineTemperature > settings.engineTemperatureThresholdHigh || batteryLevel < settings.batteryLevelThresholdLow || tirePressure < settings.tirePressureThresholdLow {
            return ("Warning", .red)
        } else if engineTemperature > settings.engineTemperatureThresholdModerate || batteryLevel < settings.batteryLevelThresholdModerate {
            return ("Moderate", .orange)
        } else {
            return ("Good", .green)
        }
    }
}
