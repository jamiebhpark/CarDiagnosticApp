import Foundation

class DiagnosticDataManager {
    static func saveDiagnosticData(for carData: CarData) {
        let history = [
            "date": Date(),
            "engineTemperature": carData.engineTemperature,
            "batteryLevel": carData.batteryLevel,
            "fuelEfficiency": carData.fuelEfficiency,
            "tirePressure": carData.tirePressure,
            "batteryVoltage": carData.batteryVoltage,
            "fuelLevel": carData.fuelLevel,
            "intakeAirTemperature": carData.intakeAirTemperature,
            "engineLoad": carData.engineLoad,
            "oxygenSensor": carData.oxygenSensor
        ] as [String : Any]
        
        var diagnosticHistory = UserDefaults.standard.array(forKey: "DiagnosticHistory") as? [[String: Any]] ?? []
        diagnosticHistory.append(history)
        
        // 최근 10개의 기록만 유지
        if diagnosticHistory.count > 10 {
            diagnosticHistory.removeFirst(diagnosticHistory.count - 10)
        }
        
        UserDefaults.standard.set(diagnosticHistory, forKey: "DiagnosticHistory")
    }
    
    static func loadDiagnosticHistory() -> [DiagnosticRecord] {
        let diagnosticHistory = UserDefaults.standard.array(forKey: "DiagnosticHistory") as? [[String: Any]] ?? []
        
        return diagnosticHistory.compactMap { item in
            if let date = item["date"] as? Date,
               let engineTemperature = item["engineTemperature"] as? Double,
               let batteryLevel = item["batteryLevel"] as? Double,
               let fuelEfficiency = item["fuelEfficiency"] as? Double,
               let tirePressure = item["tirePressure"] as? Double,
               let batteryVoltage = item["batteryVoltage"] as? Double,
               let fuelLevel = item["fuelLevel"] as? Double,
               let intakeAirTemperature = item["intakeAirTemperature"] as? Double,
               let engineLoad = item["engineLoad"] as? Double,
               let oxygenSensor = item["oxygenSensor"] as? Double {
                return DiagnosticRecord(
                    date: date,
                    engineTemperature: engineTemperature,
                    batteryLevel: batteryLevel,
                    fuelEfficiency: fuelEfficiency,
                    tirePressure: tirePressure,
                    batteryVoltage: batteryVoltage,
                    fuelLevel: fuelLevel,
                    intakeAirTemperature: intakeAirTemperature,
                    engineLoad: engineLoad,
                    oxygenSensor: oxygenSensor
                )
            }
            return nil
        }
    }
}
