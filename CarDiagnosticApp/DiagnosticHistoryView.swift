import SwiftUI

// 자동차 진단 기록을 보여주는 뷰
struct DiagnosticHistoryView: View {
    @ObservedObject var carData: CarData // CarData 객체를 감시하여 변경 사항이 있으면 UI 업데이트
    @State private var historyData: [DiagnosticRecord] = [] // 로드된 진단 기록을 저장할 배열
    @State private var currentPage = 0 // 현재 페이지를 추적
    @State private var isLoading = false // 데이터를 로드 중인지 여부를 나타내는 상태
    private let itemsPerPage = 10 // 한 페이지당 보여줄 기록 수

    var body: some View {
        List {
            // 기록 데이터를 반복하여 리스트 항목으로 보여줌
            ForEach(historyData, id: \.id) { item in
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date: \(dateFormatter.string(from: item.date))")
                        .font(.headline) // 기록 날짜

                    Group {
                        // 각 진단 항목을 그룹화하여 표시
                        Text("Engine Temperature: \(item.engineTemperature, specifier: "%.1f") °C")
                        Text("Battery Level: \(item.batteryLevel, specifier: "%.1f") %")
                        Text("Fuel Efficiency: \(item.fuelEfficiency, specifier: "%.1f") km/l")
                        Text("Tire Pressure: \(item.tirePressure, specifier: "%.1f") PSI")
                        Text("Battery Voltage: \(item.batteryVoltage, specifier: "%.1f") V")
                        Text("Fuel Level: \(item.fuelLevel, specifier: "%.1f") %")
                        Text("Intake Air Temperature: \(item.intakeAirTemperature, specifier: "%.1f") °C")
                        Text("Engine Load: \(item.engineLoad, specifier: "%.1f") %")
                        Text("Oxygen Sensor: \(item.oxygenSensor, specifier: "%.2f") V")
                    }
                    .padding(.leading, 10) // 각 항목에 패딩 추가
                }
                .padding() // 기록 전체에 패딩 추가
            }

            // 추가 페이지 로드 버튼 또는 로딩 인디케이터
            if isLoading {
                ProgressView() // 로딩 중일 때 인디케이터 표시
            } else if historyData.count >= (currentPage + 1) * itemsPerPage {
                Button("Load More") {
                    loadMoreData() // 더 많은 데이터를 로드하는 버튼
                }
                .padding()
            }
        }
        .onAppear {
            loadMoreData() // 뷰가 나타날 때 첫 번째 페이지 데이터를 로드
        }
        .navigationTitle("Diagnostic History") // 네비게이션 타이틀 설정
    }

    // 더 많은 데이터를 로드하는 메서드
    private func loadMoreData() {
        isLoading = true
        DispatchQueue.global(qos: .background).async {
            // 진단 기록 중 현재 페이지의 항목만 추가
            let newRecords = Array(DiagnosticDataManager.loadDiagnosticHistory().suffix(from: currentPage * itemsPerPage).prefix(itemsPerPage))
            DispatchQueue.main.async {
                self.historyData.append(contentsOf: newRecords) // 새로 로드된 기록을 추가
                self.currentPage += 1 // 페이지 증가
                self.isLoading = false // 로딩 완료
            }
        }
    }

    // 날짜 형식 설정을 위한 DateFormatter 프로퍼티
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // 날짜 형식 설정
        formatter.timeStyle = .short // 시간 형식 설정
        return formatter
    }
}
