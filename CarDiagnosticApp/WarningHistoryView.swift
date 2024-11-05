import SwiftUI

struct WarningHistoryView: View {
    @ObservedObject var carData: CarData

    var body: some View {
        VStack {
            Text("Warning History")
                .font(.title)
                .padding()

            List(carData.warningLogs) { log in
                VStack(alignment: .leading) {
                    Text(log.date, style: .date)
                        .font(.headline)
                    Text("\(log.type): \(log.message)")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                .padding(.vertical, 5)
            }
        }
    }
}
