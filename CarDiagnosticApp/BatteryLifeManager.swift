import Foundation

class BatteryLifeManager {
    
    func predictBatteryLife(batteryUsageHistory: [BatteryUsage], currentBatteryLevel: Double) -> String {
        guard batteryUsageHistory.count >= 2 else {
            return "Not enough data for prediction"
        }
        
        let recentData = batteryUsageHistory.suffix(5)
        guard let start = recentData.first, let end = recentData.last else {
            return "Not enough data for prediction"
        }
        
        let timeInterval = end.date.timeIntervalSince(start.date) / 3600
        
        guard timeInterval > 0 else {
            return "Invalid time interval"
        }
        
        let batteryDecrease = start.batteryLevel - end.batteryLevel
        let decreaseRatePerHour = batteryDecrease / timeInterval
        
        guard decreaseRatePerHour > 0 else {
            return "Battery level is stable or increasing"
        }
        
        let remainingTime = currentBatteryLevel / decreaseRatePerHour
        return String(format: "Estimated battery life: %.1f hours", remainingTime)
    }
}
