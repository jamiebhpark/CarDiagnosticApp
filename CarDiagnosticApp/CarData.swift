import Foundation
import Combine
import UserNotifications
import SwiftUI

class CarData: ObservableObject {
    @Published var engineTemperature: Double
    @Published var batteryLevel: Double
    @Published var fuelEfficiency: Double
    @Published var engineTemperatureHistory: [DataPoint] = []
    @Published var batteryLevelHistory: [DataPoint] = []
    @Published var fuelEfficiencyHistory: [DataPoint] = []
    @Published var tirePressureHistory: [DataPoint] = []
    @Published var batteryUsageHistory: [BatteryUsage] = []
    
    // 추가 데이터 포인트
    @Published var tirePressure: Double = 32.0
    @Published var batteryVoltage: Double = 12.6
    @Published var fuelLevel: Double = 50.0
    @Published var intakeAirTemperature: Double = 25.0
    @Published var engineLoad: Double = 20.0
    @Published var oxygenSensor: Double = 0.45
    
    @Published var warningLogs: [WarningLog] = []
    private let maxWarningLogs = 50
    
    private var timer: Timer?
    var settings: ThresholdSettings
    var statusManager: CarStatusManager
    var warningManager: WarningManager
    var batteryLifeManager: BatteryLifeManager
    var dataUpdateManager = DataUpdateManager()
    var isConnected: Bool = false
    
    // MockDataManager 객체 생성
    private let mockDataManager = MockDataManager()

    
    init(settings: ThresholdSettings) {
        self.settings = settings
        self.statusManager = CarStatusManager(settings: settings)
        self.warningManager = WarningManager()
        self.batteryLifeManager = BatteryLifeManager()
        self.dataUpdateManager = DataUpdateManager()
        
        self.engineTemperature = Double.random(in: 60...120)
        self.batteryLevel = Double.random(in: 10...100)
        self.fuelEfficiency = Double.random(in: 5...20)
        
        // 모든 멤버 초기화 후에 타이머 설정 및 연결
        self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.dataUpdateManager.updateData(for: self)
        }
    }
    
    // PDF 리포트 생성 메서드 추가
    func generateEnhancedPDFReport() -> URL? {
        return PDFReportGenerator.generateEnhancedPDFReport(carData: self, statusManager: statusManager)
    }
    
    public func checkForAlerts() {
        let alertManager = AlertManager(warningManager: warningManager)
        alertManager.checkForAlerts(carData: self)
    }
    

    // OBD 연결 및 해제 메서드
    func connectToOBD() {
        isConnected = true
        mockDataManager.isConnected = true
        mockDataManager.startMockDataUpdates(carData: self)
    }
    
    func disconnectFromOBD() {
        isConnected = false
        mockDataManager.isConnected = false
        mockDataManager.stopMockDataUpdates()
    }
}
