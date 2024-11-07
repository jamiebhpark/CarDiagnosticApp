import Foundation
import Combine
import SwiftUI

class MockDataManager {
    private var timer: Timer?
    var isConnected: Bool = false
    
    func startMockDataUpdates(carData: CarData) {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard self.isConnected else { return }
            
            carData.engineTemperature = Double.random(in: 60...120)
            carData.batteryLevel = Double.random(in: 10...100)
            carData.fuelEfficiency = Double.random(in: 5...20)
            carData.tirePressure = Double.random(in: 28...35)
            carData.batteryVoltage = Double.random(in: 12.0...13.8)
            carData.fuelLevel = Double.random(in: 10...100)
            carData.intakeAirTemperature = Double.random(in: 20...40)
            carData.engineLoad = Double.random(in: 20...80)
            carData.oxygenSensor = Double.random(in: 0.1...0.9)
        }
    }
    
    func stopMockDataUpdates() {
        timer?.invalidate()
        timer = nil
    }
}
