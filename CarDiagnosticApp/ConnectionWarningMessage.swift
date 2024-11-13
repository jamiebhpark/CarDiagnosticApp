import SwiftUI

/// 뷰: OBD-II 장치가 연결되지 않았을 때 사용자에게 경고 메시지를 표시합니다.
struct ConnectionWarningMessage: View {
    var body: some View {
        Text("Please connect to the OBD-II device to start data monitoring.") // OBD-II 장치가 연결되지 않았을 때의 경고 메시지
            .foregroundColor(.red) // 경고 메시지를 빨간색으로 표시
            .font(.subheadline) // 서브헤드라인 크기의 폰트 사용
            .multilineTextAlignment(.center) // 텍스트를 중앙에 맞추어 정렬
            .padding(.horizontal) // 텍스트 주변에 가로 패딩 추가
    }
}
