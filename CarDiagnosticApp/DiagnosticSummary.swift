import SwiftUI

// 자동차의 진단 요약 정보를 표시하는 뷰
struct DiagnosticSummary: View {
    var carData: CarData // 진단할 차량 데이터를 포함한 객체
    var settings: ThresholdSettings // 진단 임계값 설정을 포함한 객체
    private var carStatusManager: CarStatusManager // 진단 상태를 관리하기 위한 객체
    
    // 생성자 - carData 및 설정 객체를 받아서 CarStatusManager 초기화
    init(carData: CarData, settings: ThresholdSettings) {
        self.carData = carData
        self.settings = settings
        self.carStatusManager = CarStatusManager(settings: settings)
    }

    var body: some View {
        // 여러 진단 데이터를 그룹으로 묶어 표시
        Group {
            // 엔진 온도 진단
            DiagnosticDataView(
                label: "Engine Temperature:",
                value: String(format: "%.1f °C", carData.engineTemperature),
                color: carData.engineTemperature > settings.engineTemperatureThresholdHigh ? .red : .primary // 온도가 임계값보다 높으면 빨간색, 그렇지 않으면 기본 색
            )
            
            // 배터리 레벨 진단
            DiagnosticDataView(
                label: "Battery Level:",
                value: String(format: "%.1f %%", carData.batteryLevel),
                color: carData.batteryLevel < settings.batteryLevelThresholdLow ? .orange : .primary // 배터리 레벨이 낮으면 주황색, 그렇지 않으면 기본 색
            )
            
            // 타이어 압력 진단
            DiagnosticDataView(
                label: "Tire Pressure:",
                value: String(format: "%.1f PSI", carData.tirePressure),
                color: carData.tirePressure < settings.tirePressureThresholdLow || carData.tirePressure > settings.tirePressureThresholdHigh ? .red : .primary // 압력이 임계값을 벗어나면 빨간색, 그렇지 않으면 기본 색
            )
        }
        .padding() // 모든 진단 데이터를 그룹화하여 패딩 추가
    }
}
