import Foundation
import UserNotifications

/// `AlertManager`는 차량 진단 데이터와 관련된 경고 알림을 처리하는 클래스입니다.
/// `WarningManager`를 사용하여 경고를 기록하고, iOS의 `UNUserNotificationCenter`를 통해 알림을 제공합니다.
class AlertManager {
    private let warningManager: WarningManager

    /// `AlertManager`의 초기화 메서드입니다.
    /// - Parameter warningManager: 경고 기록을 관리할 `WarningManager` 인스턴스입니다.
    init(warningManager: WarningManager) {
        self.warningManager = warningManager
    }

    /// 주어진 메시지를 사용해 알림을 전송하는 메서드입니다.
    /// - Parameter message: 사용자에게 표시할 경고 메시지입니다.
    func sendAlertNotification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Car Diagnostic Alert"
        content.body = message
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    /// 알림 권한을 요청하는 정적 메서드입니다.
    /// 사용자에게 알림, 배지, 소리 권한을 요청합니다.
    static func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    /// 차량 데이터(`CarData`)를 검사하여 필요한 경고를 전송하고 기록하는 메서드입니다.
    /// - Parameter carData: 검사할 차량 데이터입니다.
    func checkForAlerts(carData: CarData) {
        // 엔진 온도 경고
        if carData.engineTemperature > carData.settings.engineTemperatureThresholdHigh {
            let message = String(format: "Warning: Engine temperature is above %.0f°C!", carData.settings.engineTemperatureThresholdHigh)
            sendAlertNotification(message: message)
            warningManager.logWarning(type: "Engine Temperature", message: message)
        }
        
        // 배터리 레벨 경고
        if carData.batteryLevel < carData.settings.batteryLevelThresholdLow {
            let message = String(format: "Warning: Battery level is below %.0f%%!", carData.settings.batteryLevelThresholdLow)
            sendAlertNotification(message: message)
            warningManager.logWarning(type: "Battery Level", message: message)
        }
        
        // 타이어 압력 경고
        if carData.tirePressure < carData.settings.tirePressureThresholdLow {
            let message = String(format: "Warning: Tire pressure is below %.0f PSI!", carData.settings.tirePressureThresholdLow)
            sendAlertNotification(message: message)
            warningManager.logWarning(type: "Tire Pressure", message: message)
        } else if carData.tirePressure > carData.settings.tirePressureThresholdHigh {
            let message = String(format: "Warning: Tire pressure is above %.0f PSI!", carData.settings.tirePressureThresholdHigh)
            sendAlertNotification(message: message)
            warningManager.logWarning(type: "Tire Pressure", message: message)
        }
        
        // 배터리 전압 경고
        if carData.batteryVoltage < 12.0 || carData.batteryVoltage > 13.8 {
            let message = "Warning: Battery voltage is abnormal (normal range: 12.0 - 13.8 V)."
            sendAlertNotification(message: message)
            warningManager.logWarning(type: "Battery Voltage", message: message)
        }
        
        // 산소 센서 경고
        if carData.oxygenSensor < 0.2 || carData.oxygenSensor > 0.8 {
            let message = "Warning: Oxygen sensor voltage is outside the normal range (0.2 - 0.8 V)."
            sendAlertNotification(message: message)
            warningManager.logWarning(type: "Oxygen Sensor", message: message)
        }
        
        // 연료 레벨 경고 (예시: 15% 이하일 때)
        if carData.fuelLevel < 15 {
            let message = "Warning: Fuel level is below 15%."
            sendAlertNotification(message: message)
            warningManager.logWarning(type: "Fuel Level", message: message)
        }
    }
}
