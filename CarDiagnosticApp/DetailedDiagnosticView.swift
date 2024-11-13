import SwiftUI

// 자동차의 자세한 진단 정보를 보여주는 뷰
struct DetailedDiagnosticView: View {
    @ObservedObject var carData: CarData // 자동차 데이터 객체를 관찰
    private var carStatusManager: CarStatusManager // 자동차 상태 평가 관리자
    
    // 초기화 메서드: carData를 전달받아 설정하고, CarStatusManager도 초기화
    init(carData: CarData) {
        self.carData = carData
        self.carStatusManager = CarStatusManager(settings: carData.settings)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 제목 텍스트
            Text("Detailed Car Diagnostic")
                .font(.title)
                .padding()
            
            VStack(spacing: 10) {
                // 엔진 온도 정보
                HStack {
                    Text("Engine Temperature:")
                    Spacer()
                    // CarStatusManager를 통해 엔진 온도 상태 평가
                    let engineStatus = carStatusManager.evaluateEngineTemperature(carData.engineTemperature)
                    let engineStatusColor = engineStatus != nil ? Color.red : Color.green
                    Text("\(carData.engineTemperature, specifier: "%.1f") °C")
                        .foregroundColor(engineStatusColor) // 상태에 따라 색상을 설정
                }
                
                // 배터리 레벨 정보
                HStack {
                    Text("Battery Level:")
                    Spacer()
                    let batteryStatus = carStatusManager.evaluateBatteryLevel(carData.batteryLevel)
                    let batteryStatusColor = batteryStatus != nil ? Color.orange : Color.green
                    Text("\(carData.batteryLevel, specifier: "%.1f") %")
                        .foregroundColor(batteryStatusColor)
                }
                
                // 연비 정보
                HStack {
                    Text("Fuel Efficiency:")
                    Spacer()
                    Text("\(carData.fuelEfficiency, specifier: "%.1f") km/l")
                        .foregroundColor(carData.fuelEfficiency < 10 ? .orange : .primary) // 연비가 낮으면 경고 색상
                }
                
                // 타이어 압력 정보
                HStack {
                    Text("Tire Pressure:")
                    Spacer()
                    let tireStatus = carStatusManager.evaluateTirePressure(carData.tirePressure)
                    let tireStatusColor = tireStatus != nil ? Color.red : Color.green
                    Text("\(carData.tirePressure, specifier: "%.1f") PSI")
                        .foregroundColor(tireStatusColor)
                }
                
                // 배터리 전압 정보
                HStack {
                    Text("Battery Voltage:")
                    Spacer()
                    let voltageStatus = carStatusManager.evaluateBatteryVoltage(carData.batteryVoltage)
                    let voltageStatusColor = voltageStatus != nil ? Color.orange : Color.primary
                    Text("\(carData.batteryVoltage, specifier: "%.1f") V")
                        .foregroundColor(voltageStatusColor)
                }
                
                // 연료 레벨 정보
                HStack {
                    Text("Fuel Level:")
                    Spacer()
                    let fuelStatus = carStatusManager.evaluateFuelLevel(carData.fuelLevel)
                    let fuelStatusColor = fuelStatus != nil ? Color.red : Color.primary
                    Text("\(carData.fuelLevel, specifier: "%.1f") %")
                        .foregroundColor(fuelStatusColor)
                }
                
                // 흡입 공기 온도 정보
                HStack {
                    Text("Intake Air Temperature:")
                    Spacer()
                    Text("\(carData.intakeAirTemperature, specifier: "%.1f") °C")
                        .foregroundColor(carData.intakeAirTemperature > 35 ? .orange : .primary) // 공기 온도가 높으면 경고
                }
                
                // 엔진 부하 정보
                HStack {
                    Text("Engine Load:")
                    Spacer()
                    Text("\(carData.engineLoad, specifier: "%.1f") %")
                        .foregroundColor(carData.engineLoad > 70 ? .red : .primary) // 엔진 부하가 높으면 경고
                }
                
                // 산소 센서 전압 정보
                HStack {
                    Text("Oxygen Sensor:")
                    Spacer()
                    let oxygenStatus = carStatusManager.evaluateOxygenSensor(carData.oxygenSensor)
                    let oxygenStatusColor = oxygenStatus != nil ? Color.orange : Color.primary
                    Text("\(carData.oxygenSensor, specifier: "%.2f") V")
                        .foregroundColor(oxygenStatusColor)
                }
            }
            .padding()
            
            Spacer() // 화면 하단에 공간을 추가하여 요소들이 밀집되지 않도록 함
        }
        .padding()
    }
}
