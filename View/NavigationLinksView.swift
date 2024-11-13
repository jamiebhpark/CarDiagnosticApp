import SwiftUI

// 여러 네비게이션 링크를 포함한 뷰를 정의
struct NavigationLinksView: View {
    var carData: CarData // 차량 데이터 객체
    var settings: ThresholdSettings // 경고 임계값 설정 객체
    
    var body: some View {
        VStack(spacing: 10) {
            // 차량 상세 진단 뷰로 이동하는 네비게이션 링크
            NavigationLink(destination: DetailedDiagnosticView(carData: carData)) {
                NavigationButtonView(label: "View Detailed Diagnostics")
            }
            
            // 차량 진단 기록 뷰로 이동하는 네비게이션 링크
            NavigationLink(destination: DiagnosticHistoryView(carData: carData)) {
                NavigationButtonView(label: "View Diagnostic History")
            }
            
            // 경고 임계값 설정 뷰로 이동하는 네비게이션 링크
            NavigationLink(destination: ThresholdSettingsView(settings: settings)) {
                NavigationButtonView(label: "Set Alert Thresholds")
            }
            
            // 경고 기록 뷰로 이동하는 네비게이션 링크
            NavigationLink(destination: WarningHistoryView(carData: carData)) {
                NavigationButtonView(label: "View Warning History")
            }
        }
    }
}
