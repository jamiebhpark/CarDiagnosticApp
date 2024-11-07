import SwiftUI

struct NavigationButtonView: View {
    var label: String
    
    var body: some View {
        Text(label)
            .foregroundColor(.blue)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 1)
            )
    }
}
