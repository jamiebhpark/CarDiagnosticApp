import SwiftUI
import UIKit

/// `ActivityView`는 공유 시트를 제공하는 UIKit의 `UIActivityViewController`를 SwiftUI에서 사용할 수 있도록 하는 구조체입니다.
/// 이를 통해 다양한 콘텐츠를 사용자에게 공유할 수 있습니다.
struct ActivityView: UIViewControllerRepresentable {
    /// 공유할 항목들을 포함하는 배열입니다. 예를 들어, 텍스트, URL 등을 전달할 수 있습니다.
    var activityItems: [Any]
    
    /// 커스텀 공유 활동을 추가할 수 있는 옵션입니다. 기본값은 `nil`입니다.
    var applicationActivities: [UIActivity]? = nil

    /// `UIActivityViewController` 인스턴스를 생성합니다.
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    /// `UIActivityViewController`의 상태 업데이트가 필요할 경우 호출됩니다.
    /// 현재는 업데이트 처리가 필요하지 않기 때문에 빈 메서드로 남겨져 있습니다.
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
