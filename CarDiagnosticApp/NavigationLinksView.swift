import SwiftUI

struct NavigationLinksView: View {
    var carData: CarData
    var settings: ThresholdSettings
    
    var body: some View {
        VStack(spacing: 10) {
            NavigationLink(destination: DetailedDiagnosticView(carData: carData)) {
                NavigationButtonView(label: "View Detailed Diagnostics")
            }
            
            NavigationLink(destination: DiagnosticHistoryView(carData: carData)) {
                NavigationButtonView(label: "View Diagnostic History")
            }
            
            NavigationLink(destination: ThresholdSettingsView(settings: settings)) {
                NavigationButtonView(label: "Set Alert Thresholds")
            }
            
            NavigationLink(destination: WarningHistoryView(carData: carData)) {
                NavigationButtonView(label: "View Warning History")
            }
        }
    }
}
