import Foundation

class DataUpdateManager {
    func updateData(for carData: CarData) {
        carData.engineTemperature = Double.random(in: 60...120)
        carData.batteryLevel = Double.random(in: 10...100)
        carData.fuelEfficiency = Double.random(in: 5...20)
        
        let currentBatteryUsage = BatteryUsage(date: Date(), batteryLevel: carData.batteryLevel)
        carData.batteryUsageHistory.append(currentBatteryUsage)
        
        if carData.batteryUsageHistory.count > 100 { carData.batteryUsageHistory.removeFirst() }
        
        carData.engineTemperatureHistory.append(DataPoint(time: Date(), value: carData.engineTemperature))
        carData.batteryLevelHistory.append(DataPoint(time: Date(), value: carData.batteryLevel))
        carData.fuelEfficiencyHistory.append(DataPoint(time: Date(), value: carData.fuelEfficiency))
        
        if carData.engineTemperatureHistory.count > 50 { carData.engineTemperatureHistory.removeFirst() }
        if carData.batteryLevelHistory.count > 50 { carData.batteryLevelHistory.removeFirst() }
        if carData.fuelEfficiencyHistory.count > 50 { carData.fuelEfficiencyHistory.removeFirst() }
        
        DiagnosticDataManager.saveDiagnosticData(for: carData)
        carData.checkForAlerts()
    }
}
