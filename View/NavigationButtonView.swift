import SwiftUI

// 네비게이션 버튼의 라벨을 정의하는 뷰
struct NavigationButtonView: View {
    var label: String // 버튼에 표시될 텍스트
    
    var body: some View {
        // 버튼 라벨 텍스트 스타일 지정
        Text(label)
            .foregroundColor(.blue) // 텍스트 색상
            .padding() // 텍스트 주위에 패딩 추가
            .overlay(
                // 텍스트 주변에 테두리 추가
                RoundedRectangle(cornerRadius: 10) // 둥근 모서리를 가진 사각형
                    .stroke(Color.blue, lineWidth: 1) // 파란색 테두리, 두께 1
            )
    }
}
