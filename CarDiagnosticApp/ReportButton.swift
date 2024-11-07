import SwiftUI

struct ReportButton: View {
    @Binding var showingShareSheet: Bool
    @Binding var reportURL: URL?
    @Binding var alertMessage: String
    @Binding var showAlert: Bool
    var carData: CarData
    
    var body: some View {
        Button(action: {
            if let url = carData.generateEnhancedPDFReport() {
                reportURL = url
                showingShareSheet = true
            } else {
                alertMessage = "Failed to generate report."
                showAlert = true
            }
        }) {
            Text("Generate and Share Report")
                .foregroundColor(.blue)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 1)
                )
        }
    }
}
