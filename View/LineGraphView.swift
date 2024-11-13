import SwiftUI

// 데이터를 선 그래프로 시각화하는 뷰
struct LineGraphView: View {
    var dataPoints: [DataPoint] // 그래프로 표시할 데이터 포인트 배열
    
    var body: some View {
        GeometryReader { geometry in
            // 데이터 포인트가 2개 이상이면서 첫 번째와 마지막 시간 데이터가 존재하는지 확인
            guard dataPoints.count > 1, let firstTime = dataPoints.first?.time, let lastTime = dataPoints.last?.time else {
                // 데이터가 충분하지 않으면 빈 뷰 반환
                return AnyView(EmptyView())
            }
            
            // 데이터 포인트 값의 최대 및 최소값 계산
            let maxValue = dataPoints.map { $0.value }.max() ?? 1
            let minValue = dataPoints.map { $0.value }.min() ?? 0
            let valueRange = maxValue - minValue == 0 ? 1 : maxValue - minValue // 최소값과 최대값이 같을 때 분모가 0이 되는 것을 방지
            
            // 전체 시간 간격 계산
            let totalTimeInterval = lastTime.timeIntervalSince(firstTime)
            
            // 각 데이터 포인트의 위치 계산
            let points = dataPoints.map { point in
                CGPoint(
                    x: geometry.size.width * CGFloat(point.time.timeIntervalSince(firstTime)) / CGFloat(totalTimeInterval), // X축 좌표: 첫 번째 시간부터 현재 시간까지의 비율
                    y: geometry.size.height * CGFloat(1 - (point.value - minValue) / valueRange) // Y축 좌표: 값의 범위를 사용하여 그래프의 높이를 비율로 변환
                )
            }
            
            // 선 그래프 그리기
            return AnyView(
                Path { path in
                    if let firstPoint = points.first {
                        path.move(to: firstPoint) // 첫 번째 점으로 이동
                        for point in points.dropFirst() {
                            path.addLine(to: point) // 이후 각 점을 연결하여 선을 그림
                        }
                    }
                }
                .stroke(Color.blue, lineWidth: 2) // 파란색 선, 두께 2
            )
        }
    }
}
