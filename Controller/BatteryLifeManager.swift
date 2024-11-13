import Foundation

/// `BatteryLifeManager`는 배터리 수명을 예측하는 기능을 제공하는 클래스입니다.
class BatteryLifeManager {
    
    /// 배터리 사용 기록을 기반으로 현재 배터리 수명을 예측하는 메서드입니다.
    /// - Parameters:
    ///   - batteryUsageHistory: 배터리 사용 내역을 담고 있는 배열입니다. 각 항목은 배터리 사용 시점의 정보를 포함합니다.
    ///   - currentBatteryLevel: 현재 배터리 잔량(%)입니다.
    /// - Returns: 배터리 수명을 예측한 문자열을 반환합니다.
    func predictBatteryLife(batteryUsageHistory: [BatteryUsage], currentBatteryLevel: Double) -> String {
        // 배터리 기록이 두 개 미만이면 예측 불가
        guard batteryUsageHistory.count >= 2 else {
            return "Not enough data for prediction"
        }
        
        // 최근 데이터 5개를 기준으로 배터리 감소량을 계산합니다.
        let recentData = batteryUsageHistory.suffix(5)
        guard let start = recentData.first, let end = recentData.last else {
            return "Not enough data for prediction"
        }
        
        // 시간 간격(시간 단위)을 계산합니다.
        let timeInterval = end.date.timeIntervalSince(start.date) / 3600
        
        // 시간 간격이 0 이하일 경우 예측 불가
        guard timeInterval > 0 else {
            return "Invalid time interval"
        }
        
        // 배터리 감소량과 시간당 감소율을 계산합니다.
        let batteryDecrease = start.batteryLevel - end.batteryLevel
        let decreaseRatePerHour = batteryDecrease / timeInterval
        
        // 배터리 감소율이 0 이하일 경우 배터리가 안정적이거나 증가 중임을 의미합니다.
        guard decreaseRatePerHour > 0 else {
            return "Battery level is stable or increasing"
        }
        
        // 현재 배터리 잔량을 사용하여 남은 시간을 예측합니다.
        let remainingTime = currentBatteryLevel / decreaseRatePerHour
        return String(format: "Estimated battery life: %.1f hours", remainingTime)
    }
}
