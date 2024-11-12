import SwiftUI

struct WarningHistoryView: View {
    @ObservedObject var carData: CarData

    var body: some View {
        VStack {
            Text("Warning History")
                .font(.title)
                .padding()

            List(carData.warningLogs, id: \.id) { log in
                VStack(alignment: .leading) {
                    HStack {
                        Text(log.date, style: .date)
                            .font(.headline)
                        Text(log.date, style: .time)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Text("\(log.type): \(log.message)")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                .padding(.vertical, 5)
            }
        }
    }
}
