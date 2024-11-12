import Foundation
import Combine
import UserNotifications
import SwiftUI

/// 차량 데이터 및 진단을 관리하는 클래스
class CarData: ObservableObject {
    // 주요 차량 데이터 프로퍼티들
    @Published var engineTemperature: Double
    @Published var batteryLevel: Double
    @Published var fuelEfficiency: Double
    @Published var engineTemperatureHistory: [DataPoint] = []
    @Published var batteryLevelHistory: [DataPoint] = []
    @Published var fuelEfficiencyHistory: [DataPoint] = []
    @Published var tirePressureHistory: [DataPoint] = []
    @Published var batteryUsageHistory: [BatteryUsage] = []
    
    // 추가적인 차량 상태 데이터
    @Published var tirePressure: Double = 32.0
    @Published var batteryVoltage: Double = 12.6
    @Published var fuelLevel: Double = 50.0
    @Published var intakeAirTemperature: Double = 25.0
    @Published var engineLoad: Double = 20.0
    @Published var oxygenSensor: Double = 0.45

    private var timer: Timer? // 차량 데이터를 주기적으로 업데이트하기 위한 타이머
    var settings: ThresholdSettings // 경고 발생 임계값 설정
    var statusManager: CarStatusManager // 차량 상태 평가를 담당하는 매니저
    var warningManager: WarningManager // 경고를 관리하는 매니저
    var batteryLifeManager: BatteryLifeManager // 배터리 수명을 예측하는 매니저
    var isConnected: Bool = false // OBD-II 연결 상태

    // 경고 기록 노출을 위한 래퍼 프로퍼티
    var warningLogs: [WarningLog] {
        warningManager.warningLogs
    }

    /// `CarData` 클래스 초기화 메서드
    /// - Parameter settings: 차량 경고 임계값 설정
    init(settings: ThresholdSettings) {
        self.settings = settings
        self.statusManager = CarStatusManager(settings: settings)
        self.warningManager = WarningManager(statusManager: statusManager)
        self.batteryLifeManager = BatteryLifeManager()
        
        // 차량 데이터 초기화
        self.engineTemperature = Double.random(in: 60...120)
        self.batteryLevel = Double.random(in: 10...100)
        self.fuelEfficiency = Double.random(in: 5...20)
        
        // 타이머를 설정하여 주기적으로 데이터를 업데이트
        self.timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(updateData), userInfo: nil, repeats: true)
    }
    
    /// PDF 리포트를 생성하는 메서드
    /// - Returns: 차량 데이터 리포트를 포함하는 PDF 파일의 URL
    func generateEnhancedPDFReport() -> URL? {
        return PDFReportGenerator.generateEnhancedPDFReport(carData: self, statusManager: statusManager)
    }

    /// WarningManager를 통해 경고를 평가하고 기록
    public func checkForAlerts() {
        warningManager.evaluateAndLogWarnings(carData: self)
    }
    
    /// OBD-II 장치에 연결하는 메서드
    func connectToOBD() {
        isConnected = true
    }
    
    /// OBD-II 장치와 연결을 해제하는 메서드
    func disconnectFromOBD() {
        isConnected = false
    }
    
    /// 차량 데이터를 업데이트하는 메서드 (타이머에 의해 호출됨)
    @objc func updateData() {
        guard isConnected else { return } // 연결된 경우에만 데이터 업데이트
        
        // 랜덤 데이터로 각 차량 상태 값을 업데이트
        engineTemperature = Double.random(in: 60...120)
        batteryLevel = Double.random(in: 10...100)
        fuelEfficiency = Double.random(in: 5...20)
        tirePressure = Double.random(in: 28...35)
        batteryVoltage = Double.random(in: 12.0...13.8)
        fuelLevel = Double.random(in: 10...100)
        intakeAirTemperature = Double.random(in: 20...40)
        engineLoad = Double.random(in: 20...80)
        oxygenSensor = Double.random(in: 0.1...0.9)
        
        // 배터리 사용 기록을 업데이트
        let currentBatteryUsage = BatteryUsage(date: Date(), batteryLevel: batteryLevel)
        batteryUsageHistory.append(currentBatteryUsage)
        
        // 최대 기록 개수를 넘으면 오래된 기록 삭제
        if batteryUsageHistory.count > 100 { batteryUsageHistory.removeFirst() }
        
        // 히스토리 데이터 업데이트
        engineTemperatureHistory.append(DataPoint(time: Date(), value: engineTemperature))
        batteryLevelHistory.append(DataPoint(time: Date(), value: batteryLevel))
        fuelEfficiencyHistory.append(DataPoint(time: Date(), value: fuelEfficiency))
        
        if engineTemperatureHistory.count > 50 { engineTemperatureHistory.removeFirst() }
        if batteryLevelHistory.count > 50 { batteryLevelHistory.removeFirst() }
        if fuelEfficiencyHistory.count > 50 { fuelEfficiencyHistory.removeFirst() }
        
        // 진단 데이터를 저장하고 경고를 체크
        DiagnosticDataManager.saveDiagnosticData(for: self)
        checkForAlerts()
    }
}
