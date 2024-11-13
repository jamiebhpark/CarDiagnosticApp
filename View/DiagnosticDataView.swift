import SwiftUI

struct DiagnosticDataView: View {
    var label: String
    var value: String
    var color: Color
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(color)
        }
        .padding(.horizontal)
    }
}
