import Foundation

// 자동차 진단 데이터 관리 클래스
class DiagnosticDataManager {

    // 자동차 진단 데이터를 저장하는 메서드
    static func saveDiagnosticData(for carData: CarData) {
        // 현재 시각과 각 데이터 포인트를 키-값 쌍으로 생성
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
        
        // UserDefaults에 저장된 진단 기록 배열을 불러옴 (없으면 빈 배열로 초기화)
        var diagnosticHistory = UserDefaults.standard.array(forKey: "DiagnosticHistory") as? [[String: Any]] ?? []
        diagnosticHistory.append(history)
        
        // 최근 10개의 기록만 유지하도록 처리 (오래된 데이터 제거)
        if diagnosticHistory.count > 10 {
            diagnosticHistory.removeFirst(diagnosticHistory.count - 10)
        }
        
        // 최신 기록을 UserDefaults에 저장
        UserDefaults.standard.set(diagnosticHistory, forKey: "DiagnosticHistory")
    }
    
    // 저장된 자동차 진단 기록을 불러오는 메서드
    static func loadDiagnosticHistory() -> [DiagnosticRecord] {
        // UserDefaults에서 진단 기록을 불러옴 (없으면 빈 배열로 초기화)
        let diagnosticHistory = UserDefaults.standard.array(forKey: "DiagnosticHistory") as? [[String: Any]] ?? []
        
        // 기록 배열을 DiagnosticRecord 형식으로 변환하여 반환
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
                // 모든 값이 유효할 경우 DiagnosticRecord 인스턴스로 변환
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
            return nil // 값이 없거나 잘못된 경우 nil 반환
        }
    }
}
