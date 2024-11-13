import SwiftUI

/// `ReportButton`은 차량 진단 데이터를 기반으로 PDF 리포트를 생성하고 공유할 수 있는 버튼입니다.
struct ReportButton: View {
    // `@Binding`을 사용해 외부에서 전달받은 상태 변수를 활용하여 공유 시트와 경고 메시지 등을 업데이트합니다.
    @Binding var showingShareSheet: Bool // PDF 공유 시트 표시 여부를 제어합니다.
    @Binding var reportURL: URL? // 생성된 PDF의 URL을 저장합니다.
    @Binding var alertMessage: String // 경고 메시지를 저장합니다.
    @Binding var showAlert: Bool // 경고 메시지 창 표시 여부를 제어합니다.
    var carData: CarData // 차량 데이터를 포함하는 객체입니다.
    
    var body: some View {
        Button(action: {
            // PDF 리포트 생성
            if let url = carData.generateEnhancedPDFReport() {
                // 리포트 생성 성공 시 URL을 업데이트하고 공유 시트를 표시합니다.
                reportURL = url
                showingShareSheet = true
            } else {
                // 리포트 생성 실패 시 경고 메시지를 설정하고 경고 창을 표시합니다.
                alertMessage = "Failed to generate report."
                showAlert = true
            }
        }) {
            // 버튼 스타일 및 텍스트
            Text("Generate and Share Report")
                .foregroundColor(.blue)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 1)
                )
        }
    }
}
