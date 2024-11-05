import SwiftUI

struct LineGraphView: View {
    var dataPoints: [DataPoint]
    
    var body: some View {
        GeometryReader { geometry in
            guard dataPoints.count > 1, let firstTime = dataPoints.first?.time, let lastTime = dataPoints.last?.time else {
                // 데이터가 충분하지 않으면 빈 뷰 반환
                return AnyView(EmptyView())
            }
            
            let maxValue = dataPoints.map { $0.value }.max() ?? 1
            let minValue = dataPoints.map { $0.value }.min() ?? 0
            let valueRange = maxValue - minValue == 0 ? 1 : maxValue - minValue
            
            let totalTimeInterval = lastTime.timeIntervalSince(firstTime)
            
            let points = dataPoints.map { point in
                CGPoint(
                    x: geometry.size.width * CGFloat(point.time.timeIntervalSince(firstTime)) / CGFloat(totalTimeInterval),
                    y: geometry.size.height * CGFloat(1 - (point.value - minValue) / valueRange)
                )
            }
            
            return AnyView(
                Path { path in
                    if let firstPoint = points.first {
                        path.move(to: firstPoint)
                        for point in points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                }
                .stroke(Color.blue, lineWidth: 2)
            )
        }
    }
}
