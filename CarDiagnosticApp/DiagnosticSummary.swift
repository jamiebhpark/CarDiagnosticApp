import SwiftUI

struct DiagnosticSummary: View {
    var carData: CarData
    var settings: ThresholdSettings
    private var carStatusManager: CarStatusManager
    
    init(carData: CarData, settings: ThresholdSettings) {
        self.carData = carData
        self.settings = settings
        self.carStatusManager = CarStatusManager(settings: settings)
    }

    var body: some View {
        Group {
            DiagnosticDataView(
                label: "Engine Temperature:",
                value: String(format: "%.1f °C", carData.engineTemperature),
                color: carData.engineTemperature > settings.engineTemperatureThresholdHigh ? .red : .primary
            )
            DiagnosticDataView(
                label: "Battery Level:",
                value: String(format: "%.1f %%", carData.batteryLevel),
                color: carData.batteryLevel < settings.batteryLevelThresholdLow ? .orange : .primary
            )
            DiagnosticDataView(
                label: "Tire Pressure:",
                value: String(format: "%.1f PSI", carData.tirePressure),
                color: carData.tirePressure < settings.tirePressureThresholdLow || carData.tirePressure > settings.tirePressureThresholdHigh ? .red : .primary
            )
        }
        .padding()
    }
}
