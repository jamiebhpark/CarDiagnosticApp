import SwiftUI

/// `ThresholdSettingsView`는 차량의 각종 임계값을 설정할 수 있는 뷰입니다.
/// 사용자는 엔진 온도, 배터리 레벨, 타이어 압력의 경고 임계값을 슬라이더를 통해 조정할 수 있습니다.
struct ThresholdSettingsView: View {
    @ObservedObject var settings: ThresholdSettings
    
    var body: some View {
        Form {
            // 엔진 온도 임계값 설정 섹션
            Section(header: Text("Engine Temperature Thresholds")) {
                Slider(value: $settings.engineTemperatureThresholdModerate, in: 50...150, step: 1) {
                    Text("Moderate Threshold")
                }
                Text("Moderate Threshold: \(settings.engineTemperatureThresholdModerate, specifier: "%.0f") °C")
                
                Slider(value: $settings.engineTemperatureThresholdHigh, in: 50...150, step: 1) {
                    Text("High Threshold")
                }
                Text("High Threshold: \(settings.engineTemperatureThresholdHigh, specifier: "%.0f") °C")
            }
            
            // 배터리 레벨 임계값 설정 섹션
            Section(header: Text("Battery Level Thresholds")) {
                Slider(value: $settings.batteryLevelThresholdModerate, in: 5...100, step: 1) {
                    Text("Moderate Threshold")
                }
                Text("Moderate Threshold: \(settings.batteryLevelThresholdModerate, specifier: "%.0f") %")
                
                Slider(value: $settings.batteryLevelThresholdLow, in: 5...100, step: 1) {
                    Text("Low Threshold")
                }
                Text("Low Threshold: \(settings.batteryLevelThresholdLow, specifier: "%.0f") %")
            }
            
            // 타이어 압력 임계값 설정 섹션
            Section(header: Text("Tire Pressure Thresholds")) {
                Slider(value: $settings.tirePressureThresholdLow, in: 20...40, step: 0.1) {
                    Text("Low Threshold")
                }
                Text("Low Threshold: \(settings.tirePressureThresholdLow, specifier: "%.1f") PSI")
                
                Slider(value: $settings.tirePressureThresholdHigh, in: 20...40, step: 0.1) {
                    Text("High Threshold")
                }
                Text("High Threshold: \(settings.tirePressureThresholdHigh, specifier: "%.1f") PSI")
            }
        }
        .navigationTitle("Threshold Settings")
    }
}
