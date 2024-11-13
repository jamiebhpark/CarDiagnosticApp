import Foundation
import SwiftUI

// 차량 상태를 관리하고 각 센서의 상태를 평가하는 클래스
class CarStatusManager {
    let settings: ThresholdSettings
    
    // 설정값을 기반으로 초기화하는 생성자
    init(settings: ThresholdSettings) {
        self.settings = settings
    }
    
    // 엔진 온도 평가 메서드
    // 설정된 온도 임계값을 초과하는 경우 경고 메시지를 반환
    func evaluateEngineTemperature(_ temperature: Double) -> String? {
        if temperature > settings.engineTemperatureThresholdHigh {
            return String(format: "Warning: Engine temperature is above %.0f°C!", settings.engineTemperatureThresholdHigh)
        }
        return nil
    }
    
    // 배터리 레벨 평가 메서드
    // 설정된 배터리 레벨 임계값보다 낮을 경우 경고 메시지를 반환
    func evaluateBatteryLevel(_ level: Double) -> String? {
        if level < settings.batteryLevelThresholdLow {
            return String(format: "Warning: Battery level is below %.0f%%!", settings.batteryLevelThresholdLow)
        }
        return nil
    }
    
    // 타이어 압력 평가 메서드
    // 설정된 압력 임계값을 벗어날 경우 경고 메시지를 반환
    func evaluateTirePressure(_ pressure: Double) -> String? {
        if pressure < settings.tirePressureThresholdLow {
            return String(format: "Warning: Tire pressure is below %.0f PSI!", settings.tirePressureThresholdLow)
        } else if pressure > settings.tirePressureThresholdHigh {
            return String(format: "Warning: Tire pressure is above %.0f PSI!", settings.tirePressureThresholdHigh)
        }
        return nil
    }
    
    // 배터리 전압 평가 메서드
    // 전압이 정상 범위를 벗어나면 경고 메시지를 반환
    func evaluateBatteryVoltage(_ voltage: Double) -> String? {
        if voltage < 12.0 || voltage > 13.8 {
            return "Warning: Battery voltage is abnormal (normal range: 12.0 - 13.8 V)."
        }
        return nil
    }
    
    // 산소 센서 평가 메서드
    // 산소 센서 전압이 정상 범위를 벗어나면 경고 메시지를 반환
    func evaluateOxygenSensor(_ sensorValue: Double) -> String? {
        if sensorValue < 0.2 || sensorValue > 0.8 {
            return "Warning: Oxygen sensor voltage is outside the normal range (0.2 - 0.8 V)."
        }
        return nil
    }
    
    // 연료 레벨 평가 메서드
    // 연료 레벨이 임계값보다 낮을 경우 경고 메시지를 반환
    func evaluateFuelLevel(_ level: Double) -> String? {
        if level < 15 {
            return "Warning: Fuel level is below 15%."
        }
        return nil
    }
    
    // 엔진 온도, 배터리 레벨, 타이어 압력을 종합적으로 평가하여 차량의 전체 상태를 반환
    // 경고 상태, 보통 상태, 좋은 상태에 따라 다른 메시지와 색상을 반환
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
