import SwiftUI

/// `WarningHistoryView`는 차량 경고 이력을 표시하는 뷰입니다.
/// 사용자는 경고의 날짜와 시간을 확인할 수 있으며, 각 경고에는 경고 유형과 메시지가 포함되어 있습니다.
struct WarningHistoryView: View {
    @ObservedObject var carData: CarData

    var body: some View {
        VStack {
            // 경고 기록 제목
            Text("Warning History")
                .font(.title)
                .padding()

            // 경고 기록 리스트
            List(carData.warningLogs, id: \.id) { log in
                VStack(alignment: .leading) {
                    // 경고 날짜 및 시간
                    HStack {
                        Text(log.date, style: .date) // 경고 발생 날짜
                            .font(.headline)
                        Text(log.date, style: .time) // 경고 발생 시간
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    // 경고 유형 및 메시지
                    Text("\(log.type): \(log.message)")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                .padding(.vertical, 5)
            }
        }
    }
}
