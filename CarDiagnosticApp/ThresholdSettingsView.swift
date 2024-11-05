import SwiftUI

struct ThresholdSettingsView: View {
    @ObservedObject var settings: ThresholdSettings
    
    var body: some View {
        Form {
            Section(header: Text("Engine Temperature Threshold")) {
                Slider(value: $settings.engineTemperatureThreshold, in: 50...150, step: 1) {
                    Text("Engine Temperature")
                }
                Text("Current Threshold: \(settings.engineTemperatureThreshold, specifier: "%.0f") °C")
            }
            
            Section(header: Text("Battery Level Threshold")) {
                Slider(value: $settings.batteryLevelThreshold, in: 5...100, step: 1) {
                    Text("Battery Level")
                }
                Text("Current Threshold: \(settings.batteryLevelThreshold, specifier: "%.0f") %")
            }
        }
        .navigationTitle("Threshold Settings")
    }
}
