import SwiftUI

struct ThresholdSettingsView: View {
    @ObservedObject var settings: ThresholdSettings
    
    var body: some View {
        Form {
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
