import SwiftUI

struct ConnectionWarningMessage: View {
    var body: some View {
        Text("Please connect to the OBD-II device to start data monitoring.")
            .foregroundColor(.red)
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
}
